import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../repositories/admin_order_repo.dart';

class AdminOrderController extends ChangeNotifier {
  final AdminOrderRepo _adminOrderRepo =
      AdminOrderRepo();

  List<OrderModel> orders = [];

  bool isLoading = false;
  String? errorMessage;

  // Fetch all orders
  Future<void> fetchOrders() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      orders = await _adminOrderRepo.getAllOrders();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminOrderRepo.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

final index =
    orders.indexWhere((o) => o.orderId == orderId);

if (index != -1) {
  orders[index] = orders[index].copyWith(
    orderStatus: "cancelled",
  );
}

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

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminOrderRepo.cancelOrder(orderId);

      final index =
          orders.indexWhere((o) => o.orderId == orderId);

      if (index != -1) {
        orders[index] = orders[index].copyWith(
          orderStatus: "cancelled",
        );
      }

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

  // Pending orders
  List<OrderModel> getPendingOrders() {
    return orders.where((o) {
      return o.orderStatus == "pending";
    }).toList();
  }

  // Delivered orders
  List<OrderModel> getDeliveredOrders() {
    return orders.where((o) {
      return o.orderStatus == "delivered";
    }).toList();
  }

  // Cancelled orders
  List<OrderModel> getCancelledOrders() {
    return orders.where((o) {
      return o.orderStatus == "cancelled";
    }).toList();
  }
}