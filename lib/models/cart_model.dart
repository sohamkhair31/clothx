import 'dart:convert';
class CartModel {
  final String productId;
  final String size;
  final int quantity;

  CartModel({
    required this.productId,
    required this.size,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "size": size,
      "quantity": quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map["productId"] ?? "",
      size: map["size"] ?? "",
      quantity: map["quantity"] ?? 1,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CartModel.fromJson(String source) =>
      CartModel.fromMap(jsonDecode(source));
}