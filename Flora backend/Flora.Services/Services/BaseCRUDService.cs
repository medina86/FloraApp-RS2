using eCommerce.Services;
using Flora.Models.SearchObjects;
using Flora.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public abstract class BaseCRUDService<T, TSearch, TEntity, TInsert, TUpdate>
   : BaseService<T, TSearch, TEntity> where T : class where TSearch : BaseSearchObject where TEntity : class, new() where TInsert : class where TUpdate : class
    {
        protected readonly FLoraDbContext _context;

        public BaseCRUDService(FLoraDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }


        public virtual async Task<T> CreateAsync(TInsert request)
        {
            var entity = new TEntity();
            MapInsertToEntity(entity, request);
            _context.Set<TEntity>().Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeInsert(TEntity entity, TInsert request)
        {

        }


        protected virtual TEntity MapInsertToEntity(TEntity entity, TInsert request)
        {
            return _mapper.Map(request, entity);
        }

        public virtual async Task<T?> UpdateAsync(int id, TUpdate request)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        protected virtual async Task BeforeUpdate(TEntity entity, TUpdate request)
        {

        }

        protected virtual void MapUpdateToEntity(TEntity entity, TUpdate request)
        {
            _mapper.Map(request, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var entity = await _context.Set<TEntity>().FindAsync(id);
            if (entity == null)
                return false;

            await BeforeDelete(entity);

            _context.Set<TEntity>().Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

        protected virtual async Task BeforeDelete(TEntity entity)
        {

        }
    }
}