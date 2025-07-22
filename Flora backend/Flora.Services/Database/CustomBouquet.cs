using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class CustomBouquet
    {
        public int Id { get; set; }
        public string Color { get; set; }
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
        public decimal TotalPrice { get; set; }

        public int UserId { get; set; } 
        public User User { get; set; }

        public ICollection<CustomBouquetItem> Items { get; set; } = new List<CustomBouquetItem>();
    }
}
