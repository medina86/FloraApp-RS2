using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class FavoriteRequest
    {
        public int UserId { get; set; }
        public int ProductId { get; set; }
    }

}
