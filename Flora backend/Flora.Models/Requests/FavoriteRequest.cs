using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class FavoriteRequest
    {
        [Required(ErrorMessage = "User ID is required")]
        public int UserId { get; set; }
        
        [Required(ErrorMessage = "Product ID is required")]
        public int ProductId { get; set; }
    }

}
