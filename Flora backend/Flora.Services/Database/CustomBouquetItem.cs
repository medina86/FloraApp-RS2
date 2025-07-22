using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class CustomBouquetItem
    {
        public int Id { get; set; }
        public int CustomBouquetId { get; set; }
        public CustomBouquet CustomBouquet { get; set; }

        public int ProductId { get; set; }
        public Product Product { get; set; }

        public int Quantity { get; set; }
    }
}
