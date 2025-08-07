using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class ShippingAddressRequest
    {
        [Required(ErrorMessage = "First name is required")]
        [MaxLength(100, ErrorMessage = "First name cannot exceed 100 characters")]
        public string FirstName { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Last name is required")]
        [MaxLength(100, ErrorMessage = "Last name cannot exceed 100 characters")]
        public string LastName { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "City is required")]
        [MaxLength(100, ErrorMessage = "City cannot exceed 100 characters")]
        public string City { get; set; } = string.Empty;
        
        [MaxLength(100, ErrorMessage = "Street cannot exceed 100 characters")]
        public string? Street { get; set; }
        
        [MaxLength(20, ErrorMessage = "House number cannot exceed 20 characters")]
        public string? HouseNumber { get; set; }
        
        [Required(ErrorMessage = "Postal code is required")]
        [MaxLength(20, ErrorMessage = "Postal code cannot exceed 20 characters")]
        public string PostalCode { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "Broj telefona je obavezan")]
        [MaxLength(20, ErrorMessage = "Broj telefona ne može biti duži od 20 karaktera")]
        [Phone(ErrorMessage = "Unesite važeći broj telefona")]
        [RegularExpression(@"^[+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3,6}$", 
            ErrorMessage = "Broj telefona nije u ispravnom formatu. Primjeri ispravnih formata: +387 33 123 456, 033/123-456, 061123456")]
        public string PhoneNumber { get; set; } = string.Empty;
        
        public string? OrderNote { get; set; }
    }
}
