using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.SearchObjects
{
    public class DecorationSelectionSearchObject : BaseSearchObject
    {
        public int? DecorationRequestId { get; set; }
        public int? UserId { get; set; }
        public int? DecorationSuggestionId { get; set; }
        public string? Status { get; set; }
    }
}
