using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class UserRequest
    {
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email je obavezan")]
        [MaxLength(100, ErrorMessage = "Email ne može biti duži od 100 karaktera")]
        [EmailAddress(ErrorMessage = "Molimo unesite važeću email adresu")]
        [RegularExpression(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", ErrorMessage = "Email nije u ispravnom formatu")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Korisničko ime je obavezno")]
        [MaxLength(100, ErrorMessage = "Korisničko ime ne može biti duže od 100 karaktera")]
        public string Username { get; set; } = string.Empty;

        [MaxLength(20, ErrorMessage = "Broj telefona ne može biti duži od 20 karaktera")]
        [Phone(ErrorMessage = "Molimo unesite važeći broj telefona")]
        [RegularExpression(@"^[+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{3,6}$", 
            ErrorMessage = "Broj telefona nije u ispravnom formatu. Primjeri ispravnih formata: +387 33 123 456, 033/123-456, 061123456")]
        public string? PhoneNumber { get; set; }

        public bool IsActive { get; set; } = true;

        [MinLength(6)]
        public string? Password { get; set; }

        public List<int> RoleIds { get; set; } = new List<int>();
    }
}
