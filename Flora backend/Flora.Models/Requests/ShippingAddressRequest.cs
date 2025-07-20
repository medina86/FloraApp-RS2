using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class ShippingAddressRequest
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string City { get; set; }
        public string? Street { get; set; }
        public string? HouseNumber { get; set; }
        public string PostalCode { get; set; }
        public string? OrderNote { get; set; }
    }
}
