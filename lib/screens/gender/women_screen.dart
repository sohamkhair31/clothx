import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() =>
      _WomenScreenState();
}

class _WomenScreenState
    extends State<WomenScreen> {
  String selectedCategory = "all";

  final List<String> categories = [
    "all",
    "hoodies",
    "tshirts",
    "shirts",
    "pants",
  ];

  @override
  Widget build(BuildContext context) {
    final products =
        context.watch<ProductController>().products;

    List<ProductModel> womenProducts =
        products.where((p) {
      return p.gender == "women" &&
          p.isActive;
    }).toList();

    if (selectedCategory != "all") {
      womenProducts =
          womenProducts.where((p) {
        return p.category ==
            selectedCategory;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Women Collection",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    categories.length,
                itemBuilder:
                    (context, index) {
                  final category =
                      categories[index];

                  final selected =
                      selectedCategory ==
                          category;

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 10,
                    ),
                    child: ChoiceChip(
                      label:
                          Text(category),
                      selected:
                          selected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory =
                              category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child:
                  womenProducts.isEmpty
                      ? const Center(
                          child: Text(
                            "No products found",
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              womenProducts.length,
                          itemBuilder:
                              (context,
                                  index) {
                            final product =
                                womenProducts[
                                    index];

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 16,
                              ),
                              child:
                                  ListTile(
                                leading:
                                    product.images
                                            .isNotEmpty
                                        ? Image.network(
                                            product.images.first,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.image,
                                          ),

                                title: Text(
                                  product.name,
                                ),

                                subtitle:
                                    Text(
                                  "₹${product.price}",
                                ),

                                trailing:
                                    Text(
                                  "Stock: ${product.stock}",
                                ),

                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              ProductDetailScreen(
                                        product:
                                            product,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}