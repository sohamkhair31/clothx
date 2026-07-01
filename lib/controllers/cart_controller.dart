import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../core/services/cache/cache_service.dart';

class CartController extends ChangeNotifier {
  final CacheService _cacheService = CacheService();

  List<CartModel> cartItems = [];

  double totalPrice = 0;

  // Load cart from Hive
  void loadCart() {
    final cachedCart = _cacheService.getCart();

    cartItems = cachedCart
        .map<CartModel>(
          (e) => CartModel.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    calculateTotal();
    notifyListeners();
  }

  // Add to cart
  Future<void> addToCart(CartModel item) async {
    final index = cartItems.indexWhere(
      (cartItem) =>
          cartItem.productId == item.productId &&
          cartItem.size == item.size,
    );

    if (index != -1) {
      cartItems[index] = CartModel(
        productId: cartItems[index].productId,
        name: cartItems[index].name,
        image: cartItems[index].image,
        price: cartItems[index].price,
        size: cartItems[index].size,
        quantity: cartItems[index].quantity + item.quantity,
      );
    } else {
      cartItems.add(item);
    }

    await _saveCart();
    calculateTotal();
    notifyListeners();
  }

  // Increase quantity
  Future<void> increaseQuantity(int index) async {
    cartItems[index] = CartModel(
      productId: cartItems[index].productId,
      name: cartItems[index].name,
      image: cartItems[index].image,
      price: cartItems[index].price,
      size: cartItems[index].size,
      quantity: cartItems[index].quantity + 1,
    );

    await _saveCart();
    calculateTotal();
    notifyListeners();
  }

  // Decrease quantity
  Future<void> decreaseQuantity(int index) async {
    if (cartItems[index].quantity > 1) {
      cartItems[index] = CartModel(
        productId: cartItems[index].productId,
        name: cartItems[index].name,
        image: cartItems[index].image,
        price: cartItems[index].price,
        size: cartItems[index].size,
        quantity: cartItems[index].quantity - 1,
      );

      await _saveCart();
      calculateTotal();
      notifyListeners();
    }
  }

  // Remove item
  Future<void> removeItem(int index) async {
    cartItems.removeAt(index);

    await _saveCart();
    calculateTotal();
    notifyListeners();
  }

  // Total price
  void calculateTotal() {
    totalPrice = 0;

    for (var item in cartItems) {
      totalPrice += item.price * item.quantity;
    }
  }

  // Save cart in Hive
  Future<void> _saveCart() async {
    await _cacheService.saveCart(
      cartItems.map((e) => e.toMap()).toList(),
    );
  }

  // Clear cart
  Future<void> clearCart() async {
    cartItems.clear();
    totalPrice = 0;

    await _cacheService.clearCart();

    notifyListeners();
  }
}