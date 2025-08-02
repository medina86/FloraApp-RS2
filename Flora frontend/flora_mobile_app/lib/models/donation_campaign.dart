class DonationCampaign {
  final int id;
  final String title;
  final String description;
  final DateTime endDate;
  final String? imageUrl;
  final double totalAmount;

  DonationCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.endDate,
    this.imageUrl,
    required this.totalAmount,
  });

  factory DonationCampaign.fromJson(Map<String, dynamic> json) {
    return DonationCampaign(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      endDate: DateTime.parse(json['endDate']),
      imageUrl: json['imageUrl'],
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
    );
  }
}
