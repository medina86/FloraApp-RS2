class Donation {
  final int? id;
  final String donorName;
  final String email;
  final double amount;
  final String purpose;
  final DateTime? date;
  final int campaignId;
  final int? userId;
  final String? campaignTitle;
  final String? status;

  Donation({
    this.id,
    required this.donorName,
    required this.email,
    required this.amount,
    required this.purpose,
    this.date,
    required this.campaignId,
    this.userId,
    this.campaignTitle,
    this.status,
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
      userId: json['userId'],
      campaignTitle: json['campaignTitle'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'donorName': donorName,
      'email': email,
      'amount': amount,
      'purpose': purpose,
      'campaignId': campaignId,
      'userId': userId,
      'status': status,
    };
  }
}
