using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Flora.Application.Model.Responses;
using System;

namespace Flora.Services.Helpers
{
    public static class PdfReportGenerator
    {
        public static byte[] Generate(StatisticsSummaryResponse summary, DateTime startDate, DateTime endDate)
        {
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(50);

                    page.Header().Text("📊 Business Report")
                        .FontSize(20).Bold().AlignCenter();

                    page.Content().Column(col =>
                    {
                        col.Spacing(10);

                        col.Item().Text($"📅 Period: {startDate:dd.MM.yyyy} - {endDate:dd.MM.yyyy}")
                            .FontSize(12);

                        col.Item().Text($"🛒 Total Orders: {summary.OrderCount}")
                            .FontSize(12);

                        col.Item().Text($"🎉 Reservations: {summary.ReservationCount}")
                            .FontSize(12);

                        col.Item().Text($"💝 Donations Collected: {summary.DonationsTotal:C}")
                            .FontSize(12);

                        col.Item().Text($"👥 New Users: {summary.NewUserCount}")
                            .FontSize(12);
                    });

                    page.Footer().AlignCenter().Text($"Generated on {DateTime.Now:dd.MM.yyyy HH:mm}");
                });
            });

            return document.GeneratePdf();
        }
    }
}
