class PayPalPaymentResponse {
  final String approvalUrl;
  final String paymentId;
  final int? cartId;
  final int? userId;

  PayPalPaymentResponse({
    required this.approvalUrl, 
    required this.paymentId,
    this.cartId,
    this.userId,
  });

  factory PayPalPaymentResponse.fromJson(Map<String, dynamic> json) {
    return PayPalPaymentResponse(
      approvalUrl: json['approvalUrl'],
      paymentId: json['paymentId'],
      cartId: json['cartId'],
      userId: json['userId'],
    );
  }
}
