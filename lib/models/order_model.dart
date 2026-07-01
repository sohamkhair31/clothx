import 'dart:convert';

import 'cart_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartModel> items;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "userId": userId,
      "items": items.map((e) => e.toMap()).toList(),
      "totalAmount": totalAmount,
      "paymentStatus": paymentStatus,
      "orderStatus": orderStatus,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"] ?? "",
      userId: map["userId"] ?? "",
      items: List<CartModel>.from(
        (map["items"] ?? []).map(
          (x) => CartModel.fromMap(Map<String, dynamic>.from(x)),
        ),
      ),
      totalAmount: (map["totalAmount"] ?? 0).toDouble(),
      paymentStatus:
    (map["paymentStatus"] ?? "").toString().toLowerCase(),
      orderStatus:
    (map["orderStatus"] ?? "").toString().toLowerCase(),
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
OrderModel copyWith({
  String? orderId,
  String? userId,
  List<CartModel>? items,
  double? totalAmount,
  String? paymentStatus,
  String? orderStatus,
  DateTime? createdAt,
}) {
  return OrderModel(
    orderId: orderId ?? this.orderId,
    userId: userId ?? this.userId,
    items: items ?? this.items,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    orderStatus: orderStatus ?? this.orderStatus,
    createdAt: createdAt ?? this.createdAt,
  );
}
  String toJson() => jsonEncode(toMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(jsonDecode(source));
}