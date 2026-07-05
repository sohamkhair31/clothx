import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../models/cart_model.dart';
import '../home/home_screen.dart' show NVColors, NVBreak, PremiumButton, ButtonVariant;

// =================================================================
// CHECKOUT SCREEN — built only on top of your existing backend
// =================================================================
// Uses (unmodified):
//   - CartController.cartItems / totalPrice / removeItem() /
//     increaseQuantity() / decreaseQuantity() / addToCart()
//   - AuthController.currentUser / currentUserData / updateProfile() /
//     getUserData()
//   - OrderController.placeOrder()  <-- ONE small addition here, see
//     order_controller.dart: an optional `paymentMethod` parameter
//     (defaults to 'Online', so anything already calling placeOrder()
//     without it behaves exactly as before). COD orders are written
//     with paymentStatus "Unpaid" instead of "Paid".
//
// INTEGRATION NOTES (search "ADJUST ME"):
//   1. Import paths assume this file lives at
//      lib/screens/checkout/checkout_screen.dart, mirroring how
//      new_arrivals_page.dart reaches home_screen.dart via '../home/...'.
//      Fix the 4 relative imports above if your layout differs.
//   2. Suggested route name is '/checkout' — same placeholder used in
//      quick_view.dart's `_kCheckoutRoute`.
//   3. OrderModel still has no address field — address is shown for
//      confirmation only, not persisted per-order (see prior note).
//   4. There's no real payment gateway wired in — choosing "Online"
//      just marks the order "Paid" immediately (same as before this
//      change); choosing "Cash on Delivery" marks it "Unpaid". Swap in
//      a real gateway call inside `_placeOrder` before `order.placeOrder`
//      when you're ready, without touching anything else here.
// =================================================================

enum _PaymentMethod { online, cod }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _placingOrder = false;
  _PaymentMethod _paymentMethod = _PaymentMethod.cod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUserData == null && auth.currentUser != null) {
        auth.getUserData();
      }
    });
  }

  void _showSnack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: NVColors.charcoal,
        content: Text(message, style: const TextStyle(color: Colors.white)),
        action: action,
      ),
    );
  }

  void _openEditAddressSheet() {
    final auth = context.read<AuthController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditAddressSheet(
        initialName: auth.currentUserData?.name ?? '',
        initialPhone: auth.currentUserData?.phone ?? '',
        initialAddress: auth.currentUserData?.address ?? '',
      ),
    );
  }

  void _removeItem(int index) {
    final cart = context.read<CartController>();
    final removed = cart.cartItems[index];

    cart.removeItem(index);

    _showSnack(
      'Removed ${removed.name}',
      action: SnackBarAction(
        label: 'UNDO',
        textColor: NVColors.gold,
        onPressed: () => cart.addToCart(removed),
      ),
    );
  }

  Future<void> _placeOrder() async {
    final auth = context.read<AuthController>();
    final cart = context.read<CartController>();
    final order = context.read<OrderController>();

    if (auth.currentUser == null) {
      _showSnack('Please log in to place an order');
      return;
    }
    if (cart.cartItems.isEmpty) {
      _showSnack('Your bag is empty');
      return;
    }
    if (auth.currentUserData == null || auth.currentUserData!.address.trim().isEmpty) {
      _showSnack('Please add a delivery address to continue');
      _openEditAddressSheet();
      return;
    }

    setState(() => _placingOrder = true);

    final success = await order.placeOrder(
      userId: auth.currentUser!.uid,
      items: List<CartModel>.from(cart.cartItems),
      totalAmount: cart.totalPrice,
      cartController: cart,
      paymentMethod: _paymentMethod == _PaymentMethod.online ? 'Online' : 'COD',
    );

    if (!mounted) return;
    setState(() => _placingOrder = false);

    if (success) {
      _showSnack('Order placed successfully');
      Navigator.of(context).maybePop();
    } else {
      _showSnack(order.errorMessage ?? 'Could not place order. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final auth = context.watch<AuthController>();
    final order = context.watch<OrderController>();

    return Scaffold(
      backgroundColor: NVColors.ivory,
      appBar: AppBar(
        backgroundColor: NVColors.white,
        elevation: 0,
        foregroundColor: NVColors.charcoal,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (cart.cartItems.isEmpty) {
              return _EmptyCartState(onShop: () => Navigator.of(context).maybePop());
            }

            final isMobile = NVBreak.isMobile(constraints.maxWidth);

            final summary = _OrderSummaryList(cart: cart, onRemove: _removeItem);
            final details = _CheckoutDetailsColumn(
              cart: cart,
              auth: auth,
              isPlacing: _placingOrder || order.isLoading,
              paymentMethod: _paymentMethod,
              onPaymentMethodChanged: (m) => setState(() => _paymentMethod = m),
              onEditAddress: _openEditAddressSheet,
              onPlaceOrder: _placeOrder,
            );

            if (isMobile) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [summary, const SizedBox(height: 24), details],
                ),
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 28, 20, 28),
                    child: summary,
                  ),
                ),
                Container(width: 1, color: NVColors.charcoal.withValues(alpha: 0.08)),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 32, 28),
                    child: details,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =================================================================
// ORDER SUMMARY — swipe to remove, inline qty stepper
// =================================================================

class _OrderSummaryList extends StatelessWidget {
  final CartController cart;
  final ValueChanged<int> onRemove;

  const _OrderSummaryList({required this.cart, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final items = cart.cartItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ORDER SUMMARY (${items.length})',
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: NVColors.charcoal,
              ),
            ),
            Text(
              'Swipe left to remove',
              style: TextStyle(fontSize: 11, color: NVColors.charcoal.withValues(alpha: 0.4)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 28),
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey('${item.productId}_${item.size}_$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              ),
              onDismissed: (_) => onRemove(index),
              child: _CheckoutItemTile(
                item: item,
                onIncrement: () => cart.increaseQuantity(index),
                onDecrement: () => cart.decreaseQuantity(index),
                onRemove: () => onRemove(index),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  final CartModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CheckoutItemTile({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 68,
            height: 82,
            child: item.image.isNotEmpty
                ? Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: NVColors.beige,
                      child: const Icon(Icons.checkroom_outlined, color: Colors.black26),
                    ),
                  )
                : Container(
                    color: NVColors.beige,
                    child: const Icon(Icons.checkroom_outlined, color: Colors.black26),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                  InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded, size: 16, color: Colors.black38),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                [
                  if (item.color.isNotEmpty) item.color,
                  if (item.size.isNotEmpty) 'Size ${item.size}',
                ].join(' · '),
                style: TextStyle(fontSize: 12, color: NVColors.charcoal.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QtyStepperMini(
                    quantity: item.quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                  const Spacer(),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: NVColors.gold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyStepperMini extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyStepperMini({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity > 1 ? onDecrement : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.remove, size: 14),
            ),
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(Icons.add, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// DELIVERY / PAYMENT / TOTAL / PLACE ORDER
// =================================================================

class _CheckoutDetailsColumn extends StatelessWidget {
  final CartController cart;
  final AuthController auth;
  final bool isPlacing;
  final _PaymentMethod paymentMethod;
  final ValueChanged<_PaymentMethod> onPaymentMethodChanged;
  final VoidCallback onEditAddress;
  final VoidCallback onPlaceOrder;

  const _CheckoutDetailsColumn({
    required this.cart,
    required this.auth,
    required this.isPlacing,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.onEditAddress,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final userData = auth.currentUserData;
    final hasAddress = userData != null && userData.address.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          title: 'DELIVERY DETAILS',
          trailing: TextButton(
            onPressed: onEditAddress,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              hasAddress ? 'Edit' : 'Add',
              style: const TextStyle(color: NVColors.gold, fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ),
          child: hasAddress
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData!.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(userData.phone,
                        style: TextStyle(fontSize: 13, color: NVColors.charcoal.withValues(alpha: 0.7))),
                    const SizedBox(height: 4),
                    Text(userData.address,
                        style: TextStyle(fontSize: 13, color: NVColors.charcoal.withValues(alpha: 0.7))),
                  ],
                )
              : Text(
                  'No delivery address on file. Add one to continue.',
                  style: TextStyle(fontSize: 13, color: NVColors.charcoal.withValues(alpha: 0.6)),
                ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'PAYMENT METHOD',
          child: Row(
            children: [
              Expanded(
                child: _PaymentOptionCard(
                  icon: Icons.credit_card_rounded,
                  label: 'Pay Online',
                  selected: paymentMethod == _PaymentMethod.online,
                  onTap: () => onPaymentMethodChanged(_PaymentMethod.online),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PaymentOptionCard(
                  icon: Icons.local_shipping_outlined,
                  label: 'Cash on Delivery',
                  selected: paymentMethod == _PaymentMethod.cod,
                  onTap: () => onPaymentMethodChanged(_PaymentMethod.cod),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'ORDER TOTAL',
          child: Column(
            children: [
              _priceRow('Subtotal', cart.totalPrice),
              const SizedBox(height: 8),
              _priceRow('Delivery', 0),
              const Divider(height: 26),
              _priceRow('Total', cart.totalPrice, bold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: PremiumButton(
            label: isPlacing
                ? 'Placing Order...'
                : paymentMethod == _PaymentMethod.online
                    ? 'Pay & Place Order'
                    : 'Place Order (COD)',
            variant: ButtonVariant.solid,
            onTap: isPlacing ? () {} : onPlaceOrder,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: NVColors.charcoal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: bold ? NVColors.gold : NVColors.charcoal,
          ),
        ),
      ],
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? NVColors.charcoal : NVColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? NVColors.charcoal : NVColors.charcoal.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: selected ? NVColors.gold : NVColors.charcoal),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : NVColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: NVColors.charcoal,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// =================================================================
// EMPTY CART STATE
// =================================================================

class _EmptyCartState extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCartState({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: NVColors.charcoal.withValues(alpha: 0.35)),
            const SizedBox(height: 18),
            const Text('Your bag is empty', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Add items to your bag before checking out.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: NVColors.charcoal.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 22),
            PremiumButton(
              label: 'Continue Shopping',
              variant: ButtonVariant.outline,
              small: true,
              onTap: onShop,
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// EDIT ADDRESS BOTTOM SHEET — uses AuthController.updateProfile()
// =================================================================

class _EditAddressSheet extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAddress;

  const _EditAddressSheet({
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
  });

  @override
  State<_EditAddressSheet> createState() => _EditAddressSheetState();
}

class _EditAddressSheetState extends State<_EditAddressSheet> {
  late final TextEditingController _nameCtrl = TextEditingController(text: widget.initialName);
  late final TextEditingController _phoneCtrl = TextEditingController(text: widget.initialPhone);
  late final TextEditingController _addressCtrl = TextEditingController(text: widget.initialAddress);
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _saving = true);

    final success = await context.read<AuthController>().updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );

    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.of(context).maybePop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save address. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: NVColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: NVColors.charcoal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text('Delivery Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              _field(_nameCtrl, 'Full Name'),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Delivery Address', maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: PremiumButton(
                  label: _saving ? 'Saving...' : 'Save Address',
                  variant: ButtonVariant.solid,
                  onTap: _saving ? () {} : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: NVColors.ivory,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}