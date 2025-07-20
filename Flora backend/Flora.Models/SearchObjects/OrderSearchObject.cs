using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public int? UserId {  get; set; }     
        public string? Status { get; set; }
    }
}
