using Flora.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.StateMachines
{
    public static class OrderStateMachine
    {
        private static readonly Dictionary<OrderStatus, OrderStatus[]> ValidTransitions = new()
        {
            { OrderStatus.Pending, new[] { OrderStatus.PaymentInitiated, OrderStatus.Cancelled } },
            { OrderStatus.PaymentInitiated, new[] { OrderStatus.Processed, OrderStatus.Cancelled } },
            { OrderStatus.Processed, new[] { OrderStatus.Delivered, OrderStatus.Cancelled } },
            { OrderStatus.Delivered, new[] { OrderStatus.Completed } },
            { OrderStatus.Completed, Array.Empty<OrderStatus>() },
            { OrderStatus.Cancelled, Array.Empty<OrderStatus>() }
        };

        public static void EnsureValidTransition(OrderStatus current, OrderStatus next)
        {
            if (!ValidTransitions.TryGetValue(current, out var validNextStates) || !validNextStates.Contains(next))
            {
                throw new InvalidOperationException($"❌ Invalid state transition from '{current}' to '{next}'.");
            }
        }
    }
}
