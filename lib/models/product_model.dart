import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductColor {
  final String name;
  final String image;

  ProductColor({
    required this.name,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "image": image,
    };
  }

  factory ProductColor.fromMap(Map<String, dynamic> map) {
    return ProductColor(
      name: map["name"] ?? "",
      image: map["image"] ?? "",
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ProductColor.fromJson(String source) =>
      ProductColor.fromMap(jsonDecode(source));
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;

  /// One image for each color
  final List<ProductColor> colors;

  /// Same sizes for all colors
  final List<String> sizes;

  final int stock;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String gender;
  final bool isActive;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.colors,
    required this.sizes,
    required this.stock,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.gender,
    required this.isActive,
  });

  // Hive Cache Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "colors": colors.map((e) => e.toMap()).toList(),
      "sizes": sizes,
      "stock": stock,
      "category": category,
      "gender": gender,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "isActive": isActive,
    };
  }

  // Firestore Map
  Map<String, dynamic> toFirestoreMap() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "price": price,
      "colors": colors.map((e) => e.toMap()).toList(),
      "sizes": sizes,
      "stock": stock,
      "category": category,
      "gender": gender,
      "createdAt": Timestamp.fromDate(createdAt),
      "updatedAt": Timestamp.fromDate(updatedAt),
      "isActive": isActive,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      price: (map["price"] ?? 0).toDouble(),

      colors: (map["colors"] as List? ?? [])
          .map(
            (e) => ProductColor.fromMap(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),

      sizes: List<String>.from(map["sizes"] ?? []),

      stock: map["stock"] ?? 0,
      category: map["category"] ?? "",
      gender: map["gender"] ?? "unisex",
      isActive: map["isActive"] ?? true,

      createdAt: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : DateTime.parse(map["createdAt"]),

      updatedAt: map["updatedAt"] is Timestamp
          ? (map["updatedAt"] as Timestamp).toDate()
          : DateTime.parse(map["updatedAt"]),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<ProductColor>? colors,
    List<String>? sizes,
    int? stock,
    String? category,
    String? gender,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(jsonDecode(source));
}