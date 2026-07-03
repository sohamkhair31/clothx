import 'dart:convert';

class CartModel {
  final String productId;
  final String name;
  final String image;
  final double price;
  final String size;
  final int quantity;

  CartModel({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.size,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "name": name,
      "image": image,
      "price": price,
      "size": size,
      "quantity": quantity,
    };
  }

  factory CartModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CartModel(
      productId:
          map["productId"] ?? "",
      name: map["name"] ?? "",
      image: map["image"] ?? "",
      price:
          (map["price"] ?? 0)
              .toDouble(),
      size: map["size"] ?? "",
      quantity:
          map["quantity"] ?? 1,
    );
  }

  // ================= COPY WITH =================
  CartModel copyWith({
    String? productId,
    String? name,
    String? image,
    double? price,
    String? size,
    int? quantity,
  }) {
    return CartModel(
      productId:
          productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      size: size ?? this.size,
      quantity:
          quantity ?? this.quantity,
    );
  }

  // ================= JSON =================
  String toJson() =>
      jsonEncode(toMap());

  factory CartModel.fromJson(
    String source,
  ) {
    return CartModel.fromMap(
      jsonDecode(source),
    );
  }
}