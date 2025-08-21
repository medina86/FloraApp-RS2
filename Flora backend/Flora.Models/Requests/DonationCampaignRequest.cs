using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DonationCampaignRequest
    {
        [Required(ErrorMessage = "Campaign title is required")]
        [MaxLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
        public string Title { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Campaign description is required")]
        public string Description { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "End date is required")]
        [DataType(DataType.Date)]
        public DateTime EndDate { get; set; }
        public decimal TotalAmount { get; set; }
        
        public IFormFile? Image { get; set; }
    }
}
