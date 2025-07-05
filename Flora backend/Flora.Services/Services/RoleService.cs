using Flora.Models.Requests;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using Flora.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class RoleService : BaseCRUDService<RoleResponse, RoleSearchObject, Database.Role, RoleRequest, RoleRequest>, IRoleService
    {
        public RoleService(FLoraDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Database.Role> ApplyFilter(IQueryable<Database.Role> query, RoleSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(r => r.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(r => r.Name.Contains(search.FTS) || r.Description.Contains(search.FTS));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(r => r.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Database.Role entity, RoleRequest request)
        {
            if (await _context.Roles.AnyAsync(r => r.Name == request.Name))
            {
                throw new InvalidOperationException("A role with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Database.Role entity, RoleRequest request)
        {
            if (await _context.Roles.AnyAsync(r => r.Name == request.Name && r.Id != entity.Id))
            {
                throw new InvalidOperationException("A role with this name already exists.");
            }
        }
    }
}
