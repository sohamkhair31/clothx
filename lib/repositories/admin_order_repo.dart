import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class AdminOrderRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _firestore
        .collection("orders")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromMap(
        doc.data(),
      );
    }).toList();
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _firestore
        .collection("orders")
        .doc(orderId)
        .update({
      "orderStatus": status,
    });
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _firestore
        .collection("orders")
        .doc(orderId)
        .update({
      "orderStatus": "cancelled",
    });
  }
}