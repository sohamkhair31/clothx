import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/controllers/wishlist_controller.dart';
import 'package:clothx/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Same design system as CartScreen: ivory ground, ink type, pine accent —
// plus a blush/rose accent used only for the heart, since wishlist is an
// emotional action while pine is reserved for commerce actions (cart/checkout).
class _Palette {
  static const ivory = Color(0xFFF7F5F0);
  static const ink = Color(0xFF20241F);
  static const inkFaint = Color(0xFF6E7268);
  static const pine = Color(0xFF3B5941);
  static const pineTint = Color(0xFFE3EAE1);
  static const rose = Color(0xFFC65B6C);
  static const roseTint = Color(0xFFF7E4E7);
  static const line = Color(0xFFE6E2D8);
  static const card = Colors.white;
}

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthController>().currentUser?.uid;
      if (userId == null) return;

      final wishlist = context.read<WishlistController>();
      wishlist.loadFromCache(userId);
      wishlist.syncWishlist(userId);
    });
  }

  String _optimizeImage(String url) {
    if (!url.contains("/upload/")) return url;
    return url.replaceFirst("/upload/", "/upload/f_auto,q_auto,w_260/");
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final wishlist = context.watch<WishlistController>();
    final products = context.watch<ProductController>().products;

    final userId = auth.currentUser?.uid;

    // Resolve full product info for each wishlisted id, preserving order.
    final wishlistProducts = <ProductModel>[];
    for (final w in wishlist.items) {
      ProductModel? match;
      for (final p in products) {
        if (p.id == w.productId) {
          match = p;
          break;
        }
      }
      if (match != null) wishlistProducts.add(match);
    }

    return Scaffold(
      backgroundColor: _Palette.ivory,
      appBar: AppBar(
        backgroundColor: _Palette.ivory,
        surfaceTintColor: _Palette.ivory,
        elevation: 0,
        foregroundColor: _Palette.ink,
        centerTitle: false,
        title: const Text(
          "Wishlist",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: _Palette.ink,
          ),
        ),
      ),
      body: userId == null
          ? const _LoggedOutState()
          : wishlist.isLoading && wishlistProducts.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: _Palette.pine),
                )
              : wishlistProducts.isEmpty
                  ? const _EmptyWishlist()
                  : RefreshIndicator(
                      color: _Palette.pine,
                      onRefresh: () => wishlist.syncWishlist(userId),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: wishlistProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemBuilder: (context, index) {
                          final product = wishlistProducts[index];
                          return _WishlistCard(
                            product: product,
                            imageUrl: product.colors.isNotEmpty
                                ? _optimizeImage(product.colors.first.image)
                                : "",
                            onRemove: () async {
                              final success = await wishlist.toggleWishlist(
                                userId,
                                product.id,
                              );
                              if (!context.mounted || success) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Couldn't remove item"),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _LoggedOutState extends StatelessWidget {
  const _LoggedOutState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          "Log in to see your wishlist",
          style: TextStyle(color: _Palette.inkFaint, fontSize: 14),
        ),
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: _Palette.roseTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 36,
                color: _Palette.rose,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your wishlist is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _Palette.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Tap the heart on any item to save it here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _Palette.inkFaint, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final ProductModel product;
  final String imageUrl;
  final VoidCallback onRemove;

  const _WishlistCard({
    required this.product,
    required this.imageUrl,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palette.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: _Palette.pineTint,
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _Palette.pine,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: _Palette.pineTint,
                    child: const Icon(
                      Icons.broken_image,
                      color: _Palette.inkFaint,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _HeartButton(onTap: onRemove),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: _Palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _Palette.pine,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HeartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.favorite, size: 16, color: _Palette.rose),
        ),
      ),
    );
  }
}