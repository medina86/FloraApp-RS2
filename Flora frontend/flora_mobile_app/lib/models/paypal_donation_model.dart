class PayPalDonationRequest {
  final int userId;
  final int campaignId;
  final double amount;
  final String returnUrl;
  final String cancelUrl;
  final String status;
  final String? transactionId;

  PayPalDonationRequest({
    required this.userId,
    required this.campaignId,
    required this.amount,
    required this.returnUrl,
    required this.cancelUrl,
    this.status = 'Pending',
    this.transactionId,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'campaignId': campaignId,
    'amount': amount,
    'returnUrl': returnUrl,
    'cancelUrl': cancelUrl,
    'status': status,
    'transactionId': transactionId,
  };
}

class PayPalDonationResponse {
  final int id;
  final int userId;
  final int campaignId;
  final double amount;
  final String status;
  final String paymentUrl;
  final String? transactionId;

  PayPalDonationResponse({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.amount,
    required this.status,
    required this.paymentUrl,
    this.transactionId,
  });

  factory PayPalDonationResponse.fromJson(Map<String, dynamic> json) {
    return PayPalDonationResponse(
      id: json['id'],
      userId: json['userId'],
      campaignId: json['campaignId'],
      amount: json['amount']?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Unknown',
      paymentUrl: json['paymentUrl'] ?? '',
      transactionId: json['transactionId'],
    );
  }
}
