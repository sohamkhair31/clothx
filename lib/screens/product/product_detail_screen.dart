import 'package:clothx/controllers/cart_controller.dart';
import 'package:clothx/controllers/review_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/models/cart_model.dart';
import 'package:clothx/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  String selectedSize = "";
  int quantity = 1;

  @override
  void initState() {
    super.initState();

    selectedSize =
        widget.product.sizes.first;

    Future.microtask(() async {
      await context
          .read<ReviewController>()
          .fetchReviews(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final review =
        context.watch<ReviewController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Images slider
            SizedBox(
              height: 320,
              child: PageView.builder(
                itemCount:
                    product.images.length,
                itemBuilder:
                    (context, index) {
                  return ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    child: Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product.name,
              style: AppTheme.heading,
            ),

            const SizedBox(height: 10),

            Text(
              "₹${product.price}",
              style:
                  AppTheme.subHeading,
            ),

            const SizedBox(height: 10),

            Text(
              product.description,
              style: AppTheme.body,
            ),

            const SizedBox(height: 20),

            Text(
              "Select Size",
              style:
                  AppTheme.subHeading,
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children:
                  product.sizes.map((size) {
                return ChoiceChip(
                  label: Text(size),
                  selected:
                      selectedSize ==
                          size,
                  onSelected: (_) {
                    setState(() {
                      selectedSize =
                          size;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Text(
              "Quantity",
              style:
                  AppTheme.subHeading,
            ),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  icon:
                      const Icon(Icons.remove),
                ),

                Text(quantity.toString()),

                IconButton(
                  onPressed: () {
                    if (quantity <
                        product.stock) {
                      setState(() {
                        quantity++;
                      });
                    }
                  },
                  icon:
                      const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await context
                      .read<
                          CartController>()
                      .addToCart(
                        CartModel(
                          productId:
                              product.id,
                          name:
                              product.name,
                          image: product
                              .images.first,
                          price:
                              product.price,
                          size:
                              selectedSize,
                          quantity:
                              quantity,
                        ),
                      );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Added to cart",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Add To Cart",
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Reviews",
              style: AppTheme.heading,
            ),

            const SizedBox(height: 20),

            if (review.isLoading)
              const Center(
                child:
                    CircularProgressIndicator(),
              ),

            if (!review.isLoading &&
                review.reviews.isEmpty)
              const Text(
                "No reviews yet",
              ),

            ...review.reviews.map((r) {
              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
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
                        r.userName,
                        style:
                            AppTheme.subHeading,
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "⭐ ${r.rating}",
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(r.comment),

                      if (r.images
                          .isNotEmpty)
                        SizedBox(
                          height: 100,
                          child:
                              ListView.builder(
                            scrollDirection:
                                Axis.horizontal,
                            itemCount:
                                r.images
                                    .length,
                            itemBuilder:
                                (context,
                                    index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.all(
                                  8,
                                ),
                                child:
                                    Image.network(
                                  r.images[
                                      index],
                                  width:
                                      100,
                                  fit: BoxFit
                                      .cover,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}