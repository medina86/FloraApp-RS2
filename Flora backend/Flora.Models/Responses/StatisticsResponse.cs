using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


    namespace Flora.Application.Model.Responses
    {
        public class MonthlyCountResponse
        {
            public DateTime Month { get; set; }
            public int Count { get; set; }
        }

        public class StatisticsSummaryResponse
        {
            public int OrderCount { get; set; }
            public int ReservationCount { get; set; }
            public decimal DonationsTotal { get; set; }
            public int NewUserCount { get; set; }
        }
    }


