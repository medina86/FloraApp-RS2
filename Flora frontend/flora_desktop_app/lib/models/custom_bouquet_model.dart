class CustomBouquetModel {
  final int id;
  final String color;
  final String? cardMessage;
  final String? specialInstructions;
  final double totalPrice;
  final List<CustomBouquetItemModel> items;

  CustomBouquetModel({
    required this.id,
    required this.color,
    this.cardMessage,
    this.specialInstructions,
    required this.totalPrice,
    required this.items,
  });

  factory CustomBouquetModel.fromJson(Map<String, dynamic> json) {
    return CustomBouquetModel(
      id: json['id'] as int,
      color: json['color'] as String,
      cardMessage: json['cardMessage'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List? ?? [])
          .map((item) => CustomBouquetItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CustomBouquetItemModel {
  final int productId;
  final String productName;
  final int quantity;

  CustomBouquetItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory CustomBouquetItemModel.fromJson(Map<String, dynamic> json) {
    return CustomBouquetItemModel(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
