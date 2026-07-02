import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/controllers/admin_order_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/screens/admin/admin_analytics_screen.dart';
import 'package:clothx/screens/admin/admin_orders_screen.dart';
import 'package:clothx/screens/admin/admin_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen
    extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen>
      createState() =>
          _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final admin =
          context.read<AdminController>();

      final orders =
          context.read<AdminOrderController>();

      // CACHE FIRST
      admin.loadAdminProductsFromCache();
      orders.loadOrdersFromCache();

      // SERVER REFRESH
      await admin.fetchAdminProducts();
      await orders.fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin =
        context.watch<AdminController>();

    final order =
        context.watch<AdminOrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
        ),
      ),

      body: admin.isLoading &&
              order.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  _dashboardCard(
                    "Total Products",
                    admin.totalProducts
                        .toString(),
                  ),

                  _dashboardCard(
                    "Active Products",
                    admin.activeProducts
                        .toString(),
                  ),

                  _dashboardCard(
                    "Inactive Products",
                    admin.inactiveProducts
                        .toString(),
                  ),

                  _dashboardCard(
                    "Pending Orders",
                    order
                        .getPendingOrders()
                        .length
                        .toString(),
                  ),

                  _dashboardCard(
                    "Delivered Orders",
                    order
                        .getDeliveredOrders()
                        .length
                        .toString(),
                  ),

                  _dashboardCard(
                    "Cancelled Orders",
                    order
                        .getCancelledOrders()
                        .length
                        .toString(),
                  ),
SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AdminAnalyticsScreen(),
        ),
      );
    },
    child: const Text(
      "Analytics",
    ),
  ),
),
                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminProductsScreen(),
                          ),
                        );
                      },
                      child:
                          const Text(
                        "Manage Products",
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminOrdersScreen(),
                          ),
                        );
                      },
                      child:
                          const Text(
                        "Track Orders",
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _dashboardCard(
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