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
      donorName: json['donorName'] as String,
      email: json['email'] as String,
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      date: DateTime.parse(json['date'] as String),
      campaignId: json['campaignId'] as int,
      campaignTitle: json['campaignTitle'] as String,
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
