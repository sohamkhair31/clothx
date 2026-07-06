import 'package:cached_network_image/cached_network_image.dart';
import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/cart_controller.dart';
import 'package:clothx/controllers/order_controller.dart';
import 'package:clothx/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Local palette: warm ivory ground, ink type, botanical green accent.
class _Palette {
  static const ivory = Color(0xFFF7F5F0);
  static const ink = Color(0xFF20241F);
  static const inkFaint = Color(0xFF6E7268);
  static const pine = Color(0xFF3B5941);
  static const pineTint = Color(0xFFE3EAE1);
  static const clay = Color(0xFFB2472E);
  static const clayTint = Color(0xFFF6E3DE);
  static const line = Color(0xFFE6E2D8);
  static const card = Color(0xFFFFFFFF);
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String _optimizeImage(String url) {
    if (!url.contains("/upload/")) return url;
    return url.replaceFirst("/upload/", "/upload/f_auto,q_auto,w_200/");
  }

  static const _swatches = {
    "black": Colors.black, "white": Colors.white,
    "red": Color(0xFFB2472E), "blue": Color(0xFF3B5F7A),
    "green": Color(0xFF3B5941), "grey": Colors.grey, "gray": Colors.grey,
    "beige": Color(0xFFD8CBB0), "navy": Color(0xFF232B3A),
    "brown": Color(0xFF6B4A34), "yellow": Color(0xFFCBA23A),
    "pink": Color(0xFFCE8B9A),
  };

  Color? _swatch(String colorName) => _swatches[colorName.trim().toLowerCase()];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final order = context.watch<OrderController>();
    final itemCount =
        cart.cartItems.fold<int>(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      backgroundColor: _Palette.ivory,
      appBar: AppBar(
        backgroundColor: _Palette.ivory,
        surfaceTintColor: _Palette.ivory,
        elevation: 0,
        foregroundColor: _Palette.ink,
        centerTitle: false,
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.1,
            color: _Palette.ink,
          ),
        ),
      ),
      body: cart.cartItems.isEmpty
          ? _EmptyCart(onBrowse: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            })
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        "$itemCount ${itemCount == 1 ? 'item' : 'items'}",
                        style: const TextStyle(
                          color: _Palette.inkFaint,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    itemCount: cart.cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.cartItems[index];
                      return _CartItemCard(
                        key: ValueKey("${item.productId}_${item.size}"),
                        item: item,
                        imageUrl: _optimizeImage(item.image),
                        swatch: _swatch(item.color),
                        onIncrease: () => cart.increaseQuantity(index),
                        onDecrease: () => cart.decreaseQuantity(index),
                        onRemove: () => cart.removeItem(index),
                      );
                    },
                  ),
                ),
                _CheckoutBar(
                  total: cart.totalPrice,
                  isLoading: order.isLoading,
                  onCheckout: () async {
                    if (auth.currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login required")),
                      );
                      return;
                    }

                    final success = await context
                        .read<OrderController>()
                        .placeOrder(
                          userId: auth.currentUser!.uid,
                          items: cart.cartItems,
                          totalAmount: cart.totalPrice,
                          cartController: cart,
                        );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? "Order placed successfully" : "Order failed",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: _Palette.pineTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: _Palette.pine,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _Palette.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Items you add will show up here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _Palette.inkFaint, fontSize: 13.5),
            ),
            const SizedBox(height: 22),
            TextButton(
              onPressed: onBrowse,
              style: TextButton.styleFrom(
                foregroundColor: _Palette.pine,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text(
                "Continue shopping",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }


class _CartItemCard extends StatelessWidget {
  final CartModel item;
  final String imageUrl;
  final Color? swatch;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    super.key,
    required this.item,
    required this.imageUrl,
    required this.swatch,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey("dismiss_${item.productId}_${item.size}"),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: _Palette.clayTint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: _Palette.clay),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _Palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Palette.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 84,
                  height: 84,
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
                  width: 84,
                  height: 84,
                  color: _Palette.pineTint,
                  child: const Icon(Icons.broken_image, color: _Palette.inkFaint),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _Palette.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Chip(label: "Size ${item.size}"),
                      const SizedBox(width: 6),
                      if (item.color.isNotEmpty)
                        _Chip(label: item.color, dot: swatch),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "₹${item.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: _Palette.pine,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _QuantityStepper(
              quantity: item.quantity,
              onIncrease: onIncrease,
              onDecrease: onDecrease,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? dot;
  const _Chip({required this.label, this.dot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _Palette.pineTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dot,
                shape: BoxShape.circle,
                border: Border.all(color: _Palette.line),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _Palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.pineTint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.add, onTap: onIncrease),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "$quantity",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: _Palette.ink,
              ),
            ),
          ),
          _StepperButton(icon: Icons.remove, onTap: onDecrease),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 15, color: _Palette.pine),
        ),
      );
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: _Palette.card,
        boxShadow: [
          BoxShadow(blurRadius: 16, color: Color(0x14000000), offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(color: _Palette.inkFaint, fontSize: 13.5),
                ),
                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: _Palette.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.pine,
                  disabledBackgroundColor: _Palette.pine.withOpacity(0.6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Checkout",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}