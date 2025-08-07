class MonthlyData {
  final String month;
  final int count;

  MonthlyData({required this.month, required this.count});

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(month: json['month'] ?? '', count: json['count'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'count': count};
  }
}

class SummaryStatistics {
  final int totalOrders;
  final double totalRevenue;
  final int totalDonations;
  final double totalDonationAmount;
  final int totalReservations;
  final int totalUsers;

  SummaryStatistics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalDonations,
    required this.totalDonationAmount,
    required this.totalReservations,
    required this.totalUsers,
  });

  factory SummaryStatistics.fromJson(Map<String, dynamic> json) {
    return SummaryStatistics(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalDonations: json['totalDonations'] ?? 0,
      totalDonationAmount: (json['totalDonationAmount'] ?? 0).toDouble(),
      totalReservations: json['totalReservations'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'totalDonations': totalDonations,
      'totalDonationAmount': totalDonationAmount,
      'totalReservations': totalReservations,
      'totalUsers': totalUsers,
    };
  }
}
