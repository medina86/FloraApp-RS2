class OrderDetailModel {
  final int id;
  final int? productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final double priceAtPurchase;
  final String? cardMessage;
  final String? specialInstructions;
  final int? customBouquetId;
  final List<CustomBouquetComponent>? customBouquetComponents;

  OrderDetailModel({
    required this.id,
    this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.priceAtPurchase,
    this.cardMessage,
    this.specialInstructions,
    this.customBouquetId,
    this.customBouquetComponents,
  });

  bool get isCustomBouquet =>
      productName.toLowerCase().contains('custom bouquet');

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    List<CustomBouquetComponent>? components;

    // Debug print da vidimo što backend šalje
    print('DEBUG - OrderDetail JSON: $json');
    if (json['productName']?.toString().toLowerCase().contains('custom') ==
        true) {
      print('DEBUG - Custom bouquet detected!');
      print('DEBUG - customBouquetId: ${json['customBouquetId']}');
      print('DEBUG - specialInstructions: ${json['specialInstructions']}');
      print(
        'DEBUG - customBouquetComponents: ${json['customBouquetComponents']}',
      );
    }

    // Pokušaj parsirati custom bouquet komponente
    if (json['customBouquetComponents'] != null) {
      components = (json['customBouquetComponents'] as List)
          .map((item) => CustomBouquetComponent.fromJson(item))
          .toList();
    } else if (json['specialInstructions'] != null) {
      // Fallback - pokušaj parsirati iz specialInstructions ako je JSON format
      try {
        final decoded = json['specialInstructions'];
        if (decoded is List) {
          components = decoded
              .map((item) => CustomBouquetComponent.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('DEBUG - Error parsing specialInstructions: $e');
      }
    }

    return OrderDetailModel(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'],
      quantity: json['quantity'],
      priceAtPurchase: json['priceAtPurchase']?.toDouble(),
      cardMessage: json['cardMessage'],
      specialInstructions: json['specialInstructions'],
      customBouquetId: json['customBouquetId'],
      customBouquetComponents: components,
    );
  }
}

class CustomBouquetComponent {
  final String flowerType;
  final String color;
  final int quantity;
  final double price;

  CustomBouquetComponent({
    required this.flowerType,
    required this.color,
    required this.quantity,
    required this.price,
  });

  factory CustomBouquetComponent.fromJson(Map<String, dynamic> json) {
    return CustomBouquetComponent(
      flowerType: json['flowerType'] ?? json['name'] ?? 'Unknown',
      color: json['color'] ?? 'Unknown',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}
