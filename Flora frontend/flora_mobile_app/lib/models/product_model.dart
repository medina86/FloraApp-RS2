class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  List<String> imageUrls;
  final bool isNew;
  final bool isFeatured;
  final bool active;
  final bool isAvailable;
  final int? occasionId;
  final String? occasionName;
  final int? categoryId;
  final String? categoryName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrls,
    required this.isNew,
    required this.isFeatured,
    required this.active,
    required this.isAvailable,
    this.occasionId,
    this.occasionName,
    this.categoryId,
    this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '', 
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']) 
          : [],
      isNew: json['isNew'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      active: json['active'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
      occasionId: json['occasionId'],
      occasionName: json['occasionName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'isNew': isNew,
      'isFeatured': isFeatured,
      'active': active,
      'isAvailable': isAvailable,
      'occasionId': occasionId,
      'occasionName': occasionName,
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
}
