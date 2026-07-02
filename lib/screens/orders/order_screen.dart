import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/order_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState
    extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth =
          context.read<AuthController>();

      final orderController =
          context.read<OrderController>();

      final user = auth.currentUser;

      // Stop if no user logged in
      if (user == null) return;

      // Load cache first
      orderController.loadOrdersFromCache(
        user.uid,
      );

      // Then fetch latest from server
      await orderController.fetchOrders(
        user.uid,
      );
    });
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "confirmed":
        return Colors.blue;
      case "shipped":
        return Colors.purple;
      case "delivered":
        return Colors.green;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final order =
        context.watch<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
      ),
      body: order.isLoading &&
              order.orders.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : order.orders.isEmpty
              ? Center(
                  child: Text(
                    "No orders yet",
                    style:
                        AppTheme.subHeading,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    final auth = context
                        .read<AuthController>();

                    final user =
                        auth.currentUser;

                    if (user == null) return;

                    await context
                        .read<OrderController>()
                        .fetchOrders(
                          user.uid,
                        );
                  },
                  child: ListView.builder(
                    itemCount:
                        order.orders.length,
                    itemBuilder:
                        (context, index) {
                      final item =
                          order.orders[index];

                      return Card(
                        margin:
                            const EdgeInsets.all(
                          12,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Order ID",
                                style: AppTheme
                                    .subHeading,
                              ),
                              Text(item.orderId),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                "Total: ₹${item.totalAmount}",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      getStatusColor(
                                    item.orderStatus,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  item.orderStatus
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                "Items: ${item.items.length}",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}