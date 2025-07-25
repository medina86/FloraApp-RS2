﻿using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface ICartItemService : ICRUDService<CartItemResponse, CartItemSearchObject, CartItemRequest, CartItemRequest>
    {
        Task<CartItemResponse?> IncreaseQuantityAsync(int id);
        Task<(CartItemResponse? response, bool removed)> DecreaseQuantityAsync(int id);
    }
}
