import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';

import '../models/product_model.dart';
import '../models/cart_model.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String logs = "Ready...\n";
  final ScrollController _scrollController = ScrollController();

  void addLog(String text) {
    setState(() {
      logs += "$text\n";
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void clearLogs() {
    setState(() {
      logs = "Logs Cleared...\n";
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final admin = context.watch<AdminController>();
    final product = context.watch<ProductController>();
    final cart = context.watch<CartController>();
    final order = context.watch<OrderController>();

    final loading = auth.isLoading ||
        admin.isLoading ||
        product.isLoading ||
        order.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Backend Test Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (loading) const LinearProgressIndicator(),

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: clearLogs,
                  child: const Text("Clear Logs"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final result = await auth.signUp(
                      name: "Test User",
                      email: "test@gmail.com",
                      password: "123456",
                      phone: "9999999999",
                      address: "Pune",
                    );

                    addLog("Signup: $result");

                    if (!result) {
                      addLog("Error: ${auth.errorMessage}");
                    }
                  },
                  child: const Text("Signup"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final result = await auth.login(
                      email: "test@gmail.com",
                      password: "123456",
                    );

                    addLog("Login: $result");

                    if (!result) {
                      addLog("Error: ${auth.errorMessage}");
                    }
                  },
                  child: const Text("Login"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final productData = ProductModel(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      name: "Black Hoodie",
                      description: "Premium hoodie",
                      price: 1499,
                      images: ["dummy_url"],
                      sizes: ["M", "L"],
                      stock: 20,
                      gender: "men",
                      category: "hoodies",
                      isActive: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    final result =
                        await admin.addProduct(productData);

                    addLog("Add Product: $result");

                    if (!result) {
                      addLog("Error: ${admin.errorMessage}");
                    }
                  },
                  child: const Text("Add Product"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await product.fetchProducts();

                    addLog(
                        "Fetched Products: ${product.products.length}");
                  },
                  child: const Text("Fetch Products"),
                ),

                ElevatedButton(
                  onPressed: () {
                    addLog("=== PRODUCT CACHE ===");

                    for (var p in product.products) {
                      addLog(
                        """
ID: ${p.id}
Name: ${p.name}
Description: ${p.description}
Price: ₹${p.price}
Stock: ${p.stock}
Gender: ${p.gender}
Category: ${p.category}
Sizes: ${p.sizes}
Images: ${p.images}
Created: ${p.createdAt}
Updated: ${p.updatedAt}
-------------------------
""",
                      );
                    }
                  },
                  child: const Text("Show Product Cache"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await product.clearLocalCache();

                    addLog("Product Cache Cleared");
                  },
                  child: const Text("Clear Product Cache"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    cart.loadCart();

                    addLog("=== CART CACHE ===");

                    for (var item in cart.cartItems) {
                      addLog(
                        """
Product ID: ${item.productId}
Name: ${item.name}
Price: ₹${item.price}
Size: ${item.size}
Quantity: ${item.quantity}
Image: ${item.image}
-------------------------
""",
                      );
                    }
                  },
                  child: const Text("Show Cart Cache"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (product.products.isEmpty) {
                      addLog("No products available.");
                      return;
                    }

                    final item = CartModel(
                      productId: product.products.first.id,
                      name: product.products.first.name,
                      image: product.products.first.images.first,
                      price: product.products.first.price,
                      size: "M",
                      quantity: 1,
                    );

                    await cart.addToCart(item);

                    addLog(
                      "Cart Updated -> Items: ${cart.cartItems.length}",
                    );
                  },
                  child: const Text("Add To Cart"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (auth.currentUser == null) {
                      addLog("No logged in user.");
                      return;
                    }

                    if (cart.cartItems.isEmpty) {
                      addLog("Cart empty.");
                      return;
                    }

                    final result = await order.placeOrder(
                      userId: auth.currentUser!.uid,
                      items: cart.cartItems,
                      totalAmount: cart.totalPrice,
                      cartController: cart,
                    );

                    addLog("Place Order: $result");

                    if (!result) {
                      addLog("Error: ${order.errorMessage}");
                    }
                  },
                  child: const Text("Place Order"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    if (auth.currentUser == null) {
                      addLog("No logged in user.");
                      return;
                    }

                    await order.fetchOrders(
                      auth.currentUser!.uid,
                    );

                    addLog("=== ORDERS ===");

                    for (var o in order.orders) {
                      addLog(
                        """
Order ID: ${o.orderId}
User ID: ${o.userId}
Total: ₹${o.totalAmount}
Payment: ${o.paymentStatus}
Status: ${o.orderStatus}
Created: ${o.createdAt}
Items Count: ${o.items.length}
-------------------------
""",
                      );
                    }
                  },
                  child: const Text("Fetch Orders"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await auth.logout();

                    addLog("Logged Out");
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Current User: ${auth.currentUser?.email ?? "None"}"),
                    Text(
                        "Products: ${product.products.length}"),
                    Text(
                        "Cart Items: ${cart.cartItems.length}"),
                    Text(
                        "Cart Total: ₹${cart.totalPrice}"),
                    Text(
                        "Orders: ${order.orders.length}"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.black,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    logs,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}