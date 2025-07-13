import 'package:flora_mobile_app/models/product_model.dart';

class FavoriteProduct {
  final int favoriteId; 
  final int productId;
  final String? productName;
  final String? description;
  final double price;
  final List<String> imageUrls;

  FavoriteProduct({
    required this.favoriteId, 
    required this.productId,
    this.productName,
    this.description,
    required this.price,
    required this.imageUrls,
  });

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) {
    return FavoriteProduct(
      favoriteId: json['favoriteId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']) 
          : [],
    );
  }

  // Convert to Product model for navigation
  Product toProduct() {
    return Product(
      id: productId,
      name: productName ?? 'Unknown Product',
      description: description ?? '',
      price: price,
      imageUrls: imageUrls,
      isNew: false,
      isFeatured: false,
      active: true,
      isAvailable: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': favoriteId,
      'productId': productId,
      'productName': productName,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
    };
  }
}
