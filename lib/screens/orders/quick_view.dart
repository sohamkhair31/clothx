import 'package:clothx/controllers/cart_controller.dart';
import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/models/cart_model.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


// ============================================================================
// QUICK VIEW — Luxury Boutique Redesign for ClothX
// ============================================================================
//
// Zero changes to ProductModel / CartModel / CartController / ProductController
// / AuthController / repositories / cache / navigation / theme / product card.
// This file is fully self-contained and only *reads* from your existing
// controllers and models.
//
// USAGE (from your product card / product screen):
//
//    QuickView.show(context, product);
//
// TWO THINGS TO DOUBLE-CHECK FOR YOUR PROJECT (search "ADJUST ME"):
//   1. Import paths above assume this file lives at `lib/widgets/quick_view.dart`
//      with `models/` and `controllers/` as siblings of `widgets/` under `lib/`.
//      If your folder layout differs, just fix these 4 import lines.
//   2. `_kCheckoutRoute` below — point it at your real checkout route name.
//
// Everything else (Provider access to CartController / ProductController)
// matches the ChangeNotifier + Provider pattern already used across your
// controllers, so no additional wiring should be required.
// ============================================================================

/// ADJUST ME: point this at your real checkout route.
const String _kCheckoutRoute = '/checkout';

/// Local palette matching the boutique design system already used across
/// ClothX admin screens (Rich Black / Ivory White / Graphite / Warm Gray /
/// Warm Gold / Champagne Gold). Defined locally so this file never depends
/// on your theme file's exact class/constant names — swap these for your
/// real AppColors constants any time without touching layout logic.
class _Palette {
  static const Color richBlack = Color(0xFF0D0D0D);
  static const Color ivory = Color(0xFFFAF7F2);
  static const Color graphite = Color(0xFF2B2B2B);
  static const Color warmGray = Color(0xFF8C8578);
  static const Color warmGold = Color(0xFFB08D57);
  static const Color champagne = Color(0xFFE9DCC3);
}

const String _kSerifFont = 'PlayfairDisplay';

// ============================================================================
// PUBLIC ENTRY POINT
// ============================================================================

class QuickView {
  QuickView._();

  static Future<void> show(BuildContext context, ProductModel product) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.55),
        builder: (_) => _QuickViewMobileSheet(initialProduct: product),
      );
    }

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'quick-view',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: Center(
              child: _QuickViewDesktopDialog(initialProduct: product),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// DESKTOP / TABLET — centered dialog, max width 900, two-column layout
// ============================================================================

class _QuickViewDesktopDialog extends StatelessWidget {
  final ProductModel initialProduct;
  const _QuickViewDesktopDialog({required this.initialProduct});

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final width = screen.width < 940 ? screen.width * 0.94 : 900.0;
    final height = screen.height * 0.86;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 780),
        decoration: BoxDecoration(
          color: _Palette.ivory,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 44,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _QuickViewBody(initialProduct: initialProduct, isDesktop: true),
      ),
    );
  }
}

// ============================================================================
// MOBILE — draggable bottom sheet
// ============================================================================

class _QuickViewMobileSheet extends StatelessWidget {
  final ProductModel initialProduct;
  const _QuickViewMobileSheet({required this.initialProduct});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _Palette.ivory,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: _Palette.warmGray.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _QuickViewBody(
                  initialProduct: initialProduct,
                  isDesktop: false,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// CORE BODY — shared state + logic for both layouts
// ============================================================================

class _QuickViewBody extends StatefulWidget {
  final ProductModel initialProduct;
  final bool isDesktop;
  final ScrollController? scrollController;

  const _QuickViewBody({
    required this.initialProduct,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  State<_QuickViewBody> createState() => _QuickViewBodyState();
}

class _QuickViewBodyState extends State<_QuickViewBody> {
  late ProductModel product;
  late final PageController _pageController;

  int selectedColorIndex = 0;
  String? selectedSize;
  int quantity = 1;
  bool detailsExpanded = false;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    product = widget.initialProduct;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _switchToProduct(ProductModel newProduct) {
    setState(() {
      product = newProduct;
      selectedColorIndex = 0;
      selectedSize = null;
      quantity = 1;
      detailsExpanded = false;
      isWishlisted = false;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _selectColor(int index) {
    setState(() => selectedColorIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _incrementQty() {
    if (quantity < product.stock) {
      setState(() => quantity++);
    }
  }

  void _decrementQty() {
    if (quantity > 1) {
      setState(() => quantity--);
    }
  }

  bool _validateSelection() {
    if (product.stock <= 0) {
      _toast('This item is out of stock');
      return false;
    }
    if (product.sizes.isNotEmpty && selectedSize == null) {
      _toast('Please select a size');
      return false;
    }
    return true;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _Palette.richBlack,
        content: Text(
          message,
          style: const TextStyle(color: _Palette.ivory),
        ),
      ),
    );
  }

  CartModel _buildCartItem() {
    final hasColors = product.colors.isNotEmpty;
    return CartModel(
      productId: product.id,
      name: product.name,
      image: hasColors ? product.colors[selectedColorIndex].image : '',
      color: hasColors ? product.colors[selectedColorIndex].name : '',
      price: product.price,
      size: selectedSize ?? (product.sizes.isNotEmpty ? product.sizes.first : ''),
      quantity: quantity,
    );
  }

  Future<void> _addToCart({bool silent = false}) async {
    if (!_validateSelection()) return;
    final cartController = context.read<CartController>();
    await cartController.addToCart(_buildCartItem());
    if (!silent) _toast('Added to bag');
  }

  Future<void> _buyNow() async {
    if (!_validateSelection()) return;
    await _addToCart(silent: true);
    if (!mounted) return;
Navigator.of(context, rootNavigator: true).pop();

Navigator.of(
  context,
  rootNavigator: true,
).push(
  MaterialPageRoute(
    builder: (_) => const CheckoutScreen(),
  ),
);
  }

  void _share() {
    Clipboard.setData(
      ClipboardData(text: 'Check out ${product.name} on ClothX'),
    );
    _toast('Link copied to clipboard');
  }

  void _openFullscreen(int initialIndex) {
    final images = product.colors.map((c) => c.image).toList();
    if (images.isEmpty) return;
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenImageViewer(
          images: images,
          initialIndex: initialIndex,
          heroPrefix: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktop) {
      return Column(
        children: [
          _Header(
            isWishlisted: isWishlisted,
            onWishlist: () => setState(() => isWishlisted = !isWishlisted),
            onShare: _share,
            onClose: () => Navigator.of(context).maybePop(),
          ),
          const Divider(height: 1, color: Color(0x14000000)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _ImageSection(
                    product: product,
                    pageController: _pageController,
                    selectedIndex: selectedColorIndex,
                    onPageChanged: (i) => setState(() => selectedColorIndex = i),
                    onTapImage: _openFullscreen,
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0x14000000)),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
                    child: _InfoColumn(
                      product: product,
                      selectedColorIndex: selectedColorIndex,
                      selectedSize: selectedSize,
                      quantity: quantity,
                      detailsExpanded: detailsExpanded,
                      onSelectColor: _selectColor,
                      onSelectSize: (s) => setState(() => selectedSize = s),
                      onIncrement: _incrementQty,
                      onDecrement: _decrementQty,
                      onToggleDetails: () =>
                          setState(() => detailsExpanded = !detailsExpanded),
                      onAddToCart: () => _addToCart(),
                      onBuyNow: _buyNow,
                      onSelectRelated: _switchToProduct,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ---- Mobile: single scrollable column ----
    return Column(
      children: [
        _Header(
          isWishlisted: isWishlisted,
          onWishlist: () => setState(() => isWishlisted = !isWishlisted),
          onShare: _share,
          onClose: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _ImageSection(
                      product: product,
                      pageController: _pageController,
                      selectedIndex: selectedColorIndex,
                      onPageChanged: (i) => setState(() => selectedColorIndex = i),
                      onTapImage: _openFullscreen,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _InfoColumn(
                  product: product,
                  selectedColorIndex: selectedColorIndex,
                  selectedSize: selectedSize,
                  quantity: quantity,
                  detailsExpanded: detailsExpanded,
                  onSelectColor: _selectColor,
                  onSelectSize: (s) => setState(() => selectedSize = s),
                  onIncrement: _incrementQty,
                  onDecrement: _decrementQty,
                  onToggleDetails: () =>
                      setState(() => detailsExpanded = !detailsExpanded),
                  onAddToCart: () => _addToCart(),
                  onBuyNow: _buyNow,
                  onSelectRelated: _switchToProduct,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HEADER — close / wishlist / share
// ============================================================================

class _Header extends StatelessWidget {
  final bool isWishlisted;
  final VoidCallback onWishlist;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const _Header({
    required this.isWishlisted,
    required this.onWishlist,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          _HeaderIconButton(icon: Icons.close_rounded, onTap: onClose),
          const Spacer(),
          _HeaderIconButton(
            icon: isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            iconColor: isWishlisted ? Colors.redAccent : _Palette.graphite,
            onTap: onWishlist,
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(icon: Icons.ios_share_rounded, onTap: onShare),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = _Palette.graphite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _Palette.champagne.withOpacity(0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }
}

// ============================================================================
// IMAGE SECTION — carousel + indicator + pinch zoom + fullscreen tap
// ============================================================================

class _ImageSection extends StatelessWidget {
  final ProductModel product;
  final PageController pageController;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onTapImage;

  const _ImageSection({
    required this.product,
    required this.pageController,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = product.colors;

    if (colors.isEmpty) {
      return Container(
        color: _Palette.champagne.withOpacity(0.3),
        child: const Center(
          child: Icon(Icons.checkroom_rounded, size: 64, color: _Palette.warmGray),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: _Palette.champagne.withOpacity(0.25)),
        PageView.builder(
          controller: pageController,
          itemCount: colors.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            final img = colors[index].image;
            return GestureDetector(
              onTap: () => onTapImage(index),
              child: Hero(
                tag: 'quickview-${product.id}-$index',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: _NetworkOrPlaceholder(url: img),
                ),
              ),
            );
          },
        ),
        if (colors.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(colors.length, (i) {
                final active = i == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? _Palette.warmGold : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _NetworkOrPlaceholder extends StatelessWidget {
  final String url;
  const _NetworkOrPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 48, color: _Palette.warmGray),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: _Palette.warmGold),
          ),
        );
      },
      errorBuilder: (context, error, stack) => const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 48, color: _Palette.warmGray),
      ),
    );
  }
}

// ============================================================================
// FULLSCREEN PREVIEW
// ============================================================================

class _FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroPrefix;

  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
    required this.heroPrefix,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Hero(
                  tag: 'quickview-${widget.heroPrefix}-$index',
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: _NetworkOrPlaceholder(url: widget.images[index]),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _HeaderIconButton(
                icon: Icons.close_rounded,
                iconColor: Colors.white,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INFO COLUMN — name/price/colors/sizes/qty/buttons/details/related
// ============================================================================

class _InfoColumn extends StatelessWidget {
  final ProductModel product;
  final int selectedColorIndex;
  final String? selectedSize;
  final int quantity;
  final bool detailsExpanded;
  final ValueChanged<int> onSelectColor;
  final ValueChanged<String> onSelectSize;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onToggleDetails;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final ValueChanged<ProductModel> onSelectRelated;

  const _InfoColumn({
    required this.product,
    required this.selectedColorIndex,
    required this.selectedSize,
    required this.quantity,
    required this.detailsExpanded,
    required this.onSelectColor,
    required this.onSelectSize,
    required this.onIncrement,
    required this.onDecrement,
    required this.onToggleDetails,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onSelectRelated,
  });

  String _availabilityText() {
    if (product.stock <= 0) return 'Out of stock';
    if (product.stock <= 5) return 'Only ${product.stock} left';
    return 'In stock';
  }

  Color _availabilityColor() {
    if (product.stock <= 0) return Colors.redAccent;
    if (product.stock <= 5) return Colors.orangeAccent;
    return const Color(0xFF3E8E5A);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: _Palette.warmGray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: const TextStyle(
            fontFamily: _kSerifFont,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _Palette.richBlack,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.gender.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: _Palette.warmGray,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _Palette.warmGold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _availabilityColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _availabilityText(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _availabilityColor(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (product.description.isNotEmpty)
          Text(
            product.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: _Palette.graphite.withOpacity(0.85),
            ),
          ),
        const SizedBox(height: 22),

        if (product.colors.isNotEmpty) ...[
          _SectionLabel('Color', value: product.colors[selectedColorIndex].name),
          const SizedBox(height: 10),
          _ColorSelector(
            colors: product.colors,
            selectedIndex: selectedColorIndex,
            onSelect: onSelectColor,
          ),
          const SizedBox(height: 22),
        ],

        if (product.sizes.isNotEmpty) ...[
          _SectionLabel('Size', value: selectedSize ?? 'Select a size'),
          const SizedBox(height: 10),
          _SizeSelector(
            sizes: product.sizes,
            selected: selectedSize,
            onSelect: onSelectSize,
          ),
          const SizedBox(height: 22),
        ],

        _SectionLabel('Quantity'),
        const SizedBox(height: 10),
        _QuantitySelector(
          quantity: quantity,
          stock: product.stock,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
        const SizedBox(height: 26),

        _ActionButtons(
          stock: product.stock,
          onAddToCart: onAddToCart,
          onBuyNow: onBuyNow,
          onViewDetails: onToggleDetails,
        ),
        const SizedBox(height: 22),

        _DetailsExpansion(product: product, expanded: detailsExpanded, onToggle: onToggleDetails),
        const SizedBox(height: 26),

        _RelatedProducts(currentProduct: product, onSelect: onSelectRelated),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? value;
  const _SectionLabel(this.label, {this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: _Palette.graphite,
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: _Palette.warmGray),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// COLOR SELECTOR
// ============================================================================

class _ColorSelector extends StatelessWidget {
  final List<ProductColor> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ColorSelector({
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const Map<String, Color> _named = {
    'black': Colors.black,
    'white': Colors.white,
    'ivory': _Palette.ivory,
    'cream': Color(0xFFFFFDD0),
    'beige': Color(0xFFF5F5DC),
    'khaki': Color(0xFFC3B091),
    'gray': Colors.grey,
    'grey': Colors.grey,
    'charcoal': Color(0xFF36454F),
    'red': Colors.red,
    'maroon': Color(0xFF800000),
    'pink': Colors.pink,
    'orange': Colors.orange,
    'mustard': Color(0xFFFFDB58),
    'yellow': Colors.yellow,
    'olive': Color(0xFF708238),
    'green': Colors.green,
    'teal': Colors.teal,
    'navy': Color(0xFF001F3F),
    'blue': Colors.blue,
    'purple': Colors.purple,
    'brown': Colors.brown,
    'gold': _Palette.warmGold,
    'champagne': _Palette.champagne,
  };

  Color? _resolve(String name) => _named[name.trim().toLowerCase()];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(colors.length, (index) {
        final c = colors[index];
        final resolved = _resolve(c.name);
        final selected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? _Palette.warmGold : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: resolved != null
                  ? Container(
                      color: resolved,
                      child: resolved == Colors.white
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: _Palette.warmGray.withOpacity(0.3)),
                              ),
                            )
                          : null,
                    )
                  : (c.image.isNotEmpty
                      ? Image.network(
                          c.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _Palette.champagne,
                            child: const Icon(Icons.checkroom, size: 16, color: _Palette.warmGray),
                          ),
                        )
                      : Container(color: _Palette.champagne)),
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// SIZE SELECTOR
// ============================================================================

class _SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SizeSelector({required this.sizes, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: sizes.map((size) {
        final active = size == selected;
        return GestureDetector(
          onTap: () => onSelect(size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active ? _Palette.richBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? _Palette.richBlack : _Palette.warmGray.withOpacity(0.5),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              size,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? _Palette.ivory : _Palette.graphite,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// QUANTITY SELECTOR
// ============================================================================

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.stock,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = stock <= 0;
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _Palette.warmGray.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _qtyButton(Icons.remove, disabled || quantity <= 1 ? null : onDecrement),
            SizedBox(
              width: 40,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            _qtyButton(Icons.add, disabled || quantity >= stock ? null : onIncrement),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 16, color: _Palette.richBlack),
      ),
    );
  }
}

// ============================================================================
// ACTION BUTTONS
// ============================================================================

class _ActionButtons extends StatelessWidget {
  final int stock;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onViewDetails;

  const _ActionButtons({
    required this.stock,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = stock <= 0;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: disabled ? null : onBuyNow,
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.warmGold,
              disabledBackgroundColor: _Palette.warmGray.withOpacity(0.4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text('BUY NOW', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: disabled ? null : onAddToCart,
            style: OutlinedButton.styleFrom(
              foregroundColor: _Palette.richBlack,
              side: BorderSide(color: _Palette.richBlack.withOpacity(disabled ? 0.3 : 1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('ADD TO CART', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onViewDetails,
          style: TextButton.styleFrom(foregroundColor: _Palette.graphite),
          child: const Text('VIEW DETAILS', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.6)),
        ),
      ],
    );
  }
}

// ============================================================================
// EXPANDABLE PRODUCT DETAILS
// ============================================================================

class _DetailsExpansion extends StatelessWidget {
  final ProductModel product;
  final bool expanded;
  final VoidCallback onToggle;

  const _DetailsExpansion({required this.product, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _Palette.warmGray.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Product Details',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.description.isNotEmpty) ...[
                          Text(
                            product.description,
                            style: TextStyle(fontSize: 13, height: 1.5, color: _Palette.graphite.withOpacity(0.85)),
                          ),
                          const SizedBox(height: 12),
                        ],
                        _detailRow('Category', product.category),
                        _detailRow('Gender', product.gender),
                        _detailRow('Stock', '${product.stock} units'),
                        _detailRow('Product ID', product.id),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(fontSize: 12, color: _Palette.warmGray)),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RELATED PRODUCTS
// ============================================================================

class _RelatedProducts extends StatelessWidget {
  final ProductModel currentProduct;
  final ValueChanged<ProductModel> onSelect;

  const _RelatedProducts({required this.currentProduct, required this.onSelect});

  List<ProductModel> _pickRelated(List<ProductModel> all) {
    final others = all.where((p) => p.id != currentProduct.id).toList();
    final sameCategory =
        others.where((p) => p.category.toLowerCase() == currentProduct.category.toLowerCase()).toList();
    final rest =
        others.where((p) => p.category.toLowerCase() != currentProduct.category.toLowerCase()).toList();
    return [...sameCategory, ...rest].take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    final related = _pickRelated(productController.products);

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOU MAY ALSO LIKE',
          style: TextStyle(fontSize: 11, letterSpacing: 1.4, fontWeight: FontWeight.w700, color: _Palette.graphite),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final p = related[index];
              final image = p.colors.isNotEmpty ? p.colors.first.image : '';
              return GestureDetector(
                onTap: () => onSelect(p),
                child: SizedBox(
                  width: 116,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 116,
                          height: 116,
                          child: _NetworkOrPlaceholder(url: image),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${p.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12, color: _Palette.warmGold, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}