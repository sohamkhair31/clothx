import 'package:clothx/screens/home/home_screen.dart';
import 'package:clothx/screens/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../core/theme/app_theme.dart';
import '../../controllers/product_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ScrollController _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // CACHE FIRST LOAD
      await context.read<ProductController>()
          .fetchProducts();
    });
  }

  void goNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BottomNavScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product =
        context.watch<ProductController>();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // HERO SECTION
                Container(
                  height:
                      MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: AppTheme.primary,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.checkroom,
                        size: 120,
                        color: AppTheme.white,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "ClothX",
                        style: AppTheme.logoText,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Wear your identity",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 60),

                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),

                // SECOND SECTION
                Container(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Explore Collections",
                        style: AppTheme.heading,
                      ),

                      const SizedBox(height: 20),

                      _buildSectionCard(
                        title: "Men Collection",
                        subtitle:
                            "Premium streetwear & essentials",
                      ),

                      const SizedBox(height: 20),

                      _buildSectionCard(
                        title: "Women Collection",
                        subtitle:
                            "Elegant styles & trendy fits",
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.isLoading
                              ? null
                              : goNext,
                          child: product.isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "Enter Store",
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.subHeading,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}