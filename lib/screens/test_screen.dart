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

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  ProductModel? selectedProduct;
  int quantity = 1;
  String selectedSize = "M";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductController>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final admin = context.watch<AdminController>();
    final productController = context.watch<ProductController>();
    final cart = context.watch<CartController>();
    final order = context.watch<OrderController>();
    final adminOrder = context.watch<AdminOrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ClothX Full Test"),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// AUTH
            const Text(
              "Auth",
              style: TextStyle(fontSize: 20),
            ),

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
              ],
            ),

            const SizedBox(height: 20),

            /// ADMIN ADD PRODUCT
            const Text(
              "Admin",
              style: TextStyle(fontSize: 20),
            ),

            ElevatedButton(
              onPressed: () async {
                final product = ProductModel(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  name: "Black Hoodie",
                  description: "Premium hoodie",
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

                await admin.addProduct(product);

                await productController.fetchProducts();
              },
              child: const Text("Add Dummy Product"),
            ),

            const SizedBox(height: 20),

            /// PRODUCTS
            const Text(
              "Products",
              style: TextStyle(fontSize: 20),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productController.products.length,
              itemBuilder: (context, index) {
                final p = productController.products[index];

                return Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      "₹${p.price} | Stock: ${p.stock}",
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
              },
            ),

            const SizedBox(height: 20),

            if (selectedProduct != null) ...[
              Text(
                "Selected: ${selectedProduct!.name}",
                style: const TextStyle(fontSize: 18),
              ),

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
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    onPressed: () {
                      if (quantity < selectedProduct!.stock) {
                        setState(() {
                          quantity++;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () async {
                  final item = CartModel(
                    productId: selectedProduct!.id,
                    name: selectedProduct!.name,
                    image: selectedProduct!.images.first,
                    price: selectedProduct!.price,
                    size: selectedSize,
                    quantity: quantity,
                  );

                  await cart.addToCart(item);
                },
                child: const Text("Add To Cart"),
              ),
            ],

            const SizedBox(height: 20),

            /// CART
            const Text(
              "Cart",
              style: TextStyle(fontSize: 20),
            ),

            ...cart.cartItems.map(
              (item) => ListTile(
                title: Text(item.name),
                subtitle: Text(
                  "${item.size} x${item.quantity}",
                ),
                trailing: Text("₹${item.price}"),
              ),
            ),

            Text("Total: ₹${cart.totalPrice}"),

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

            const SizedBox(height: 20),

            /// USER ORDERS
            ElevatedButton(
              onPressed: () async {
                if (auth.currentUser == null) return;

                await order.fetchOrders(
                  auth.currentUser!.uid,
                );
              },
              child: const Text("Fetch My Orders"),
            ),

            ...order.orders.map(
              (o) => ListTile(
                title: Text(o.orderId),
                subtitle: Text(o.orderStatus),
                trailing: Text("₹${o.totalAmount}"),
              ),
            ),

            const SizedBox(height: 20),

            /// ADMIN ORDERS
            ElevatedButton(
              onPressed: () async {
                await adminOrder.fetchOrders();
              },
              child: const Text("Admin Fetch Orders"),
            ),

            ...adminOrder.orders.map(
              (o) => Card(
                child: ListTile(
                  title: Text(o.orderId),
                  subtitle: Text(o.orderStatus),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}