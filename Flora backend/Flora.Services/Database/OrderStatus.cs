using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public enum OrderStatus
    {
        Pending,
        PaymentInitiated,
        Processed,
        Delivered,
        Completed,
        Cancelled
    }
}
