using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class DonationRequest
    {
        [Required(ErrorMessage = "Donor name is required")]
        [MaxLength(100, ErrorMessage = "Donor name cannot exceed 100 characters")]
        public string DonorName { get; set; } = string.Empty;
            
        [Required(ErrorMessage = "Email je obavezan")]
        [EmailAddress(ErrorMessage = "Unesite važeću email adresu")]
        [MaxLength(100, ErrorMessage = "Email ne može biti duži od 100 karaktera")]
        [RegularExpression(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", 
            ErrorMessage = "Email adresa nije u ispravnom formatu")]
        public string Email { get; set; } = string.Empty;
            
        [Required(ErrorMessage = "Donation amount is required")]
        [Range(0.01, 10000.00, ErrorMessage = "Amount must be between 0.01 and 10,000.00")]
        public decimal Amount { get; set; }
            
        [Required(ErrorMessage = "Purpose is required")]
        public string Purpose { get; set; } = string.Empty;
            
        [Required(ErrorMessage = "Campaign ID is required")]
        public int CampaignId { get; set; }
    }
}
