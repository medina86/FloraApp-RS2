using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class CustomBouquetRequest
    {
        public string Color { get; set; }
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
        public decimal TotalPrice { get; set; }
        public int UserId {  get; set; }
        public List<CustomBouquetItemRequest> CustomBouquetItems { get; set; } = new();
    }
}
