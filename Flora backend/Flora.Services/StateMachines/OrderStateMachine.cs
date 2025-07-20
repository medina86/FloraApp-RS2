using Flora.Services.Database;
using System;
using System.Collections.Generic;

namespace Flora.Services.StateMachines
{
    public static class OrderStateMachine
    {
        private static readonly Dictionary<OrderStatus, List<OrderStatus>> _allowedTransitions = new()
        {
            { OrderStatus.Pending, new List<OrderStatus> { OrderStatus.PaymentInitiated, OrderStatus.Processed, OrderStatus.Cancelled } }, 
            { OrderStatus.PaymentInitiated, new List<OrderStatus> { OrderStatus.Processed, OrderStatus.Cancelled } },
            { OrderStatus.Processed, new List<OrderStatus> { OrderStatus.Delivered, OrderStatus.Cancelled } }, 
            { OrderStatus.Delivered, new List<OrderStatus> { OrderStatus.Completed } }, 
            { OrderStatus.Completed, new List<OrderStatus>() }, 
            { OrderStatus.Cancelled, new List<OrderStatus>() } 
        };

        public static void EnsureValidTransition(OrderStatus currentStatus, OrderStatus newStatus)
        {
            if (!_allowedTransitions.TryGetValue(currentStatus, out var allowedNextStates))
            {
                throw new Exception($"Invalid current order status: {currentStatus}");
            }

            if (!allowedNextStates.Contains(newStatus))
            {
                throw new Exception($"Invalid state transition from '{currentStatus}' to '{newStatus}'.");
            }
        }
    }
}
