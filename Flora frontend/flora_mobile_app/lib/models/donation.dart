class Donation {
  final int? id;
  final String donorName;
  final String email;
  final double amount;
  final String purpose;
  final DateTime? date;
  final int campaignId;
  final String? campaignTitle;

  Donation({
    this.id,
    required this.donorName,
    required this.email,
    required this.amount,
    required this.purpose,
    this.date,
    required this.campaignId,
    this.campaignTitle,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      donorName: json['donorName'],
      email: json['email'],
      amount: json['amount']?.toDouble() ?? 0.0,
      purpose: json['purpose'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      campaignId: json['campaignId'],
      campaignTitle: json['campaignTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donorName': donorName,
      'email': email,
      'amount': amount,
      'purpose': purpose,
      'campaignId': campaignId,
    };
  }
}
