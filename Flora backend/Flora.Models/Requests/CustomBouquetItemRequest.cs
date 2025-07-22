using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class CustomBouquetItemRequest
    {
        public int ProductId { get; set; }
        public int Quantity { get; set; }
    }
}
