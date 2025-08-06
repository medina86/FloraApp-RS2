using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class CustomBouquetResponse
    {
        public int Id { get; set; }
        public string Color { get; set; }
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
        public decimal TotalPrice { get; set; }
        public int? CustomBouquetId { get; set; }

        public List<CustomBouquetItemResponse> Items { get; set; }
    }
}
