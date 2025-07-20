using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IOrderService : ICRUDService<OrderResponse, OrderSearchObject, OrderRequest, OrderRequest>
    {
        Task<OrderResponse> CreateOrderFromCart(OrderRequest request);
        Task<PayPalPaymentResponse> InitiatePayPalPaymentAsync(PayPalPaymentRequest request); 
        Task<OrderResponse> ConfirmPayPalPaymentAsync(int orderId, string paymentId);
        Task<OrderResponse> ProcessOrder(int orderId);
        Task<OrderResponse> DeliverOrder(int orderId);
    }
}
