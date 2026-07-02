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

      if (auth.currentUser != null) {
        await context
            .read<OrderController>()
            .fetchOrders(
              auth.currentUser!.uid,
            );
      }
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

      body: order.isLoading
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
              : ListView.builder(
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
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: getStatusColor(
                                  item.orderStatus,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
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
                                      FontWeight
                                          .bold,
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
    );
  }
}