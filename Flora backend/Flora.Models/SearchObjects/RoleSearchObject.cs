using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class RoleSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public bool? IsActive { get; set; }
    }
}
