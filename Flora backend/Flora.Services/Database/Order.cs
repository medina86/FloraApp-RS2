using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class Order
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public DateTime OrderDate { get; set; }
        public decimal TotalAmount { get; set; }
        public OrderStatus Status { get; set; } 

        public int ShippingAddressId { get; set; }
        public ShippingAddress ShippingAddress { get; set; }

        public ICollection<OrderDetail> OrderDetails { get; set; }
    }
}
