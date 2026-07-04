import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothx/controllers/admin_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/admin/admin_add_product_screen.dart';
import 'package:clothx/screens/admin/admin_edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminProductsScreen
    extends StatefulWidget {
  const AdminProductsScreen({
    super.key,
  });

  @override
  State<AdminProductsScreen>
      createState() =>
          _AdminProductsScreenState();
}

class _AdminProductsScreenState
    extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final admin =
          context.read<AdminController>();

      admin.loadAdminProductsFromCache();

      await admin.fetchAdminProducts();
    });
  }

  String optimizeImage(String url) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_200/",
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin =
        context.watch<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Manage Products"),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminAddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: admin.isLoading &&
              admin.adminProducts.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : admin.adminProducts.isEmpty
              ? Center(
                  child: Text(
                    "No products found",
                    style:
                        AppTheme.subHeading,
                  ),
                )
              : ListView.builder(
                  itemCount:
                      admin.adminProducts.length,
                  itemBuilder:
                      (context, index) {
                    final product =
                        admin.adminProducts[index];

                    return _productCard(
                      context,
                      product,
                    );
                  },
                ),
    );
  }

  Widget _productCard(
    BuildContext context,
    ProductModel product,
  ) {
    final admin =
        context.read<AdminController>();

    return Card(
      margin:
          const EdgeInsets.all(12),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                product.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        child:
                            CachedNetworkImage(
                          imageUrl:
                              optimizeImage(
                            product.images.first,
                          ),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          placeholder:
                              (
                                context,
                                url,
                              ) =>
                                  const SizedBox(
                            width: 70,
                            height: 70,
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
                      )
                    : const Icon(
                        Icons.image,
                      ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style:
                            AppTheme.subHeading,
                      ),
                      Text(
                        "₹${product.price}",
                      ),
                      Text(
                        "Stock: ${product.stock}",
                      ),
                      Text(
                        product.isActive
                            ? "Active"
                            : "Inactive",
                        style: TextStyle(
                          color:
                              product.isActive
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminEditProductScreen(
                            product:
                                product,
                          ),
                        ),
                      );
                    },
                    child:
                        const Text("Edit"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await admin
                          .toggleProductStatus(
                        productId:
                            product.id,
                        isActive:
                            !product.isActive,
                      );
                    },
                    child: Text(
                      product.isActive
                          ? "Deactivate"
                          : "Activate",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await admin
                          .deleteProduct(
                        product.id,
                      );
                    },
                    child:
                        const Text("Delete"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              keyboardType:
                  TextInputType.number,
              onSubmitted: (
                value,
              ) async {
                final stock =
                    int.tryParse(value);

                if (stock == null) return;

                await admin.updateStock(
                  productId:
                      product.id,
                  newStock: stock,
                );
              },
              decoration:
                  InputDecoration(
                hintText:
                    "Update Stock (${product.stock})",
              ),
            ),
          ],
        ),
      ),
    );
  }
}