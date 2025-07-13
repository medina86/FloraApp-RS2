class Category {
  final int id;
  final String name;
  final String description;
  final String? categoryImageUrl;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.categoryImageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      categoryImageUrl: json['categoryImageUrl'],
    );
  }
}
