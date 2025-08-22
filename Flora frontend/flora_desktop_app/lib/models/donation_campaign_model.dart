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
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      endDate: DateTime.parse(json['endDate'] as String),
      imageUrl: json['imageUrl'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'endDate': endDate.toIso8601String(),
      'imageUrl': imageUrl,
      'totalAmount': totalAmount,
    };
  }
}
