using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Responses
{
    public class ProductResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public List<string> ImageUrls { get; set; } = new();
        public int? CategoryId { get; set; }
        public string? CategoryName { get; set; }
        public bool IsNew { get; set; } = false;
        public bool IsFeatured { get; set; } = false;
        public int? OccasionId { get; set; }
        public string? OccasionName { get; set; }
    }

}
