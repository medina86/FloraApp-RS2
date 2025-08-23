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
        Task<PayPalPaymentResponse> InitiatePayPalPaymentWithoutOrderAsync(PayPalPaymentWithCartRequest request);
        Task<OrderResponse> ConfirmPayPalPaymentAndCreateOrderAsync(int userId, int cartId, ShippingAddressRequest shippingAddress, string paymentId, string payerId);
        
        // Nova metoda za inicijalizaciju PayPal plaćanja koristeći REST API
        Task<PayPalPaymentResponse> InitiatePayPalPaymentRestAsync(PayPalPaymentWithCartRequest request);
        
        // Nova metoda za potvrdu PayPal plaćanja i kreiranje narudžbe koristeći REST API
        Task<OrderResponse> ConfirmPayPalPaymentAndCreateOrderRestAsync(int userId, int cartId, ShippingAddressRequest shippingAddress, string orderId);
        
        Task<OrderResponse> ProcessOrder(int orderId);
        Task<OrderResponse> DeliverOrder(int orderId);
        Task<OrderResponse> CompleteOrder(int orderId);
    }
}