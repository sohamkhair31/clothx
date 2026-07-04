import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../core/services/cache/cache_service.dart';

class CartController extends ChangeNotifier {
  final CacheService _cacheService =
      CacheService();

  List<CartModel> cartItems = [];

  double totalPrice = 0;

  // ================= LOAD CART =================
  void loadCart() {
    final cachedCart =
        _cacheService.getCart();

    if (cachedCart.isNotEmpty) {
      cartItems =
          cachedCart.map<CartModel>((e) {
        return CartModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();
    }

    _calculateTotal();
    notifyListeners();
  }

  // ================= ADD TO CART =================
  Future<void> addToCart(
    CartModel item,
  ) async {
    final index = cartItems.indexWhere(
      (cartItem) =>
          cartItem.productId ==
              item.productId &&
          cartItem.size == item.size,
    );

    if (index != -1) {
      final oldItem = cartItems[index];

      cartItems[index] = oldItem.copyWith(
        quantity:
            oldItem.quantity +
            item.quantity,
      );
    } else {
      cartItems.add(item);
    }

    await _saveAndRefresh();
  }

  // ================= INCREASE =================
  Future<void> increaseQuantity(
    int index,
  ) async {
    final item = cartItems[index];

    cartItems[index] = item.copyWith(
      quantity: item.quantity + 1,
    );

    await _saveAndRefresh();
  }

  // ================= DECREASE =================
  Future<void> decreaseQuantity(
    int index,
  ) async {
    final item = cartItems[index];

    if (item.quantity <= 1) return;

    cartItems[index] = item.copyWith(
      quantity: item.quantity - 1,
    );

    await _saveAndRefresh();
  }

  // ================= REMOVE ITEM =================
  Future<void> removeItem(
    int index,
  ) async {
    if (index < 0 ||
        index >= cartItems.length) {
      return;
    }

    cartItems.removeAt(index);

    await _saveAndRefresh();
  }

  // ================= TOTAL =================
  void _calculateTotal() {
    totalPrice = cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (item.price *
              item.quantity),
    );
  }

  // ================= SAVE + REFRESH =================
  Future<void> _saveAndRefresh() async {
    await _cacheService.saveCart(
      cartItems.map((e) => e.toMap()).toList(),
    );

    _calculateTotal();

    notifyListeners();
  }

  // ================= CLEAR CART =================
  Future<void> clearCart() async {
    cartItems.clear();
    totalPrice = 0;

    await _cacheService.clearCart();

    notifyListeners();
  }
}