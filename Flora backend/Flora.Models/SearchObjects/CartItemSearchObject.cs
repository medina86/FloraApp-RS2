using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class CartItemSearchObject : BaseSearchObject
    {
        public int? CartId { get; set; }
        public int? ProductId { get; set; }
    }

}
