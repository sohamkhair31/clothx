import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../models/cart_model.dart';
import 'cart_controller.dart';

class OrderController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<OrderModel> orders = [];
  bool isLoading = false;
  String? errorMessage;

  // Place order after payment success
  Future<bool> placeOrder({
    required String userId,
    required List<CartModel> items,
    required double totalAmount,
    required CartController cartController,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      final order = OrderModel(
        orderId: orderId,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        paymentStatus: "Paid",
        orderStatus: "Pending",
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection("orders")
          .doc(orderId)
          .set(order.toMap());

      await cartController.clearCart();

      orders.add(order);

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch user orders
  Future<void> fetchOrders(String userId) async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection("orders")
          .where("userId", isEqualTo: userId)
          .get();

      orders = snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data());
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection("orders").doc(orderId).update({
      "orderStatus": "Cancelled",
    });

    final index = orders.indexWhere((o) => o.orderId == orderId);

    if (index != -1) {
      orders[index] = OrderModel(
        orderId: orders[index].orderId,
        userId: orders[index].userId,
        items: orders[index].items,
        totalAmount: orders[index].totalAmount,
        paymentStatus: orders[index].paymentStatus,
        orderStatus: "Cancelled",
        createdAt: orders[index].createdAt,
      );
    }

    notifyListeners();
  }
}