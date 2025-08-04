using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IBlogPostService : ICRUDService<BlogPostResponse, BlogPostSearchObject, BlogPostRequest, BlogPostRequest> {
       
    }
}
