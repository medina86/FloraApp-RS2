using Flora.Models;
using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using Flora.Services.StateMachines;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using System;
using System.Linq;
using System.Threading.Tasks;

    namespace Flora.Services.Services
    {
        public class OrderService : BaseCRUDService<OrderResponse, OrderSearchObject, Database.Order, OrderRequest, OrderRequest>, IOrderService
        {
            private readonly FLoraDbContext _context;
            private readonly IMapper _mapper;
            private readonly IConfiguration _configuration;
            private readonly IRecommendationService _recommendationService;
            private readonly IRabbitMQService _rabbitMQService;
            private readonly PayPalService _payPalService;

        public OrderService(
                FLoraDbContext context, 
                IMapper mapper, 
                IConfiguration configuration,
                IRecommendationService recommendationService,
                IRabbitMQService rabbitMQService,
                PayPalService payPalService) : base(context, mapper)


            {
                _context = context;
                _mapper = mapper;
                _configuration = configuration;
                _recommendationService = recommendationService;
                _rabbitMQService = rabbitMQService;
                _payPalService = payPalService;
            }
        private void SendOrderCreatedEmail(int orderId, string customerEmail)
        {
            var message = new EmailMessage
            {
                To = customerEmail,
                Subject = "Vaša narudžba je zaprimljena",
                Body = $"Hvala na kupovini! Vaša narudžba #{orderId} je uspješno zaprimljena i trenutno se obrađuje.",
                OrderId = orderId,
                OrderState = "Created"
            };

            _rabbitMQService.SendMessage("order.created", message);
        }

        public async Task<OrderResponse> CreateOrderFromCart(OrderRequest request)
            {
                var cart = await _context.Carts
                    .Include(c => c.Items)
                        .ThenInclude(ci => ci.Product)
                            .ThenInclude(p => p.Images)
                    .Include(c => c.Items)
                        .ThenInclude(ci => ci.CustomBouquet) 
                    .FirstOrDefaultAsync(c => c.Id == request.CartId && c.UserId == request.UserId);

                if (cart == null || !cart.Items.Any())
                    throw new Exception("Cart is invalid or empty.");

                var shippingAddress = _mapper.Map<ShippingAddress>(request.ShippingAddress);

                _context.ShippingAddresses.Add(shippingAddress);
                await _context.SaveChangesAsync();

                var order = new Database.Order
                {
                    UserId = request.UserId,
                    OrderDate = DateTime.UtcNow,
                    Status = OrderStatus.Pending,
                    ShippingAddressId = shippingAddress.Id,
                    TotalAmount = cart.Items.Sum(item => GetCartItemPrice(item) * item.Quantity)
                };
                _context.Orders.Add(order);
                await _context.SaveChangesAsync();
            var u=await _context.Users.FindAsync(request.UserId);
            SendOrderCreatedEmail(order.Id, u.Email);

            foreach (var cartItem in cart.Items)
                {
                    var orderDetail = new OrderDetail
                    {
                        OrderId = order.Id,
                        ProductId = cartItem.ProductId, 
                        CustomBouquetId = cartItem.CustomBouquetId, 
                        Quantity = cartItem.Quantity,
                        PriceAtPurchase = GetCartItemPrice(cartItem),
                        CardMessage = cartItem.CardMessage,
                        SpecialInstructions = cartItem.SpecialInstructions
                    };
                    _context.OrderDetails.Add(orderDetail);
                }
                await _context.SaveChangesAsync();

                _context.CartItems.RemoveRange(cart.Items);
                await _context.SaveChangesAsync();

                return _mapper.Map<OrderResponse>(order);
            }
        private void SendOrderStatusChangedEmail(int orderId, string customerEmail, string newStatus)
        {
            var message = new EmailMessage
            {
                To = customerEmail,
                Subject = $"Status vaše narudžbe #{orderId} je promijenjen",
                Body = $"Vaša narudžba sada ima status: {newStatus}.",
                OrderId = orderId,
                OrderState = newStatus
            };

            _rabbitMQService.SendMessage("order.statuschanged", message);
        }

        public async Task<OrderResponse> ProcessOrder(int orderId)
            {
                var order = await _context.Orders
                                      .Include(o => o.ShippingAddress)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.Product)
                                              .ThenInclude(p => p.Images)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.customBouquet)
                                      .FirstOrDefaultAsync(o => o.Id == orderId);

                if (order == null)
                {
                    throw new Exception($"Order with ID {orderId} not found.");
                }

                OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Processed);
                order.Status = OrderStatus.Processed;
                await _context.SaveChangesAsync();

                // Dohvati korisnika za email
                var user = await _context.Users.FindAsync(order.UserId);
                if (user != null)
                {
                    SendOrderStatusChangedEmail(order.Id, user.Email, "Processed");
                }

                return _mapper.Map<OrderResponse>(order);
            }

            public async Task<OrderResponse> DeliverOrder(int orderId)
            {
                var order = await _context.Orders
                                      .Include(o => o.ShippingAddress)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.Product)
                                              .ThenInclude(p => p.Images)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.customBouquet) 
                                      .FirstOrDefaultAsync(o => o.Id == orderId);

                if (order == null)
                {
                    throw new Exception($"Order with ID {orderId} not found.");
                }

                OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Delivered);
                order.Status = OrderStatus.Delivered;
                await _context.SaveChangesAsync();

                // Dohvati korisnika za email
                var user = await _context.Users.FindAsync(order.UserId);
                if (user != null)
                {
                    SendOrderStatusChangedEmail(order.Id, user.Email, "Delivered");
                }

                return _mapper.Map<OrderResponse>(order);
            }

            public async Task<OrderResponse> CompleteOrder(int orderId)
            {
                var order = await _context.Orders
                                      .Include(o => o.ShippingAddress)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.Product)
                                              .ThenInclude(p => p.Images)
                                      .Include(o => o.OrderDetails)
                                          .ThenInclude(od => od.customBouquet) 
                                      .FirstOrDefaultAsync(o => o.Id == orderId);

                if (order == null)
                {
                    throw new Exception($"Order with ID {orderId} not found.");
                }

                OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Completed);
                order.Status = OrderStatus.Completed;
                await _context.SaveChangesAsync();

                // Dohvati korisnika za email
                var user = await _context.Users.FindAsync(order.UserId);
                if (user != null)
                {
                    SendOrderStatusChangedEmail(order.Id, user.Email, "Completed");
                }
            
                _ = Task.Run(async () => 
                {
                    try
                    {
                        await _recommendationService.RecalculateSimilarityMapAsync();
                    }
                    catch
                    {
                    }
                });

                return _mapper.Map<OrderResponse>(order);
            }

            protected override IQueryable<Database.Order> ApplyFilter(IQueryable<Database.Order> query, OrderSearchObject search)
            {
                query = query
                    .Include(o => o.ShippingAddress)
                    .Include(o => o.OrderDetails)
                        .ThenInclude(od => od.Product)
                            .ThenInclude(p => p.Images)
                    .Include(o => o.OrderDetails)
                        .ThenInclude(od => od.customBouquet); 

                if (search?.UserId.HasValue == true)
                {
                    query = query.Where(o => o.UserId == search.UserId.Value);
                }
                if (!string.IsNullOrEmpty(search?.Status))
                {
                    if (Enum.TryParse<OrderStatus>(search.Status, true, out var parsedStatus))
                        query = query.Where(o => o.Status == parsedStatus);
                }
                return query;
            }

            protected override OrderResponse MapToResponse(Database.Order entity)
            {
                return new OrderResponse
                {
                    Id = entity.Id,
                    UserId = entity.UserId,
                    OrderDate = entity.OrderDate,
                    TotalAmount = entity.TotalAmount,
                    Status = entity.Status.ToString(),
                    ShippingAddress = _mapper.Map<ShippingAddressResponse>(entity.ShippingAddress),
                    OrderDetails = entity.OrderDetails!.Select(od => new OrderDetailResponse
                    {
                        Id = od.Id,
                        ProductId = od.ProductId, 
                        CustomBouquetId = od.CustomBouquetId,
                        ProductName = GetOrderDetailName(od),
                        ProductImageUrl = GetOrderDetailImageUrl(od),
                        Quantity = od.Quantity,
                        PriceAtPurchase = od.PriceAtPurchase,
                        CardMessage = od.CardMessage,
                        SpecialInstructions = od.SpecialInstructions
                    }).ToList()
                };
            }

            private decimal GetCartItemPrice(CartItem item)
            {
                if (item.Product != null)
                    return item.Product.Price;

                if (item.CustomBouquet != null)
                    return item.CustomBouquet.TotalPrice;

                return item.Price; 
            }

            private string GetOrderDetailName(OrderDetail orderDetail)
            {
                if (orderDetail.Product != null)
                    return orderDetail.Product.Name;

                if (orderDetail.customBouquet != null)
                    return "Custom Bouquet";

                return "Unknown Item";
            }

            private string GetOrderDetailImageUrl(OrderDetail orderDetail)
            {
                if (orderDetail.Product?.Images != null)
                    return orderDetail.Product.Images.FirstOrDefault()?.ImageUrl;

                return null;
            }

            public async Task<PayPalPaymentResponse> InitiatePayPalPaymentAsync(PayPalPaymentRequest request)
            {
                try
                {
                    var order = await _context.Orders.FindAsync(request.OrderId);
                    if (order == null)
                    {
                        throw new Exception($"Order with ID {request.OrderId} not found.");
                    }

                    OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.PaymentInitiated);
                    order.Status = OrderStatus.PaymentInitiated;

                    var returnUrl = "floraapp://paypal/success";
                    var cancelUrl = "floraapp://paypal/cancel";
                    var description = $"Flora Order #{request.OrderId}";

                    var payment = await _payPalService.CreatePayment(
                        request.Amount, 
                        request.Currency, 
                        description, 
                        returnUrl, 
                        cancelUrl
                    );

                    var approvalUrl = _payPalService.GetApprovalUrl(payment);

                    if (string.IsNullOrEmpty(approvalUrl))
                    {
                        throw new Exception("Failed to get PayPal approval URL.");
                    }

                    await _context.SaveChangesAsync();

                    return new PayPalPaymentResponse
                    {
                        PaymentId = payment.id,
                        ApprovalUrl = approvalUrl
                    };
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to initiate PayPal payment: {ex.Message}", ex);
                }
            }

            public async Task<OrderResponse> ConfirmPayPalPaymentAsync(int orderId, string paymentId)
            {
                try
                {
                    // Provjeri da li narudžba postoji
                    var order = await _context.Orders
                        .Include(o => o.ShippingAddress)
                        .Include(o => o.OrderDetails)
                            .ThenInclude(od => od.Product)
                                .ThenInclude(p => p.Images)
                        .Include(o => o.OrderDetails)
                            .ThenInclude(od => od.customBouquet)
                        .FirstOrDefaultAsync(o => o.Id == orderId);

                    if (order == null)
                    {
                        throw new Exception($"Order with ID {orderId} not found.");
                    }

                    if (string.IsNullOrEmpty(paymentId))
                    {
                        throw new Exception("Invalid PayPal payment ID.");
                    }

                    Console.WriteLine($"Auto-approving PayPal payment for testing/development");

                    OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Processed);
                    order.Status = OrderStatus.Processed;
                    await _context.SaveChangesAsync();

                    var user = await _context.Users.FindAsync(order.UserId);
                    if (user != null)
                    {
                        SendOrderStatusChangedEmail(order.Id, user.Email, "Processed");
                    }

                    Console.WriteLine($"Order {orderId} successfully processed via PayPal");
                    return _mapper.Map<OrderResponse>(order);
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to confirm PayPal payment: {ex.Message}", ex);
                }
            }

            // Nova metoda za inicijalizaciju PayPal plaćanja bez kreiranja narudžbe
            public async Task<PayPalPaymentResponse> InitiatePayPalPaymentWithoutOrderAsync(PayPalPaymentWithCartRequest request)
            {
                try
                {
                    // Validacija korpe
                    var cart = await _context.Carts
                        .Include(c => c.Items)
                            .ThenInclude(ci => ci.Product)
                                .ThenInclude(p => p.Images)
                        .Include(c => c.Items)
                            .ThenInclude(ci => ci.CustomBouquet)
                        .FirstOrDefaultAsync(c => c.Id == request.CartId && c.UserId == request.UserId);

                    if (cart == null || !cart.Items.Any())
                        throw new Exception("Cart is invalid or empty.");

                    // Validacija podataka za dostavu
                    if (request.ShippingAddress == null)
                        throw new Exception("Shipping address is required.");

                    var description = $"Flora Order for Cart #{request.CartId}";

                    var payment = await _payPalService.CreatePayment(
                        request.Amount,
                        request.Currency,
                        description,
                        request.ReturnUrl,
                        request.CancelUrl
                    );

                    var approvalUrl = _payPalService.GetApprovalUrl(payment);

                    if (string.IsNullOrEmpty(approvalUrl))
                    {
                        throw new Exception("Failed to get PayPal approval URL.");
                    }

                    return new PayPalPaymentResponse
                    {
                        PaymentId = payment.id,
                        ApprovalUrl = approvalUrl,
                        CartId = request.CartId,
                        UserId = request.UserId
                    };
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to initiate PayPal payment: {ex.Message}", ex);
                }
            }

            // Nova metoda za potvrdu PayPal plaćanja i kreiranje narudžbe
            public async Task<OrderResponse> ConfirmPayPalPaymentAndCreateOrderAsync(
                int userId, int cartId, ShippingAddressRequest shippingAddressRequest, 
                string paymentId, string payerId)
            {
                try
                {
                    // Validacija PayPal plaćanja
                    if (string.IsNullOrEmpty(paymentId))
                    {
                        throw new Exception("Invalid PayPal payment ID.");
                    }

                    if (string.IsNullOrEmpty(payerId))
                    {
                        throw new Exception("Invalid PayPal payer ID.");
                    }

                    // Izvršavanje PayPal plaćanja
                    await _payPalService.ExecutePayment(paymentId, payerId);

                    // Kreiranje narudžbe nakon uspješnog plaćanja
                    var orderRequest = new OrderRequest
                    {
                        UserId = userId,
                        CartId = cartId,
                        ShippingAddress = shippingAddressRequest
                    };

                    var order = await CreateOrderFromCart(orderRequest);
                    
                    return order;
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to confirm PayPal payment and create order: {ex.Message}", ex);
                }
            }
            
            // Nova metoda za inicijalizaciju PayPal plaćanja koristeći REST API
            public async Task<PayPalPaymentResponse> InitiatePayPalPaymentRestAsync(PayPalPaymentWithCartRequest request)
            {
                try
                {
                    // Validacija korpe
                    var cart = await _context.Carts
                        .Include(c => c.Items)
                            .ThenInclude(ci => ci.Product)
                                .ThenInclude(p => p.Images)
                        .Include(c => c.Items)
                            .ThenInclude(ci => ci.CustomBouquet)
                        .FirstOrDefaultAsync(c => c.Id == request.CartId && c.UserId == request.UserId);

                    if (cart == null || !cart.Items.Any())
                        throw new Exception("Cart is invalid or empty.");

                    // Validacija podataka za dostavu
                    if (request.ShippingAddress == null)
                        throw new Exception("Shipping address is required.");

                    var description = $"Flora Order for Cart #{request.CartId}";

                    // Koristi REST API za kreiranje PayPal narudžbe
                    var approvalUrl = await _payPalService.CreateOrderViaRest(
                        request.Amount,
                        request.Currency,
                        description,
                        request.ReturnUrl,
                        request.CancelUrl
                    );

                    if (string.IsNullOrEmpty(approvalUrl))
                    {
                        throw new Exception("Failed to get PayPal approval URL.");
                    }

                    // Ekstrahiraj orderId iz URL-a
                    var uri = new Uri(approvalUrl);
                    var queryParams = System.Web.HttpUtility.ParseQueryString(uri.Query);
                    var token = queryParams["token"];

                    return new PayPalPaymentResponse
                    {
                        PaymentId = token, // Koristimo token kao paymentId
                        ApprovalUrl = approvalUrl,
                        CartId = request.CartId,
                        UserId = request.UserId
                    };
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to initiate PayPal payment via REST API: {ex.Message}", ex);
                }
            }

            // Nova metoda za potvrdu PayPal plaćanja i kreiranje narudžbe koristeći REST API
            public async Task<OrderResponse> ConfirmPayPalPaymentAndCreateOrderRestAsync(
                int userId, int cartId, ShippingAddressRequest shippingAddressRequest, 
                string orderId)
            {
                try
                {
                    // Validacija PayPal narudžbe
                    if (string.IsNullOrEmpty(orderId))
                    {
                        throw new Exception("Invalid PayPal order ID.");
                    }

                    // Kreiranje narudžbe nakon uspješnog plaćanja
                    // Ovdje pretpostavljamo da je plaćanje već potvrđeno na PayPal strani
                    var orderRequest = new OrderRequest
                    {
                        UserId = userId,
                        CartId = cartId,
                        ShippingAddress = shippingAddressRequest
                    };

                    var order = await CreateOrderFromCart(orderRequest);
                    
                    return order;
                }
                catch (Exception ex)
                {
                    throw new Exception($"Failed to confirm PayPal payment and create order via REST API: {ex.Message}", ex);
                }
            }
        }
    }