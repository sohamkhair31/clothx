import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class AdminOrderRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= GET ALL ORDERS =================
  Future<List<OrderModel>> getAllOrders({
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection("orders")
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

  // ================= GET META =================
  Future<String> getOrdersMeta() async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("admin_orders")
        .get();

    if (!doc.exists) {
      return "";
    }

    final timestamp =
        doc["lastUpdated"] as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }

  // ================= UPDATE ORDER STATUS =================
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

    // update admin meta
    await _firestore
        .collection("app_meta")
        .doc("admin_orders")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= CANCEL ORDER =================
  Future<void> cancelOrder(
    String orderId,
  ) async {
    await updateOrderStatus(
      orderId: orderId,
      status: "cancelled",
    );
  }
}