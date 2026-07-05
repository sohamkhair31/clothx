import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/cart_controller.dart';
import 'package:clothx/controllers/order_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String optimizeImage(String url) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_200/",
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final order =
        context.watch<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: cart.cartItems.isEmpty
          ? Center(
              child: Text(
                "Cart is empty",
                style:
                    AppTheme.subHeading,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        cart.cartItems.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          cart.cartItems[index];

                      return Card(
                        margin:
                            const EdgeInsets.all(
                          10,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            12,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                                child:
                                    CachedNetworkImage(
                                  imageUrl:
                                      optimizeImage(
                                    item.image,
                                  ),
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (
                                        context,
                                        url,
                                      ) =>
                                          const SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    ),
                                  ),
                                  errorWidget:
                                      (
                                        context,
                                        url,
                                        error,
                                      ) =>
                                          const Icon(
                                    Icons.broken_image,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      item.name,
                                      style:
                                          AppTheme.subHeading,
                                    ),
                                    const SizedBox(
                                        height: 5),
                                    Text(
                                      "Size: ${item.size}",
                                    ),
                                    Text(
                                      "₹${item.price}",
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      cart.decreaseQuantity(
                                        index,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.remove,
                                    ),
                                  ),
                                  Text(
                                    item.quantity
                                        .toString(),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cart.increaseQuantity(
                                        index,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cart.removeItem(
                                        index,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color:
                                          Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color:
                            Colors.black12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style:
                                AppTheme.subHeading,
                          ),
                          Text(
                            "₹${cart.totalPrice}",
                            style:
                                AppTheme.subHeading,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              order.isLoading
                                  ? null
                                  : () async {
                                      if (auth
                                              .currentUser ==
                                          null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text(
                                              "Login required",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final success =
                                          await context
                                              .read<
                                                  OrderController>()
                                              .placeOrder(
                                                userId:
                                                    auth.currentUser!.uid,
                                                items:
                                                    cart.cartItems,
                                                totalAmount:
                                                    cart.totalPrice,
                                                cartController:
                                                    cart,
                                              );

                                      if (!context
                                          .mounted) {
                                        return;
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(
                                            success
                                                ? "Order placed successfully"
                                                : "Order failed",
                                          ),
                                        ),
                                      );
                                    },
                          child:
                              order.isLoading
                                  ? const SizedBox(
                                      height:
                                          20,
                                      width:
                                          20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : const Text(
                                      "Checkout",
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}