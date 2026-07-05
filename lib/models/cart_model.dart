import 'dart:convert';

class CartModel {
  final String productId;
  final String name;
  final String image;
  final String color;
  final double price;
  final String size;
  final int quantity;

  CartModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.color,
    required this.price,
    required this.size,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "name": name,
      "image": image,
      "color": color,
      "price": price,
      "size": size,
      "quantity": quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map["productId"] ?? "",
      name: map["name"] ?? "",
      image: map["image"] ?? "",
      color: map["color"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      size: map["size"] ?? "",
      quantity: map["quantity"] ?? 1,
    );
  }

  CartModel copyWith({
    String? productId,
    String? name,
    String? image,
    String? color,
    double? price,
    String? size,
    int? quantity,
  }) {
    return CartModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      color: color ?? this.color,
      price: price ?? this.price,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CartModel.fromJson(String source) {
    return CartModel.fromMap(jsonDecode(source));
  }
}