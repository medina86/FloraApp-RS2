﻿using Flora.Models.Requests;
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

        public OrderService(FLoraDbContext context, IMapper mapper, IConfiguration configuration) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _configuration = configuration;
        }

        public async Task<OrderResponse> CreateOrderFromCart(OrderRequest request)
        {
            var cart = await _context.Carts
                .Include(c => c.Items)
                    .ThenInclude(ci => ci.Product)
                        .ThenInclude(p => p.Images)
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
                TotalAmount = cart.Items.Sum(item => (item.Product?.Price ?? 0) * item.Quantity)
            };
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            foreach (var cartItem in cart.Items)
            {
                var orderDetail = new OrderDetail
                {
                    OrderId = order.Id,
                    ProductId = cartItem.ProductId,
                    Quantity = cartItem.Quantity,
                    PriceAtPurchase = cartItem.Product?.Price ?? 0,
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

        public async Task<PayPalPaymentResponse> InitiatePayPalPaymentAsync(PayPalPaymentRequest request)
        {
            var paypalClientId = _configuration["PayPal:ClientID"];
            var paypalSecretKey = _configuration["PayPal:SecretKey"];

            if (string.IsNullOrEmpty(paypalClientId) || string.IsNullOrEmpty(paypalSecretKey))
            {
                throw new Exception("PayPal credentials are missing.");
            }

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == request.OrderId);
            if (order == null)
                throw new Exception("Order not found.");

            OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.PaymentInitiated);
            order.Status = OrderStatus.PaymentInitiated;
            await _context.SaveChangesAsync();

            var dummyPaymentIdFromPayPal = Guid.NewGuid().ToString();
            var simulatedReturnUrl = $"{request.ReturnUrl}?orderId={request.OrderId}&paymentId={dummyPaymentIdFromPayPal}";

            return new PayPalPaymentResponse
            {
                ApprovalUrl = simulatedReturnUrl,
                PaymentId = dummyPaymentIdFromPayPal
            };
        }

        public async Task<OrderResponse> ConfirmPayPalPaymentAsync(int orderId, string paymentId)
        {
            var order = await _context.Orders
                                    .Include(o => o.ShippingAddress)
                                    .Include(o => o.OrderDetails)
                                        .ThenInclude(od => od.Product)
                                            .ThenInclude(p => p.Images)
                                    .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
            {
                throw new Exception($"Order with ID {orderId} not found.");
            }

            if (string.IsNullOrEmpty(paymentId))
            {
                throw new Exception("Invalid PayPal payment ID.");
            }

            OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Processed);
            order.Status = OrderStatus.Processed;
            await _context.SaveChangesAsync();

            return _mapper.Map<OrderResponse>(order);
        }

        public async Task<OrderResponse> ProcessOrder(int orderId)
        {
            var order = await _context.Orders
                                  .Include(o => o.ShippingAddress)
                                  .Include(o => o.OrderDetails)
                                      .ThenInclude(od => od.Product)
                                          .ThenInclude(p => p.Images)
                                  .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
            {
                throw new Exception($"Order with ID {orderId} not found.");
            }

            OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Processed);
            order.Status = OrderStatus.Processed;
            await _context.SaveChangesAsync();

            return _mapper.Map<OrderResponse>(order);
        }

        public async Task<OrderResponse> DeliverOrder(int orderId)
        {
            var order = await _context.Orders
                                  .Include(o => o.ShippingAddress)
                                  .Include(o => o.OrderDetails)
                                      .ThenInclude(od => od.Product)
                                          .ThenInclude(p => p.Images)
                                  .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
            {
                throw new Exception($"Order with ID {orderId} not found.");
            }

            OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Delivered);
            order.Status = OrderStatus.Delivered;
            await _context.SaveChangesAsync();

            return _mapper.Map<OrderResponse>(order);
        }

        public async Task<OrderResponse> CompleteOrder(int orderId)
        {
            var order = await _context.Orders
                                  .Include(o => o.ShippingAddress)
                                  .Include(o => o.OrderDetails)
                                      .ThenInclude(od => od.Product)
                                          .ThenInclude(p => p.Images)
                                  .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null)
            {
                throw new Exception($"Order with ID {orderId} not found.");
            }

            OrderStateMachine.EnsureValidTransition(order.Status, OrderStatus.Completed);
            order.Status = OrderStatus.Completed;
            await _context.SaveChangesAsync();

            return _mapper.Map<OrderResponse>(order);
        }

        protected override IQueryable<Database.Order> ApplyFilter(IQueryable<Database.Order> query, OrderSearchObject search)
        {
            query = query
                .Include(o => o.ShippingAddress)
                .Include(o => o.OrderDetails)
                    .ThenInclude(od => od.Product)
                        .ThenInclude(p => p.Images);
            if (search.UserId.HasValue)
            {
                query = query.Where(o => o.UserId == search.UserId.Value);
            }
            if (!string.IsNullOrEmpty(search.Status))
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
                    ProductName = od.Product?.Name,
                    ProductImageUrl = od.Product?.Images?.FirstOrDefault()?.ImageUrl,
                    Quantity = od.Quantity,
                    PriceAtPurchase = od.PriceAtPurchase,
                    CardMessage = od.CardMessage,
                    SpecialInstructions = od.SpecialInstructions
                }).ToList()
            };
        }
    }
}
