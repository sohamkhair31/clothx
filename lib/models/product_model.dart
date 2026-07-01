import 'dart:convert';
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final List<String> sizes;
  final int stock;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.sizes,
    required this.stock,
    required this.category,
  });

  // Convert object -> Map (for Firebase/Hive)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "images": images,
      "sizes": sizes,
      "stock": stock,
      "category": category,
    };
  }

  // Convert Map -> Object
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      images: List<String>.from(map["images"] ?? []),
      sizes: List<String>.from(map["sizes"] ?? []),
      stock: map["stock"] ?? 0,
      category: map["category"] ?? "",
    );
  }

  // JSON helpers
  String toJson() => jsonEncode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(jsonDecode(source));
}