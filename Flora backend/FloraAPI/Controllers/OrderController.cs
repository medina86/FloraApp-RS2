using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrderController : BaseCRUDController<OrderResponse, OrderSearchObject, OrderRequest, OrderRequest>
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService service) : base(service)
        {
            _orderService = service;
        }

        [HttpPost("createFromCart")]
        public async Task<IActionResult> CreateOrderFromCart([FromBody] OrderRequest request)
        {
            try
            {
                var order = await _orderService.CreateOrderFromCart(request);
                return Ok(order);
            }
            catch (System.Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        
        [HttpPost("initiatePayPalPayment")]
        public async Task<ActionResult<PayPalPaymentResponse>> InitiatePayPalPayment([FromBody] PayPalPaymentRequest request)
        {
            try
            {
                var response = await _orderService.InitiatePayPalPaymentAsync(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error initiating PayPal payment: {ex.Message}");
            }
        }

        [HttpPost("confirm-paypal-payment")]
        public async Task<ActionResult<OrderResponse>> ConfirmPayPalPayment(
            [FromQuery] int orderId,
            [FromQuery] string paymentId)
        {
            try
            {
                var order = await _orderService.ConfirmPayPalPaymentAsync(orderId, paymentId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error confirming PayPal payment: {ex.Message}");
            }
        }
        
        // Novi endpoint za inicijalizaciju PayPal plaćanja bez kreiranja narudžbe
        [HttpPost("initiatePayPalPaymentWithoutOrder")]
        public async Task<ActionResult<PayPalPaymentResponse>> InitiatePayPalPaymentWithoutOrder([FromBody] PayPalPaymentWithCartRequest request)
        {
            try
            {
                var response = await _orderService.InitiatePayPalPaymentWithoutOrderAsync(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error initiating PayPal payment: {ex.Message}");
            }
        }
        
        // Novi endpoint za potvrdu PayPal plaćanja i kreiranje narudžbe
        [HttpPost("confirm-paypal-payment-and-create-order")]
        public async Task<ActionResult<OrderResponse>> ConfirmPayPalPaymentAndCreateOrder(
            [FromQuery] int userId,
            [FromQuery] int cartId,
            [FromQuery] string paymentId,
            [FromQuery] string payerId,
            [FromBody] ShippingAddressRequest shippingAddress)
        {
            try
            {
                var order = await _orderService.ConfirmPayPalPaymentAndCreateOrderAsync(
                    userId, cartId, shippingAddress, paymentId, payerId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error confirming PayPal payment and creating order: {ex.Message}");
            }
        }
        
        // Novi endpoint za inicijalizaciju PayPal plaćanja koristeći REST API
        [HttpPost("initiatePayPalPaymentRest")]
        public async Task<ActionResult<PayPalPaymentResponse>> InitiatePayPalPaymentRest([FromBody] PayPalPaymentWithCartRequest request)
        {
            try
            {
                var response = await _orderService.InitiatePayPalPaymentRestAsync(request);
                return Ok(response);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error initiating PayPal payment via REST API: {ex.Message}");
            }
        }
        
        // Novi endpoint za potvrdu PayPal plaćanja i kreiranje narudžbe koristeći REST API
        [HttpPost("confirm-paypal-payment-and-create-order-rest")]
        public async Task<ActionResult<OrderResponse>> ConfirmPayPalPaymentAndCreateOrderRest(
            [FromQuery] int userId,
            [FromQuery] int cartId,
            [FromQuery] string orderId,
            [FromBody] ShippingAddressRequest shippingAddress)
        {
            try
            {
                var order = await _orderService.ConfirmPayPalPaymentAndCreateOrderRestAsync(
                    userId, cartId, shippingAddress, orderId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error confirming PayPal payment and creating order via REST API: {ex.Message}");
            }
        }
        [HttpPost("{orderId}/process")]
        public async Task<ActionResult<OrderResponse>> ProcessOrder(int orderId)
        {
            try
            {
                var order = await _orderService.ProcessOrder(orderId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error processing order: {ex.Message}");
            }
        }

        [HttpPost("{orderId}/deliver")]
        public async Task<ActionResult<OrderResponse>> DeliverOrder(int orderId)
        {
            try
            {
                var order = await _orderService.DeliverOrder(orderId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error delivering order: {ex.Message}");
            }
        }
        [HttpPost("{orderId}/complete")]
        public async Task<ActionResult<OrderResponse>> CompleteOrder(int orderId)
        {
            try
            {
                var order = await _orderService.CompleteOrder(orderId);
                return Ok(order);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error completing order: {ex.Message}");
            }
        }
    }

}


