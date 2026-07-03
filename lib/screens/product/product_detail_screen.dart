import 'package:cached_network_image/cached_network_image.dart';
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

  String optimizeProductImage(
    String url,
  ) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_800/",
    );
  }

  String optimizeReviewImage(
    String url,
  ) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_300/",
    );
  }

  @override
  void initState() {
    super.initState();

    selectedSize =
        widget.product.sizes.first;

    Future.microtask(() async {
      await context
          .read<ReviewController>()
          .fetchReviews(
            widget.product.id,
          );
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
                    child:
                        CachedNetworkImage(
                      imageUrl:
                          optimizeProductImage(
                        product.images[index],
                      ),
                      fit: BoxFit.cover,
                      placeholder:
                          (
                            context,
                            url,
                          ) =>
                              const Center(
                        child:
                            CircularProgressIndicator(),
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
                                (
                                  context,
                                  index,
                                ) {
                              return Padding(
                                padding:
                                    const EdgeInsets.all(
                                  8,
                                ),
                                child:
                                    CachedNetworkImage(
                                  imageUrl:
                                      optimizeReviewImage(
                                    r.images[index],
                                  ),
                                  width:
                                      100,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (
                                        context,
                                        url,
                                      ) =>
                                          const SizedBox(
                                    width: 100,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(),
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