class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  List<String> imageUrls;
  final int? categoryId;
  final String? categoryName;
  final bool isNew;
  final bool isFeatured;
  final int? occasionId;
  final String? occasionName;
  final bool active;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.imageUrls,
    this.categoryId,
    this.categoryName,
    required this.isNew,
    required this.isFeatured,
    this.occasionId,
    this.occasionName,
    required this.active,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrls:
          (json['images'] as List<dynamic>?)
              ?.map((img) => img['imageUrl'] as String)
              .toList() ??
          [],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      isNew: json['isNew'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      occasionId: json['occasionId'],
      occasionName: json['occasionName'],
      active: json['active'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    int? categoryId,
    String? categoryName,
    bool? isNew,
    bool? isFeatured,
    int? occasionId,
    String? occasionName,
    bool? active,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      occasionId: occasionId ?? this.occasionId,
      occasionName: occasionName ?? this.occasionName,
      active: active ?? this.active,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name'] ?? '');
  }
}

class Occasion {
  final int occasionId;
  final String name;

  Occasion({required this.occasionId, required this.name});

  factory Occasion.fromJson(Map<String, dynamic> json) {
    return Occasion(
      occasionId: json['occasionId'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
