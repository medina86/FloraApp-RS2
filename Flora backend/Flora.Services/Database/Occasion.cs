using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class Occasion
    {
        public int OccasionId { get; set; }
        public string Name { get; set; }

        public ICollection<Product> Products { get; set; } = new List<Product>();
    }
}
