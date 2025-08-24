using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;

namespace Flora.Services.Database.Seeders
{
    public static class OrderSeeder
    {
        public static void SeedData(this EntityTypeBuilder<Order> entity)
        {
            entity.HasData(
                new Order
                {
                    Id = 1,
                    UserId = 2,
                    OrderDate = new DateTime(2025, 7, 1),
                    TotalAmount = 135.00m,
                    Status = OrderStatus.Completed,
                    ShippingAddressId = 1
                },
                new Order
                {
                    Id = 2,
                    UserId = 3,
                    OrderDate = new DateTime(2025, 7, 5),
                    TotalAmount = 80.00m,
                    Status = OrderStatus.Delivered,
                    ShippingAddressId = 2
                },
                new Order
                {
                    Id = 3,
                    UserId = 3,
                    OrderDate = new DateTime(2025, 7, 10),
                    TotalAmount = 50.00m,
                    Status = OrderStatus.Processed,
                    ShippingAddressId = 3
                },
                new Order
                {
                    Id = 4,
                    UserId = 2,
                    OrderDate = new DateTime(2025, 7, 15),
                    TotalAmount = 100.00m,
                    Status = OrderStatus.Processed,
                    ShippingAddressId = 4
                }
            );
        }
    }
}
