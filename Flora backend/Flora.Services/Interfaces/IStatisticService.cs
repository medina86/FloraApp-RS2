using Flora.Application.Model.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Interfaces
{
    public interface IStatisticsService
    {
        Task<int> GetTotalUsers();
        Task<int> GetTotalOrders();
        Task<List<MonthlyCountResponse>> GetOrdersByMonth();
        Task<List<MonthlyCountResponse>> GetReservationsByMonth();
        Task<StatisticsSummaryResponse> GetSummary(DateTime startDate, DateTime endDate);
        Task<byte[]> GeneratePdfReport(DateTime startDate, DateTime endDate);
    }

}
