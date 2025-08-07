using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DonationPayPalRequest
    {
        [Required(ErrorMessage = "Campaign ID is required")]
        public int CampaignId { get; set; }
        
        [Required(ErrorMessage = "User ID is required")]
        public int UserId { get; set; }
        
        [Required(ErrorMessage = "Donation amount is required")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Donation amount must be greater than 0")]
        public decimal Amount { get; set; }
        
        [Required(ErrorMessage = "Return URL is required")]
        public string ReturnUrl { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Cancel URL is required")]
        public string CancelUrl { get; set; } = string.Empty;
    }

}
