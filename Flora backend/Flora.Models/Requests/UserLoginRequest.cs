﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Models.Requests
{
    public class UserLoginRequest
    {
        public string? Username { get; set; }
        public string? Password { get; set; }
    }
}
