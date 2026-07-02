import 'package:clothx/controllers/admin_order_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrdersScreen
    extends StatefulWidget {
  const AdminOrdersScreen({
    super.key,
  });

  @override
  State<AdminOrdersScreen>
      createState() =>
          _AdminOrdersScreenState();
}

class _AdminOrdersScreenState
    extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final controller =
          context.read<
              AdminOrderController>();

      // CACHE FIRST
      controller.loadOrdersFromCache();

      // SERVER REFRESH
      await controller.fetchOrders();
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
    final adminOrder =
        context.watch<
            AdminOrderController>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Track Orders"),
      ),

      body: adminOrder.isLoading &&
              adminOrder.orders.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : adminOrder.orders.isEmpty
              ? Center(
                  child: Text(
                    "No orders found",
                    style:
                        AppTheme.subHeading,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await context
                        .read<
                            AdminOrderController>()
                        .fetchOrders();
                  },
                  child: ListView.builder(
                    itemCount:
                        adminOrder
                            .orders.length,
                    itemBuilder:
                        (context, index) {
                      final order =
                          adminOrder
                              .orders[index];

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
                                style:
                                    AppTheme.subHeading,
                              ),

                              Text(
                                order.orderId,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                "User ID",
                              ),

                              Text(
                                order.userId,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Text(
                                "Total: ₹${order.totalAmount}",
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      12,
                                  vertical:
                                      6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      getStatusColor(
                                    order.orderStatus,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  order
                                      .orderStatus
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
                                height: 15,
                              ),

                              Text(
                                "Products",
                                style:
                                    AppTheme.subHeading,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              ...order.items.map(
                                (item) {
                                  return ListTile(
                                    contentPadding:
                                        EdgeInsets.zero,
                                    leading:
                                        Image.network(
                                      item.image,
                                      width:
                                          50,
                                      height:
                                          50,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      item.name,
                                    ),
                                    subtitle:
                                        Text(
                                      "Size: ${item.size} | Qty: ${item.quantity}",
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _statusButton(
                                    "Confirmed",
                                    order.orderId,
                                  ),
                                  _statusButton(
                                    "Shipped",
                                    order.orderId,
                                  ),
                                  _statusButton(
                                    "Delivered",
                                    order.orderId,
                                  ),
                                  _statusButton(
                                    "Cancelled",
                                    order.orderId,
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
    );
  }

  Widget _statusButton(
    String status,
    String orderId,
  ) {
    return Builder(
      builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            await context
                .read<
                    AdminOrderController>()
                .updateOrderStatus(
                  orderId: orderId,
                  status:
                      status.toLowerCase(),
                );
          },
          child: Text(status),
        );
      },
    );
  }
}