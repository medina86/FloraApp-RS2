using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? Email { get; set; }
    }
}
