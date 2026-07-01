import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/admin_order_controller.dart';

import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  ProductModel? selectedProduct;
  String selectedSize = "M";
  int quantity = 1;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await context.read<ProductController>().fetchProducts();
      context.read<CartController>().loadCart();
    });
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final admin = context.watch<AdminController>();
    final product = context.watch<ProductController>();
    final cart = context.watch<CartController>();
    final order = context.watch<OrderController>();
    final adminOrder = context.watch<AdminOrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ClothX Backend Full Test"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle("Auth"),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await auth.signUp(
                      name: "Test User",
                      email: "test@gmail.com",
                      password: "123456",
                      phone: "9999999999",
                      address: "Pune",
                    );
                  },
                  child: const Text("Signup"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await auth.login(
                      email: "test@gmail.com",
                      password: "123456",
                    );
                  },
                  child: const Text("Login"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await auth.logout();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),

            Text("Current User: ${auth.currentUser?.email ?? "None"}"),

            sectionTitle("Admin"),

            ElevatedButton(
              onPressed: () async {
                final newProduct = ProductModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: "Black Hoodie",
                  description: "Premium hoodie test",
                  price: 1499,
                  images: ["dummy_url"],
                  sizes: ["S", "M", "L"],
                  stock: 20,
                  gender: "men",
                  category: "hoodies",
                  isActive: true,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await admin.addProduct(newProduct);
                await product.fetchProducts();
              },
              child: const Text("Add Dummy Product"),
            ),

            ElevatedButton(
              onPressed: () async {
                await product.fetchProducts();
              },
              child: const Text("Refresh Products"),
            ),

            ElevatedButton(
              onPressed: () {
                product.loadFromCacheOnly();
              },
              child: const Text("Load Products From Cache"),
            ),

            sectionTitle("Products"),

            ...product.products.map((p) {
              return Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    """
₹${p.price}
Stock: ${p.stock}
Category: ${p.category}
Gender: ${p.gender}
Sizes: ${p.sizes.join(", ")}
Updated: ${p.updatedAt}
""",
                  ),
                  trailing: selectedProduct?.id == p.id
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedProduct = p;
                      selectedSize = p.sizes.first;
                      quantity = 1;
                    });
                  },
                ),
              );
            }),

            if (selectedProduct != null) ...[
              sectionTitle("Selected Product"),

              Text("Name: ${selectedProduct!.name}"),
              Text("Price: ₹${selectedProduct!.price}"),
              Text("Stock: ${selectedProduct!.stock}"),
              Text("Description: ${selectedProduct!.description}"),

              DropdownButton<String>(
                value: selectedSize,
                items: selectedProduct!.sizes.map((size) {
                  return DropdownMenuItem(
                    value: size,
                    child: Text(size),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSize = value!;
                  });
                },
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    onPressed: () {
                      if (quantity < selectedProduct!.stock) {
                        setState(() => quantity++);
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () async {
                  await cart.addToCart(
                    CartModel(
                      productId: selectedProduct!.id,
                      name: selectedProduct!.name,
                      image: selectedProduct!.images.first,
                      price: selectedProduct!.price,
                      size: selectedSize,
                      quantity: quantity,
                    ),
                  );
                },
                child: const Text("Add To Cart"),
              ),
            ],

            sectionTitle("Cart"),

            ...cart.cartItems.map((item) {
              return Card(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    """
Size: ${item.size}
Qty: ${item.quantity}
Subtotal: ₹${item.price * item.quantity}
""",
                  ),
                ),
              );
            }),

            Text("Cart Total: ₹${cart.totalPrice}"),

            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (auth.currentUser == null) return;

                    await order.placeOrder(
                      userId: auth.currentUser!.uid,
                      items: cart.cartItems,
                      totalAmount: cart.totalPrice,
                      cartController: cart,
                    );
                  },
                  child: const Text("Place Order"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await cart.clearCart();
                  },
                  child: const Text("Clear Cart"),
                ),
              ],
            ),

            sectionTitle("My Orders"),

            ElevatedButton(
              onPressed: () async {
                if (auth.currentUser == null) return;

                await order.fetchOrders(auth.currentUser!.uid);
              },
              child: const Text("Fetch My Orders"),
            ),

            ...order.orders.map((OrderModel o) {
              return Card(
                child: ListTile(
                  title: Text("Order: ${o.orderId}"),
                  subtitle: Text(
                    """
Status: ${o.orderStatus}
Payment: ${o.paymentStatus}
Items: ${o.items.length}
Total: ₹${o.totalAmount}
Created: ${o.createdAt}
""",
                  ),
                ),
              );
            }),

            sectionTitle("Admin Orders"),

            ElevatedButton(
              onPressed: () async {
                await adminOrder.fetchOrders();
              },
              child: const Text("Fetch All Orders"),
            ),

            ...adminOrder.orders.map((OrderModel o) {
              return Card(
                child: ListTile(
                  title: Text("Order: ${o.orderId}"),
                  subtitle: Text(
                    """
User: ${o.userId}
Status: ${o.orderStatus}
Total: ₹${o.totalAmount}
""",
                  ),
                  trailing: DropdownButton<String>(
                    value: o.orderStatus.toLowerCase(),
                    items: const [
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Pending"),
                      ),
                      DropdownMenuItem(
                        value: "confirmed",
                        child: Text("Confirmed"),
                      ),
                      DropdownMenuItem(
                        value: "shipped",
                        child: Text("Shipped"),
                      ),
                      DropdownMenuItem(
                        value: "delivered",
                        child: Text("Delivered"),
                      ),
                      DropdownMenuItem(
                        value: "cancelled",
                        child: Text("Cancelled"),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;

                      await adminOrder.updateOrderStatus(
                        orderId: o.orderId,
                        status: value,
                      );
                    },
                  ),
                ),
              );
            }),

            sectionTitle("Debug Stats"),
sectionTitle("Cache Debug"),

Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.loadedFromCache
              ? "Cache Used: YES"
              : "Cache Used: NO",
          style: TextStyle(
            color: product.loadedFromCache
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          product.loadedFromServer
              ? "Server Fetch: YES"
              : "Server Fetch: NO",
          style: TextStyle(
            color: product.loadedFromServer
                ? Colors.orange
                : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "Last Cache Load: ${product.lastCacheLoad ?? "Never"}",
        ),

        Text(
          "Last Server Fetch: ${product.lastServerFetch ?? "Never"}",
        ),

        const Divider(),

        Text("Products in Memory: ${product.products.length}"),
        Text("Cart Items: ${cart.cartItems.length}"),
        Text("Orders: ${order.orders.length}"),
        Text("Admin Orders: ${adminOrder.orders.length}"),
      ],
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}