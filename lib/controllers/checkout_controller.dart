import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repo.dart';
import 'cart_controller.dart';

class CheckoutController extends ChangeNotifier {
  final OrderRepo _orderRepo = OrderRepo();

  bool isLoading = false;
  String? errorMessage;

  Future<bool> checkout({
    required String userId,
    required List<CartModel> cartItems,
    required CartController cartController,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (cartItems.isEmpty) {
        throw Exception("Your cart is empty.");
      }

      final total = cartItems.fold<double>(
        0,
        (sum, item) =>
            sum + (item.price * item.quantity),
      );

      final order = OrderModel(
        orderId: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        userId: userId,
        items: List<CartModel>.from(cartItems),
        totalAmount: total,
        paymentStatus: "paid",
        orderStatus: "pending",
        createdAt: DateTime.now(),
      );

      await _orderRepo.placeOrder(order);

      // Clear local cart only after successful order
      await cartController.clearCart();

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
}