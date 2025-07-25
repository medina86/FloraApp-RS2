﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Database
{
    public class OrderDetail
    {
        public int Id { get; set; }
        public int OrderId { get; set; }
        public Order Order { get; set; }

        public int ProductId { get; set; }
        public Product Product { get; set; } 

        public int Quantity { get; set; }
        public decimal PriceAtPurchase { get; set; } 
        public string? CardMessage { get; set; }
        public string? SpecialInstructions { get; set; }
    }
}
