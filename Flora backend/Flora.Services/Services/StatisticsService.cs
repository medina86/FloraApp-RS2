using Flora.Application.Model.Responses;
using Flora.Services.Database;
using Microsoft.EntityFrameworkCore;
using Flora.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Flora.Services.Helpers;

namespace Flora.Services.Services
{
    public class StatisticsService : IStatisticsService
    {
        private readonly FLoraDbContext _context;

        public StatisticsService(FLoraDbContext context)
        {
            _context = context;
        }

        public async Task<int> GetTotalUsers()
            => await _context.Users.CountAsync();

        public async Task<int> GetTotalOrders()
            => await _context.Orders.CountAsync();

        public async Task<List<MonthlyCountResponse>> GetOrdersByMonth()
        {
            return await _context.Orders
                .GroupBy(o => new { o.OrderDate.Year, o.OrderDate.Month })
                .Select(g => new MonthlyCountResponse
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1),
                    Count = g.Count()
                })
                .ToListAsync();
        }

        public async Task<List<MonthlyCountResponse>> GetReservationsByMonth()
        {
            return await _context.DecorationRequests
                .GroupBy(r => new { r.EventDate.Year, r.EventDate.Month })
                .Select(g => new MonthlyCountResponse
                {
                    Month = new DateTime(g.Key.Year, g.Key.Month, 1),
                    Count = g.Count()
                })
                .ToListAsync();
        }

        public async Task<StatisticsSummaryResponse> GetSummary(DateTime startDate, DateTime endDate)
        {
            return new StatisticsSummaryResponse
            {
                OrderCount = await _context.Orders
                    .CountAsync(o => o.OrderDate >= startDate && o.OrderDate <= endDate),
                ReservationCount = await _context.DecorationRequests
                    .CountAsync(r => r.EventDate >= startDate && r.EventDate <= endDate),
                DonationsTotal = await _context.Donations
                    .Where(d => d.Date >= startDate && d.Date <= endDate)
                    .SumAsync(d => (decimal?)d.Amount) ?? 0,
                NewUserCount = await _context.Users
                    .CountAsync(u => u.CreatedAt >= startDate && u.CreatedAt <= endDate)
            };
        }

        public async Task<byte[]> GeneratePdfReport(DateTime startDate, DateTime endDate)
        {
            var summary = await GetSummary(startDate, endDate);

            var pdfBytes = PdfReportGenerator.Generate(summary, startDate, endDate);
            return pdfBytes;
        }
    }

}
