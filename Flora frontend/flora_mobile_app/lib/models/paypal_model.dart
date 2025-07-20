class PayPalPaymentResponse {
  final String approvalUrl;
  final String paymentId;

  PayPalPaymentResponse({required this.approvalUrl, required this.paymentId});

  factory PayPalPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PayPalPaymentResponse(
      approvalUrl: json['approvalUrl'],
      paymentId: json['paymentId'],
    );
  }
}
