class Donation {
  final int id;
  final String donorName;
  final String email;
  final double amount;
  final String purpose;
  final DateTime date;
  final int campaignId;
  final String campaignTitle;

  Donation({
    required this.id,
    required this.donorName,
    required this.email,
    required this.amount,
    required this.purpose,
    required this.date,
    required this.campaignId,
    required this.campaignTitle,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as int,
      donorName: json['donorName'] as String? ?? 'Anonymous',
      email: json['email'] as String? ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      purpose: json['purpose'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      campaignId: json['campaignId'] as int,
      campaignTitle: json['campaignTitle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorName': donorName,
      'email': email,
      'amount': amount,
      'purpose': purpose,
      'date': date.toIso8601String(),
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
    };
  }
}
