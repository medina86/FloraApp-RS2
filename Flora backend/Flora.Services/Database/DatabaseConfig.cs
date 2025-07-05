using Flora.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace eCommerce.Services.Database
{
    public static class DatabaseConfig
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<FLoraDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseEComm(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<FLoraDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}