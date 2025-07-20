using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class OrderRequest
    {
        public int UserId { get; set; }
        public ShippingAddressRequest ShippingAddress { get; set; }
        public int CartId { get; set; }
    }
}
