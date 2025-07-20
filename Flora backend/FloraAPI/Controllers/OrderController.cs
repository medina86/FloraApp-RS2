using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FloraAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
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
    }

}


