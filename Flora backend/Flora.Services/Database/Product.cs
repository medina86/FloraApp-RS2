using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class Product
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }
        public int? CategoryId { get; set; }
        [ForeignKey("CategoryId")]
        public virtual Categories? Category { get; set; }
        public virtual ICollection<ProductImages> Images { get; set; } = new List<ProductImages>();
        public bool IsNew { get; set; } = false;
        public bool IsFeatured { get; set; } = false;
        public int? OccasionId { get; set; } 
        public Occasion? Occasion { get; set; }
        public bool Active { get; set; } = true;
        public bool IsAvailable { get; set; } = true;
    }
}
