import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Place order
Future<void> placeOrder(OrderModel order) async {
  // Validate stock first
  for (var item in order.items) {
    final productDoc = await _firestore
        .collection("products")
        .doc(item.productId)
        .get();

    if (!productDoc.exists) {
      throw Exception(
        "Product not found: ${item.name}",
      );
    }

    final currentStock =
        productDoc["stock"] ?? 0;

    if (item.quantity > currentStock) {
      throw Exception(
        "Not enough stock for ${item.name}",
      );
    }
  }

  // Save order
  await _firestore
      .collection("orders")
      .doc(order.orderId)
      .set(order.toMap());

  // Reduce stock
  await _reduceStock(order);
}
  // Reduce stock
  Future<void> _reduceStock(OrderModel order) async {
    final batch = _firestore.batch();

    for (var item in order.items) {
      final productRef = _firestore
          .collection("products")
          .doc(item.productId);

      final productDoc = await productRef.get();

      if (productDoc.exists) {
        final currentStock =
            productDoc["stock"] ?? 0;

        final newStock =
            currentStock - item.quantity;

        batch.update(productRef, {
          "stock": newStock < 0 ? 0 : newStock,
          "updatedAt":
              DateTime.now().toIso8601String(),
        });
      }
    }

    await batch.commit();
  }

  // Fetch user orders
  Future<List<OrderModel>> fetchOrders(
    String userId,
  ) async {
    final snapshot = await _firestore
        .collection("orders")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromMap(doc.data());
    }).toList();
  }
}