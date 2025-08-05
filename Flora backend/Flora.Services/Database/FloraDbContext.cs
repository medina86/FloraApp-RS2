using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;
using Flora.Services.Database.Seeders;

namespace Flora.Services.Database
{
    public class FLoraDbContext : DbContext
    {
        public FLoraDbContext(DbContextOptions<FLoraDbContext> options) : base(options)
        {
        }
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Categories> Categories { get; set; }
        public DbSet<Product>Products { get; set; }
        public DbSet<ProductImages>ProductImages { get; set; }
        public DbSet<Occasion> Occasions {  get; set; }
        public DbSet<Favorite> Favorites { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<Cart> Carts { get; set; }
        public DbSet<ShippingAddress> ShippingAddresses { get; set; }
        public DbSet<OrderDetail>OrderDetails { get; set; }
        public DbSet<Order>Orders { get; set; }
        public DbSet<CustomBouquetItem> CustomBouquetItems { get; set; }
        public DbSet<CustomBouquet>CustomBouquets { get; set; }
        public DbSet<DecorationRequest> DecorationRequests { get; set; }
        public DbSet<DecorationSuggestion> DecorationSuggestions { get; set; }
        public DbSet<Donation>Donations { get; set; }
        public DbSet<DonationCampaign>DonationCampaigns { get; set; }
        public DbSet<BlogComment> BlogComments { get; set; }
        public DbSet<BlogPost> BlogPosts { get; set; }
        public DbSet<BlogImage> BlogImages { get; set; }







        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Seeding data
            modelBuilder.Entity<Categories>().SeedData();
            modelBuilder.Entity<Occasion>().SeedData();
            modelBuilder.Entity<Role>().SeedData();
            modelBuilder.Entity<User>().SeedData();
            modelBuilder.Entity<UserRole>().SeedData();
            modelBuilder.Entity<Product>().SeedData();
            modelBuilder.Entity<ProductImages>().SeedData();
            modelBuilder.Entity<BlogPost>().SeedData();
            modelBuilder.Entity<BlogImage>().SeedData();
            modelBuilder.Entity<BlogComment>().SeedData();
            modelBuilder.Entity<DonationCampaign>().SeedData();
            modelBuilder.Entity<Donation>().SeedData();
            modelBuilder.Entity<DecorationRequest>().SeedData();
            modelBuilder.Entity<DecorationSuggestion>().SeedData();
            modelBuilder.Entity<ShippingAddress>().SeedData();
            modelBuilder.Entity<Order>().SeedData();
            modelBuilder.Entity<OrderDetail>().SeedData();
            modelBuilder.Entity<CustomBouquet>().SeedData();
            modelBuilder.Entity<CustomBouquetItem>().SeedData();
            modelBuilder.Entity<Cart>().SeedData();
            modelBuilder.Entity<CartItem>().SeedData();
            modelBuilder.Entity<Favorite>().SeedData();
            
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();
            modelBuilder.Entity<Order>()
                .Property(o => o.Status)
                .HasConversion<string>();
           
        }
    }
    }

