﻿
using System.Linq;
using System;
using Mapster ;
using Flora.Models.Responses;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using MapsterMapper;
using Flora.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Flora.Services
{
    public abstract class BaseService<T, TSearch, TEntity> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TEntity : class
    {
        private readonly FLoraDbContext _context;
        protected readonly IMapper _mapper;

        public BaseService(FLoraDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<PagedResult<T>> GetAsync(TSearch search)
        {
            var query = _context.Set<TEntity>().AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }



            var list = await query.ToListAsync();
            return new PagedResult<T>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
        {
            return query;
        }

        public virtual async Task<T?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    

        protected virtual T MapToResponse(TEntity entity)
        {
            return _mapper.Map<T>(entity);
        }

    }
}