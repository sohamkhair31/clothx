import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../core/services/cache/cache_service.dart';
import 'cart_controller.dart';

class OrderController extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CacheService _cacheService =
      CacheService();

  List<OrderModel> orders = [];

  bool isLoading = false;
  String? errorMessage;

  // ================= LOAD CACHE =================
  void loadOrdersFromCache(
    String userId,
  ) {
    final cachedOrders =
        _cacheService.getOrders(userId);

    if (cachedOrders.isNotEmpty) {
      orders =
          cachedOrders.map<OrderModel>((e) {
        return OrderModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      notifyListeners();
    }
  }

  // ================= PLACE ORDER =================
  Future<bool> placeOrder({
    required String userId,
    required List<CartModel> items,
    required double totalAmount,
    required CartController cartController,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final orderId =
          DateTime.now()
              .millisecondsSinceEpoch
              .toString();

      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        paymentStatus: "Paid",
        orderStatus: "Pending",
        createdAt: DateTime.now(),
      );

      print(
        "Placing order for user: $userId",
      );

      await _firestore
          .collection("orders")
          .doc(orderId)
          .set(order.toFirestoreMap());

      print("Order saved: $orderId");

      await cartController.clearCart();

      orders.insert(0, order);

      await _cacheService.saveOrders(
        userId,
        orders.map((e) => e.toMap()).toList(),
      );

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      print("Place Order Error: $e");

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= FETCH ORDERS =================
  Future<void> fetchOrders(
    String userId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      print(
        "Fetching orders for user: $userId",
      );

      final snapshot =
          await _firestore
              .collection("orders")
              .where(
                "userId",
                isEqualTo: userId,
              )
              .get();

      orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(
          doc.data(),
        );
      }).toList();

      // Sort locally
      orders.sort(
        (a, b) => b.createdAt.compareTo(
          a.createdAt,
        ),
      );

      await _cacheService.saveOrders(
        userId,
        orders.map((e) => e.toMap()).toList(),
      );

      print(
        "Orders fetched: ${orders.length}",
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print(
        "Fetch Orders Error: $e",
      );

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= CANCEL ORDER =================
  Future<void> cancelOrder(
    String orderId,
  ) async {
    try {
      await _firestore
          .collection("orders")
          .doc(orderId)
          .update({
        "orderStatus": "Cancelled",
      });

      final index = orders.indexWhere(
        (o) => o.orderId == orderId,
      );

      if (index != -1) {
        final updatedOrder =
            orders[index].copyWith(
          orderStatus: "Cancelled",
        );

        orders[index] = updatedOrder;

        await _cacheService.saveOrders(
          updatedOrder.userId,
          orders
              .map((e) => e.toMap())
              .toList(),
        );
      }

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print(
        "Cancel Order Error: $e",
      );

      notifyListeners();
    }
  }
}