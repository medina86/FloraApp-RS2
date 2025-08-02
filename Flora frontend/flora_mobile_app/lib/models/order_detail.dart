class OrderDetailModel {
  final int id;
  final int? productId; 
  final int? customBouquetId; 
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double priceAtPurchase;
  final String? cardMessage; 
  final String? specialInstructions; 

  OrderDetailModel({
    required this.id,
    this.productId, 
    this.customBouquetId, 
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.priceAtPurchase,
    this.cardMessage,  
    this.specialInstructions,  
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      productId: json['productId'],  
      customBouquetId: json['customBouquetId'], 
      productName: json['productName'] ?? '',
      productImageUrl: json['productImageUrl'],
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: (json['priceAtPurchase'] ?? 0).toDouble(),
      cardMessage: json['cardMessage'],  
      specialInstructions: json['specialInstructions'],  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'customBouquetId': customBouquetId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
      'cardMessage': cardMessage,
      'specialInstructions': specialInstructions,
    };
  }

  bool get isCustomBouquet => customBouquetId != null;
  bool get isRegularProduct => productId != null;
}