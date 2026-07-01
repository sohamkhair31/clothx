import 'dart:convert';
import 'cart_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartModel> items;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "userId": userId,
      "items": items.map((e) => e.toMap()).toList(),
      "totalAmount": totalAmount,
      "paymentStatus": paymentStatus,
      "orderStatus": orderStatus,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"] ?? "",
      userId: map["userId"] ?? "",
      items: List<CartModel>.from(
        (map["items"] ?? []).map((x) => CartModel.fromMap(x)),
      ),
      totalAmount: (map["totalAmount"] ?? 0).toDouble(),
      paymentStatus: map["paymentStatus"] ?? "",
      orderStatus: map["orderStatus"] ?? "",
    );
  }

  String toJson() => jsonEncode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(jsonDecode(source));
}