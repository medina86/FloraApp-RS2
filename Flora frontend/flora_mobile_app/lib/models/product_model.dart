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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls']),
      isNew: json['isNew'],
      isFeatured: json['isFeatured'],
      active: json['active'],
      isAvailable: json['isAvailable'],
    );
  }
}
