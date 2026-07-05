import 'package:clothx/core/services/cache/cache_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

class OrderRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int orderLimit = 20;

  // ================= PLACE ORDER =================

  Future<void> placeOrder(
    OrderModel order,
  ) async {
    await _firestore.runTransaction(
      (transaction) async {
        // -------------------------
        // STEP 1 : Validate Stock
        // -------------------------

        final Map<DocumentReference, int> stockUpdates =
            {};

        for (final item in order.items) {
          final productRef = _firestore
              .collection("products")
              .doc(item.productId);

          final productDoc =
              await transaction.get(productRef);

          if (!productDoc.exists) {
            throw Exception(
              "${item.name} no longer exists.",
            );
          }

          final data = productDoc.data()!;

          final bool isActive =
              data["isActive"] ?? true;

          if (!isActive) {
            throw Exception(
              "${item.name} is unavailable.",
            );
          }

          final int stock =
              data["stock"] ?? 0;

          if (stock < item.quantity) {
            throw Exception(
              "Only $stock ${item.name} left in stock.",
            );
          }

          stockUpdates[productRef] =
              stock - item.quantity;
        }

        // -------------------------
        // STEP 2 : Update Stock
        // -------------------------

        stockUpdates.forEach((ref, stock) {
          transaction.update(ref, {
            "stock": stock,
            "updatedAt":
                FieldValue.serverTimestamp(),
          });
        });

        // -------------------------
        // STEP 3 : Save Order
        // -------------------------

        final orderRef = _firestore
            .collection("orders")
            .doc(order.orderId);

        transaction.set(
          orderRef,
          order.toFirestoreMap(),
        );

        // -------------------------
        // STEP 4 : Update Products Meta
        // -------------------------

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("products"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );

        // -------------------------
        // STEP 5 : Update User Orders Meta
        // -------------------------

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("orders_${order.userId}"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );

        // -------------------------
        // STEP 6 : Update Admin Orders Meta
        // -------------------------

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("admin_orders"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ================= FETCH USER ORDERS =================

// ================= FETCH USER ORDERS =================

Future<List<OrderModel>> fetchOrders(
  String userId, {
  int limit = orderLimit,
}) async {
  final cacheService = CacheService();

final localMeta =
    cacheService.getOrdersMeta(userId);

  final serverMeta = await getOrdersMeta(userId);

  // Load cached orders
  final cachedOrders = cacheService.getOrders(userId);

  // Cache is up-to-date
  if (localMeta == serverMeta &&
      cachedOrders.isNotEmpty) {
    return cachedOrders;
  }

  final snapshot = await _firestore
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

  final orders = snapshot.docs
      .map((doc) => OrderModel.fromMap(doc.data()))
      .toList();

await cacheService.saveOrders(
  userId,
  orders,
);

await cacheService.saveOrdersMeta(
  userId,
  serverMeta,
);

  return orders;
}
  // ================= USER META =================

  Future<String> getOrdersMeta(
    String userId,
  ) async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("orders_$userId")
        .get();

    if (!doc.exists) return "";

    final timestamp =
        doc["lastUpdated"] as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }
}