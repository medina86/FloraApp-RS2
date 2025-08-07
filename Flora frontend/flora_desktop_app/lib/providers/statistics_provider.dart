import 'dart:typed_data';
import 'package:flora_desktop_app/models/statistics_model.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';
import 'package:flora_desktop_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class StatisticsApiService {
  // Get total users count
  static Future<int> getTotalUsers() async {
    return await BaseApiService.get<int>(
      '/Statistics/total-users',
      (data) => data as int,
    );
  }

  // Get total orders count
  static Future<int> getTotalOrders() async {
    return await BaseApiService.get<int>(
      '/Statistics/total-orders',
      (data) => data as int,
    );
  }

  // Get orders by month for chart
  static Future<List<MonthlyData>> getOrdersByMonth() async {
    return await BaseApiService.get<List<MonthlyData>>(
      '/Statistics/orders-by-month',
      (data) {
        final List<dynamic> list = data as List<dynamic>;
        return list.map((item) => MonthlyData.fromJson(item)).toList();
      },
    );
  }

  // Get reservations by month for chart
  static Future<List<MonthlyData>> getReservationsByMonth() async {
    return await BaseApiService.get<List<MonthlyData>>(
      '/Statistics/reservations-by-month',
      (data) {
        final List<dynamic> list = data as List<dynamic>;
        return list.map((item) => MonthlyData.fromJson(item)).toList();
      },
    );
  }

  // Get summary statistics for a date range
  static Future<SummaryStatistics> getSummary(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await BaseApiService.getWithParams<SummaryStatistics>(
      '/Statistics/summary',
      {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
      (data) => SummaryStatistics.fromJson(data),
    );
  }

  // Generate and download PDF report
  static Future<Uint8List> generateReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final queryParams = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final url =
        'http://localhost:5014/api/Statistics/generate-report?$queryString';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        ...AuthProvider.getHeaders(), // Use proper authentication
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to generate report: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
