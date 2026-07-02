import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/cart/cart_screen.dart';
import 'package:clothx/screens/gender/men_screen.dart';
import 'package:clothx/screens/gender/women_screen.dart';
import 'package:clothx/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController =
        context.watch<ProductController>();

    final products = productController.products;

    final menProducts = products
        .where((p) => p.gender == "men")
        .toList();

    final womenProducts = products
        .where((p) => p.gender == "women")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ClothX"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "NEW COLLECTION 2026",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Shop By Category",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _categoryCard(
                    context,
                    "Men",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MenScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _categoryCard(
                    context,
                    "Women",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WomenScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              "Featured Products",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 20),

            ...products.take(6).map(
              (product) =>
                  _productCard(context, product),
            ),

            const SizedBox(height: 30),

            Text(
              "Men Picks",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 20),

            ...menProducts.take(3).map(
              (product) =>
                  _productCard(context, product),
            ),

            const SizedBox(height: 30),

            Text(
              "Women Picks",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 20),

            ...womenProducts.take(3).map(
              (product) =>
                  _productCard(context, product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTheme.subHeading,
          ),
        ),
      ),
    );
  }

  Widget _productCard(
    BuildContext context,
    ProductModel product,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: product.images.isNotEmpty
            ? Image.network(
                product.images.first,
                width: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),

        title: Text(product.name),

        subtitle: Text(
          "₹${product.price}",
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ProductDetailScreen(
                product: product,
              ),
            ),
          );
        },
      ),
    );
  }
}