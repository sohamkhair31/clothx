import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../repositories/admin_order_repo.dart';
import '../core/services/cache/cache_service.dart';

class AdminOrderController extends ChangeNotifier {
  final AdminOrderRepo _adminOrderRepo =
      AdminOrderRepo();

  final CacheService _cacheService =
      CacheService();

  List<OrderModel> orders = [];

  bool isLoading = false;
  String? errorMessage;

  static const int orderLimit = 50;

  // ================= LOAD CACHE =================
void loadOrdersFromCache() {
  orders = _cacheService.getOrders("admin");

  if (orders.isNotEmpty) {
    notifyListeners();
  }
}
  // ================= FETCH ORDERS =================
  Future<void> fetchOrders() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Local meta
final localMeta =
    _cacheService.getOrdersMeta("admin");

      // Server meta
      final serverMeta =
          await _adminOrderRepo.getOrdersMeta();

      // If same, skip fetch
if (localMeta == serverMeta &&
    orders.isNotEmpty) {
        print(
          "Admin orders unchanged. Using cache.",
        );

        isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch fresh
      orders =
          await _adminOrderRepo.getAllOrders(
        limit: orderLimit,
      );

      // Save cache
await _cacheService.saveOrders(
  "admin",
  orders,
);

      // Save meta
await _cacheService.saveOrdersMeta(
  "admin",
  serverMeta,
);

      isLoading = false;
      notifyListeners();
   } catch (e) {
  errorMessage = e.toString();

  print(
    "Admin fetch orders error: $e",
  );

  // Load cached orders if network fails
  orders = _cacheService.getOrders("admin");

  isLoading = false;
  notifyListeners();
}
  }

  // ================= UPDATE STATUS =================
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

      final index = orders.indexWhere(
        (o) => o.orderId == orderId,
      );

      if (index != -1) {
        orders[index] =
            orders[index].copyWith(
          orderStatus: status,
        );
      }

      // Update local cache
await _cacheService.saveOrders(
  "admin",
  orders,
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

  // ================= CANCEL ORDER =================
  Future<bool> cancelOrder(
    String orderId,
  ) async {
    return await updateOrderStatus(
      orderId: orderId,
      status: "cancelled",
    );
  }

  // ================= FILTERS =================
  List<OrderModel> getPendingOrders() {
    return orders.where(
      (o) =>
          o.orderStatus.toLowerCase() ==
          "pending",
    ).toList();
  }

  List<OrderModel> getDeliveredOrders() {
    return orders.where(
      (o) =>
          o.orderStatus.toLowerCase() ==
          "delivered",
    ).toList();
  }

  List<OrderModel> getCancelledOrders() {
    return orders.where(
      (o) =>
          o.orderStatus.toLowerCase() ==
          "cancelled",
    ).toList();
  }

  List<OrderModel> getShippedOrders() {
    return orders.where(
      (o) =>
          o.orderStatus.toLowerCase() ==
          "shipped",
    ).toList();
  }
}