
class CartModel {
  final int id;
  final int userId;
  final DateTime createdAt;
  final double totalAmount;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.totalAmount,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items: json['items'] != null
          ? List<CartItemModel>.from(
              json['items'].map((item) => CartItemModel.fromJson(item)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  double calculateTotalAmount() {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  int getTotalItemCount() {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartItemModel {
  final int id;
  final int cartId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final int? customBouquetId;
  final String? cardMessage;
  final String? specialInstructions;
  final String? imageUrl;

  CartItemModel({
    required this.id,
    required this.cartId,
    this.customBouquetId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.cardMessage,
    this.specialInstructions,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      cartId: json['cartId'] ?? 0,
      productId: json['productId'] ?? 0,
      customBouquetId: json['customBouquetId'],
      productName: json['productName'] ?? 'Unknown Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
      cardMessage: json['cardMessage'],
      specialInstructions: json['specialInstructions'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'productId': productId,
      'customBouquetId': customBouquetId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'cardMessage': cardMessage,
      'specialInstructions': specialInstructions,
      'imageUrl': imageUrl,
    };
  }

  double getTotalPrice() {
    return price * quantity;
  }

  CartItemModel copyWith({
    int? id,
    int? cartId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    int? customBouquetId,
    String? cardMessage,
    String? specialInstructions,
    String? imageUrl,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      customBouquetId: customBouquetId ?? this.customBouquetId,
      cardMessage: cardMessage ?? this.cardMessage,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}