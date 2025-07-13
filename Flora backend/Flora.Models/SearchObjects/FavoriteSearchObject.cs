using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class FavoriteSearchObject : BaseSearchObject
    {
        public string? ProductName {  get; set; }
        public int? UserId { get; set; }
    }
}
