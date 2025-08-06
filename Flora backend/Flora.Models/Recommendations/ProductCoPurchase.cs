using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Recommendations
{
    public class ProductCoPurchase
    {
        public int ProductId { get; set; }
        public int CoPurchasedProductId { get; set; }
        public int Count { get; set; } 
    }
}
