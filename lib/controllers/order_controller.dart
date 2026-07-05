import 'package:flutter/material.dart';

import '../core/services/cache/cache_service.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repo.dart';
import 'cart_controller.dart';

class OrderController extends ChangeNotifier {
  final OrderRepo _orderRepo = OrderRepo();
  final CacheService _cacheService = CacheService();

  List<OrderModel> orders = [];

  bool isLoading = false;
  String? errorMessage;

  static const int orderLimit = 20;

  // ================= LOAD CACHE =================

void loadOrdersFromCache(
  String userId,
) {
  orders = _cacheService.getOrders(userId);

  if (orders.isNotEmpty) {
    notifyListeners();
  }
}
  // ================= PLACE ORDER =================

  Future<bool> placeOrder({
    required String userId,
    required List<CartModel> items,
    required double totalAmount,
    required CartController cartController,
    // NEW — optional. Defaults to 'Online' so any existing call site that
    // doesn't pass this keeps getting paymentStatus "Paid" exactly like before.
    String paymentMethod = 'Online',
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final now = DateTime.now();

      final order = OrderModel(
        orderId:
            now.millisecondsSinceEpoch
                .toString(),
        userId: userId,
        items: List<CartModel>.from(items),
        totalAmount: totalAmount,
        // NEW — Cash on Delivery orders are recorded as unpaid until
        // delivery; online payments keep the original "Paid" behavior.
        paymentStatus: paymentMethod == 'COD' ? "Unpaid" : "Paid",
        orderStatus: "Pending",
        createdAt: now,
      );

      await _orderRepo.placeOrder(order);

      await cartController.clearCart();

      orders.insert(0, order);

await _cacheService.saveOrders(
  userId,
  orders,
);

      final serverMeta =
          await _orderRepo.getOrdersMeta(
        userId,
      );

      await _cacheService.saveOrdersMeta(
        userId,
        serverMeta,
      );

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

  // ================= FETCH ORDERS =================

  Future<void> fetchOrders(
    String userId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;

      if (orders.isEmpty) {
        notifyListeners();
      }

      final localMeta =
          _cacheService.getOrdersMeta(
        userId,
      );

      final serverMeta =
          await _orderRepo.getOrdersMeta(
        userId,
      );

      if (localMeta == serverMeta &&
          orders.isNotEmpty) {
        isLoading = false;
        notifyListeners();
        return;
      }

      orders =
          await _orderRepo.fetchOrders(
        userId,
        limit: orderLimit,
      );
await _cacheService.saveOrders(
  userId,
  orders,
);

      await _cacheService.saveOrdersMeta(
        userId,
        serverMeta,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= REFRESH =================

  Future<void> refreshOrders(
    String userId,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      orders =
          await _orderRepo.fetchOrders(
        userId,
        limit: orderLimit,
      );

      final serverMeta =
          await _orderRepo.getOrdersMeta(
        userId,
      );

await _cacheService.saveOrders(
  userId,
  orders,
);
      await _cacheService.saveOrdersMeta(
        userId,
        serverMeta,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= CLEAR CACHE =================

  Future<void> clearOrdersCache(
    String userId,
  ) async {
await _cacheService.clearOrders(
  userId,
);

    orders.clear();

    notifyListeners();
  }
}