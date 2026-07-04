import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= PLACE ORDER =================
  Future<void> placeOrder(
    OrderModel order,
  ) async {
    await _firestore.runTransaction(
      (transaction) async {
        // Validate stock + reduce stock
        for (var item in order.items) {
          final productRef =
              _firestore
                  .collection("products")
                  .doc(item.productId);

          final productDoc =
              await transaction.get(
            productRef,
          );

          if (!productDoc.exists) {
            throw Exception(
              "Product not found: ${item.name}",
            );
          }

          final currentStock =
              productDoc["stock"] ?? 0;

          if (item.quantity >
              currentStock) {
            throw Exception(
              "Not enough stock for ${item.name}",
            );
          }

          transaction.update(
            productRef,
            {
              "stock":
                  currentStock -
                  item.quantity,
              "updatedAt":
                  FieldValue.serverTimestamp(),
            },
          );
        }

        // Save order
        final orderRef =
            _firestore
                .collection("orders")
                .doc(order.orderId);

        transaction.set(
          orderRef,
          order.toFirestoreMap(),
        );

        // Update user-specific meta
        final metaRef =
            _firestore
                .collection("app_meta")
                .doc(
                  "orders_${order.userId}",
                );

        transaction.set(metaRef, {
          "lastUpdated":
              FieldValue.serverTimestamp(),
        });
      },
    );
  }

  // ================= FETCH USER ORDERS =================
  Future<List<OrderModel>> fetchOrders(
    String userId, {
    int limit = 20,
  }) async {
    final snapshot =
        await _firestore
            .collection("orders")
            .where(
              "userId",
              isEqualTo: userId,
            )
            .orderBy(
              "createdAt",
              descending: true,
            )
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromMap(
        doc.data(),
      );
    }).toList();
  }

  // ================= GET USER META =================
  Future<String> getOrdersMeta(
    String userId,
  ) async {
    final doc =
        await _firestore
            .collection("app_meta")
            .doc(
              "orders_$userId",
            )
            .get();

    if (!doc.exists) {
      return "";
    }

    final timestamp =
        doc["lastUpdated"]
            as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }
}