class OrderDetailModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double priceAtPurchase;
  final String cardMessage;
  final String specialInstructions;

  OrderDetailModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.priceAtPurchase,
    required this.cardMessage,
    required this.specialInstructions,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'],
      quantity: json['quantity'],
      priceAtPurchase: json['priceAtPurchase']?.toDouble(),
      cardMessage: json['cardMessage'],
      specialInstructions: json['specialInstructions'],
    );
  }
  
}