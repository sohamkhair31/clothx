import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/controllers/admin_order_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminAnalyticsScreen
    extends StatelessWidget {
  const AdminAnalyticsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final admin =
        context.watch<AdminController>();

    final orders =
        context.watch<AdminOrderController>();

    final totalRevenue =
        orders.orders.fold(
      0.0,
      (sum, order) =>
          sum + order.totalAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Analytics"),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              "Total Revenue",
              "₹$totalRevenue",
            ),

            _card(
              "Total Orders",
              orders.orders.length
                  .toString(),
            ),

            _card(
              "Pending Orders",
              orders
                  .getPendingOrders()
                  .length
                  .toString(),
            ),

            _card(
              "Delivered Orders",
              orders
                  .getDeliveredOrders()
                  .length
                  .toString(),
            ),

            _card(
              "Cancelled Orders",
              orders
                  .getCancelledOrders()
                  .length
                  .toString(),
            ),

            _card(
              "Total Products",
              admin.totalProducts
                  .toString(),
            ),

            _card(
              "Active Products",
              admin.activeProducts
                  .toString(),
            ),

            _card(
              "Inactive Products",
              admin.inactiveProducts
                  .toString(),
            ),

            _card(
              "Low Stock",
              admin
                  .getLowStockProducts()
                  .length
                  .toString(),
            ),

            _card(
              "Out Of Stock",
              admin
                  .getOutOfStockProducts()
                  .length
                  .toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    String title,
    String value,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTheme.subHeading,
        ),
        trailing: Text(
          value,
          style: AppTheme.heading,
        ),
      ),
    );
  }
}