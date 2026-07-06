import 'dart:async';

import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/controllers/wishlist_controller.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/home/profile_page.dart';
import 'package:clothx/screens/home/utils/color_utils.dart';
import 'package:clothx/screens/orders/quick_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart' show NVBreak, PremiumButton, ButtonVariant, HomeScreen;

/// =================================================================
/// NV'S — NEW ARRIVALS PAGE  (UI ONLY — single-file build)
/// =================================================================
/// This file is a pure presentation-layer redesign. It does not touch
/// any backend logic, controllers, models, Firebase calls, routing,
/// or state-management (Provider/Bloc/Riverpod/etc.) that may already
/// exist in your project.
///
/// INTEGRATION POINTS (search for "TODO(integration)"):
///   - Replace `_mockProducts()` with your real product stream/list
///     (e.g. from your ProductController / Firestore query).
///   - Replace `_onProductTap`, `_onAddToCart`, `_onToggleWishlist`,
///     and `_onQuickView` with your existing navigation/business logic.
///   - Wire `_loadMore()` to your real pagination (Firestore
///     startAfter / your existing controller's `fetchNextPage()`).
///
/// No new packages are required — everything (shimmer, staggered
/// fade/slide entrance, image loading states) is built with vanilla
/// Flutter widgets/animations.
/// =================================================================

// ---------------------------------------------------------------
// MODELS & ENUMS (UI-facing shape only — map your real model to this,
// or replace this class entirely with your existing Product model)
// ---------------------------------------------------------------
import 'package:clothx/models/product_model.dart';
enum SortOption { newest, bestSelling, priceLowHigh, priceHighLow }

extension on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.bestSelling:
        return 'Best Selling';
      case SortOption.priceLowHigh:
        return 'Price: Low to High';
      case SortOption.priceHighLow:
        return 'Price: High to Low';
    }
  }
}

// ---------------------------------------------------------------
// MOCK DATA — TODO(integration): remove this block once wired to
// your real data source.
// ---------------------------------------------------------------


const _swatchColors = [
  Colors.black,
  Color(0xFF3A3A3A),
  Color(0xFFB7A183),
  Colors.white,
  Color(0xFF3E4C59),
];


// =================================================================
// NEW ARRIVALS SCREEN
// =================================================================
class NewArrivalsScreen extends StatefulWidget {
  final String? gender;
  final bool isSearch;

  const NewArrivalsScreen({
        this.isSearch = false,
    super.key,
    this.gender,
  });

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
    TextEditingController();

Timer? _debounce;

String _searchQuery = "";
String get pageTitle {
  switch (widget.gender?.toLowerCase()) {
    case "male":
      return "MEN";

    case "female":
      return "WOMEN";

    default:
      return "NEW ARRIVALS";
  }
}
  // Data state
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
List<ProductModel> get _products =>
    context.watch<ProductController>().products;

  // Filter state
  RangeValues _priceRange = const RangeValues(0, 500);
  final Set<Color> _selectedColors = {};
  final Set<String> _selectedSizes = {};
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedBrands = {};
  bool _inStockOnly = false;
  double _minRating = 0;
  SortOption _sortOption = SortOption.newest;

@override
void initState() {
  super.initState();

WidgetsBinding.instance.addPostFrameCallback((_) async {
  final auth = context.read<AuthController>();
  final wishlist = context.read<WishlistController>();

  final uid = auth.currentUser?.uid;

  if (uid != null) {
    wishlist.loadFromCache(uid);
    await wishlist.syncWishlist(uid);
  }

  _loadInitial();
});
}

  @override
  void dispose() {
      _debounce?.cancel();
  _searchController.dispose();

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }
void _onSearchChanged(String value) {
  _debounce?.cancel();

  if (value.trim().length < 2) {
    setState(() {
      _searchQuery = "";
    });
    return;
  }

  _debounce = Timer(
    const Duration(milliseconds: 400),
    () async {
      _searchQuery = value.trim();

      await context
          .read<ProductController>()
          .searchProducts(
            _searchQuery,
            gender: widget.gender,
          );

      if (mounted) {
        setState(() {});
      }
    },
  );
}
Future<void> _loadInitial() async {
  final controller =
      context.read<ProductController>();

  controller.loadProductsFromCache();

  await controller.fetchProducts();

  if (!mounted) return;

  setState(() {
    _isInitialLoading = false;
  });
}
Future<void> _loadMore() async {
  // Pagination later.
}
  void _resetFilters() {
    setState(() {
      _priceRange = const RangeValues(0, 500);
      _selectedColors.clear();
      _selectedSizes.clear();
      _selectedCategories.clear();
      _selectedBrands.clear();
      _inStockOnly = false;
      _minRating = 0;
    });
  }

List<ProductModel> get _filteredProducts {
  final controller = context.watch<ProductController>();

  final sourceProducts = widget.isSearch
      ? controller.searchResults
      : _products;

  // ================= DEBUG =================
  print("========== FILTER DEBUG ==========");
  print("isSearch      : ${widget.isSearch}");
  print("Gender        : ${widget.gender}");
  print("Products      : ${_products.length}");
  print("SearchResults : ${controller.searchResults.length}");
  print("SourceProducts: ${sourceProducts.length}");
  print("==================================");
  // =========================================

  var list = sourceProducts.where((p) {
    // Gender filter
    if (widget.gender != null &&
        p.gender.toLowerCase() != widget.gender!.toLowerCase()) {
      return false;
    }

    // Price filter
    if (p.price < _priceRange.start ||
        p.price > _priceRange.end) {
      return false;
    }

    // Color filter
    if (_selectedColors.isNotEmpty &&
        !p.colors.any(
          (c) => _selectedColors.contains(
            colorFromName(c.name),
          ),
        )) {
      return false;
    }

    // Size filter
    if (_selectedSizes.isNotEmpty &&
        !p.sizes.any((s) => _selectedSizes.contains(s))) {
      return false;
    }

    // Category filter
    if (_selectedCategories.isNotEmpty &&
        !_selectedCategories.contains(p.category)) {
      return false;
    }

    // Stock filter
    if (_inStockOnly && p.stock <= 0) {
      return false;
    }

    return true;
  }).toList();

  print("Filtered Products : ${list.length}");

  switch (_sortOption) {
    case SortOption.newest:
      list.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      break;

    case SortOption.bestSelling:
      break;

    case SortOption.priceLowHigh:
      list.sort((a, b) => a.price.compareTo(b.price));
      break;

    case SortOption.priceHighLow:
      list.sort((a, b) => b.price.compareTo(a.price));
      break;
  }

  return list;
} // TODO(integration): hook these into your existing logic.
  void _onProductTap(ProductModel p) {}
  void _onAddToCart(ProductModel p) {}
  void _onToggleWishlist(ProductModel p) {}
  void _onQuickView(ProductModel p) {}

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterBottomSheet(
        priceRange: _priceRange,
        selectedColors: _selectedColors,
        selectedSizes: _selectedSizes,
        selectedCategories: _selectedCategories,
        selectedBrands: _selectedBrands,
        inStockOnly: _inStockOnly,
        minRating: _minRating,
        onApply: (priceRange, colors, sizes, categories, brands, inStock, rating) {
          setState(() {
            _priceRange = priceRange;
            _selectedColors
              ..clear()
              ..addAll(colors);
            _selectedSizes
              ..clear()
              ..addAll(sizes);
            _selectedCategories
              ..clear()
              ..addAll(categories);
            _selectedBrands
              ..clear()
              ..addAll(brands);
            _inStockOnly = inStock;
            _minRating = rating;
          });
        },
        onReset: _resetFilters,
      ),
    );
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NVColors.ivory,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = NVBreak.isMobile(width);
            final isTablet = NVBreak.isTablet(width);
            final showSidebar = !isMobile;

            return Column(
              children: [
_TopBar(
  isMobile: isMobile,
  gender: widget.gender,
  isSearch: widget.isSearch,
  searchController: _searchController,
  onSearchChanged: _onSearchChanged,
  onFilterTap: _openFilterSheet,
),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSidebar)
                        SizedBox(
                          width: isTablet ? 240 : 288,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 28, 12, 40),
                            child: _FilterPanelContent(
                              priceRange: _priceRange,
                              selectedColors: _selectedColors,
                              selectedSizes: _selectedSizes,
                              selectedCategories: _selectedCategories,
                              selectedBrands: _selectedBrands,
                              inStockOnly: _inStockOnly,
                              minRating: _minRating,
                              onPriceChanged: (v) =>
                                  setState(() => _priceRange = v),
                              onColorToggled: (c) => setState(() {
  _selectedColors.contains(c)
      ? _selectedColors.remove(c)
      : _selectedColors.add(c);
}),
                              onSizeToggled: (s) => setState(() {
                                _selectedSizes.contains(s)
                                    ? _selectedSizes.remove(s)
                                    : _selectedSizes.add(s);
                              }),
                              onCategoryToggled: (c) => setState(() {
                                _selectedCategories.contains(c)
                                    ? _selectedCategories.remove(c)
                                    : _selectedCategories.add(c);
                              }),
                              onBrandToggled: (_) {},
                              onInStockChanged: (v) =>
                                  setState(() => _inStockOnly = v),
                              onRatingChanged: (v) =>
                                  setState(() => _minRating = v),
                              onReset: _resetFilters,
                            ),
                          ),
                        ),
                      if (showSidebar)
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: NVColors.charcoal.withValues(alpha: 0.08),
                        ),
                      Expanded(
                        child: 
                        _ProductArea(
  title: widget.gender == null
      ? "NEW ARRIVALS"
      : widget.gender!.toLowerCase() == "men"
          ? "MEN COLLECTION"
          : "WOMEN COLLECTION",
                          isMobile: isMobile,
                          isTablet: isTablet,
                          isInitialLoading: _isInitialLoading,
                          isLoadingMore: _isLoadingMore,
                          products: _filteredProducts,
                          sortOption: _sortOption,
                          scrollController: _scrollController,
                          onSortChanged: (v) => setState(() => _sortOption = v),
                          onFilterTap: _openFilterSheet,
                          onResetFilters: _resetFilters,
                          onProductTap: _onProductTap,
                          onAddToCart: _onAddToCart,
                          onToggleWishlist: _onToggleWishlist,
                          onQuickView: _onQuickView,
                        ),
                      ),
                    ],
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
// TOP BAR — brand centered, nav right (desktop), filter+menu (mobile)
// =================================================================
class _TopBar extends StatelessWidget {
  final bool isMobile;
  final bool isSearch;
  final String? gender;
  final VoidCallback onFilterTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _TopBar({
    super.key,
    required this.isMobile,
    required this.onFilterTap,
    this.gender, required this.isSearch, required this.searchController, required this.onSearchChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 14 : 20,
      ),
      decoration: BoxDecoration(
        color: NVColors.white,
        border: Border(
          bottom: BorderSide(
            color: NVColors.charcoal.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered brand wordmark
isSearch
    ? SizedBox(
        width: isMobile ? double.infinity : 420,
        child: TextField(
          controller: searchController,
          autofocus: true,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      )
    : Text(
        "NV's",
            style: TextStyle(
              color: NVColors.charcoal,
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 20 : 24,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: filter icon (mobile) or small logo mark (desktop)
              isMobile
                  ? _CircleIconButton(
                      icon: Icons.tune_rounded,
                      onTap: onFilterTap,
                      tooltip: 'Filters',
                    )
                  : Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: NVColors.charcoal),
                          ),
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: NVColors.charcoal,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
              // Right: nav links (desktop) or search+menu (mobile)
              isMobile
                  ? Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.search_rounded,
                          onTap: () {
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => NewArrivalsScreen(
      isSearch: true,
      gender: gender,
    ),
  ),
);
                          },
                          tooltip: 'Search',
                        ),
                        const SizedBox(width: 8),
                        _CircleIconButton(
  icon: Icons.menu_rounded,
  onTap: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
ListTile(
  title: const Text("New Arrivals"),
  onTap: () {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(),
      ),
    );
  },
),
ListTile(
  title: const Text("Men"),
  onTap: () {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(
          gender: "men",
        ),
      ),
    );
  },
),
ListTile(
  title: const Text("Women"),
  onTap: () {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(
          gender: "women",
        ),
      ),
    );
  },
),
            ],
          ),
        );
      },
    );
  },
  tooltip: 'Menu',
),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children:  [
_NavItem(
  label: 'NEW ARRIVALS',
  active: gender == null,
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(),
      ),
    );
  },
),

_NavItem(
  label: 'Men',
  active: gender == "men",
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(
          gender: "men",
        ),
      ),
    );
  },
),

_NavItem(
  label: 'Women',
  active: gender == "women",
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NewArrivalsScreen(
          gender: "women",
        ),
      ),
    );
  },
),

_NavItem(
  label: 'Account',
 onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountPage()
      ),
    );
  },
),

_NavItem(
  label: 'Search',
  icon: Icons.search_rounded,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewArrivalsScreen(
          isSearch: true,
          gender: gender,
        ),
      ),
    );
  },
),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
    this.onTap,
  });
  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active
        ? NVColors.gold
        : (_hover ? NVColors.charcoal : NVColors.charcoal.withValues(alpha: 0.7));
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
  onTap: widget.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: color),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, size: 18, color: NVColors.charcoal),
        ),
      ),
    );
  }
}

// =================================================================
// PRODUCT AREA — breadcrumb, sort bar, grid/shimmer/empty-state
// =================================================================
class _ProductArea extends StatelessWidget {
  final String title;

  final bool isMobile;
  final bool isTablet;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final List<ProductModel> products;
  final SortOption sortOption;
  final ScrollController scrollController;
  final ValueChanged<SortOption> onSortChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onResetFilters;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;
  final ValueChanged<ProductModel> onToggleWishlist;
  final ValueChanged<ProductModel> onQuickView;

  const _ProductArea({
    required this.title,
    required this.isMobile,
    required this.isTablet,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.products,
    required this.sortOption,
    required this.scrollController,
    required this.onSortChanged,
    required this.onFilterTap,
    required this.onResetFilters,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onQuickView,
  });

  int get _columns {
    // Handled precisely in the grid via LayoutBuilder, this is a fallback.
    if (isMobile) return 2;
    if (isTablet) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final hPad = isMobile ? 16.0 : 32.0;

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, isMobile ? 14 : 24, hPad, 0),
          sliver: SliverToBoxAdapter(
            child: _Breadcrumb(
  isMobile: isMobile,
  title: title,
),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 0),
          sliver: SliverToBoxAdapter(
            child:
_SortBar(
  title: title,
  isMobile: isMobile,
              count: products.length,
              sortOption: sortOption,
              onSortChanged: onSortChanged,
              onFilterTap: onFilterTap,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
          sliver: isInitialLoading
              ? _ShimmerGridSliver(columns: _columns)
              : products.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyState(onReset: onResetFilters),
                    )
                  : _ProductGridSliver(
                      products: products,
                      onProductTap: onProductTap,
                      onAddToCart: onAddToCart,
                      onToggleWishlist: onToggleWishlist,
                      onQuickView: onQuickView,
                    ),
        ),
        if (!isInitialLoading && products.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Center(
                child: isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: NVColors.gold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}
class _Breadcrumb extends StatelessWidget {
  final bool isMobile;
  final String title;

  const _Breadcrumb({
    super.key,
    required this.isMobile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 12.5,
      color: NVColors.charcoal.withValues(alpha: 0.55),
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: [
InkWell(
  borderRadius: BorderRadius.circular(4),
  onTap: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  },
  child: Text(
    'Home',
    style: baseStyle.copyWith(
      decoration: TextDecoration.underline,
    ),
  ),
),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right_rounded,
              size: 16, color: NVColors.charcoal.withValues(alpha: 0.4)),
        ),
        Text(
title,
          style: baseStyle.copyWith(
            color: NVColors.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SortBar extends StatelessWidget {
  final String title;
  final bool isMobile;
  final int count;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortChanged;
  final VoidCallback onFilterTap;

  const _SortBar({
    required this.title,
    required this.isMobile,
    required this.count,
    required this.sortOption,
    required this.onSortChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
                title,

              style: TextStyle(
                color: NVColors.charcoal,
                fontSize: isMobile ? 20 : 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SORT ROW (separate widget so it sits neatly under the title)
// =================================================================
class _SortRow extends StatelessWidget {
  final int count;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortChanged;
  final bool isMobile;
  final VoidCallback onFilterTap;

  const _SortRow({
    required this.count,
    required this.sortOption,
    required this.onSortChanged,
    required this.isMobile,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$count products',
            style: TextStyle(
              color: NVColors.charcoal.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isMobile)
          _CircleIconButton(
            icon: Icons.tune_rounded,
            onTap: onFilterTap,
            tooltip: 'Filters',
          ),
        const SizedBox(width: 10),
        _SortDropdown(value: sortOption, onChanged: onSortChanged),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final SortOption value;
  final ValueChanged<SortOption> onChanged;
  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.18)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: NVColors.charcoal.withValues(alpha: 0.7)),
          style: TextStyle(
            color: NVColors.charcoal,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: SortOption.values
              .map((o) => DropdownMenuItem(value: o, child: Text(o.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// =================================================================
// PRODUCT GRID (sliver)
// =================================================================
class _ProductGridSliver extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;
  final ValueChanged<ProductModel> onToggleWishlist;
  final ValueChanged<ProductModel> onQuickView;

  const _ProductGridSliver({
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onQuickView,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        int columns;
        if (width < 560) {
          columns = 2;
        } else if (width < 820) {
          columns = 3;
        } else if (width < 1180) {
          columns = 4;
        } else {
          columns = 5;
        }
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 22,
            crossAxisSpacing: 18,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final p = products[index];
              return _StaggeredEntrance(
                index: index,
                child: _ProductCard(
                  product: p,
                  onTap: () => onProductTap(p),
                  onAddToCart: () => onAddToCart(p),
                  onToggleWishlist: () => onToggleWishlist(p),
                  onQuickView: () => onQuickView(p),
                ),
              );
            },
            childCount: products.length,
          ),
        );
      },
    );
  }
}

/// Staggered fade + slide entrance for grid items.
class _StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredEntrance({required this.index, required this.child});

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 40 * (widget.index % 12));
    Future.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// =================================================================
// PRODUCT CARD
// =================================================================
class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final VoidCallback onQuickView;

  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.onQuickView,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hover = false;
  String? _selectedSize;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
final auth = context.read<AuthController>();

final wishlistController =
    context.watch<WishlistController>();

final uid = auth.currentUser?.uid;

final isWishlisted =
    wishlistController.isWishlisted(p.id);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
  onTap: () {
    QuickView.show(context, widget.product);
  },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          decoration: BoxDecoration(
            color: NVColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: NVColors.charcoal.withValues(alpha: _hover ? 0.14 : 0.05),
                blurRadius: _hover ? 24 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Image + overlays ----
              AspectRatio(
                aspectRatio: 0.82,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hover ? 1.06 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: Image.network(
                          p.colors.first.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(color: NVColors.beige);
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: NVColors.beige,
                            child: const Icon(Icons.image_outlined,
                                color: Colors.black26),
                          ),
                        ),
                      ),
                      if (DateTime.now().difference(p.createdAt).inDays <= 30)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _Badge(label: 'NEW'),
                        ),
                      if (p.stock <= 0)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _Badge(
                            label: 'SOLD OUT',
                            background: NVColors.charcoal.withValues(alpha: 0.85),
                          ),
                        ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child:_GlassCircleButton(
  icon: isWishlisted
      ? Icons.favorite_rounded
      : Icons.favorite_border_rounded,
  iconColor: isWishlisted
      ? Colors.red
      : NVColors.charcoal,
  onTap: () async {
    if (uid == null) return;

    await wishlistController.toggleWishlist(
      uid,
      p.id,
    );

    widget.onToggleWishlist();
  },
),
                      ),
                      // Quick view — fades in on hover (desktop) and stays
                      // subtly visible via a small always-on affordance
                      // on touch devices.
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: AnimatedOpacity(
                          opacity: _hover ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !_hover,
                            child: 
                            _QuickViewButton(
  onTap: () {
    QuickView.show(context, widget.product);
  },
),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- Details ----
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: NVColors.charcoal,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${p.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: NVColors.gold,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        /// compare at removed
                    
                    ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: p.sizes
                                .map((s) => _SizeChip(
                                      label: s,
                                      selected: _selectedSize == s,
                                      onTap: () => setState(
                                          () => _selectedSize = s),
                                    ))
                                .toList(),
                          ),
                        ),
                        _GlassCircleButton(
                          icon: Icons.shopping_bag_outlined,
                          iconColor: NVColors.charcoal,
                          small: true,
                          filled: true,
                          onTap: widget.onAddToCart,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: p.colors
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _ColorDot(color: colorFromName(c.name),),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

class _Badge extends StatelessWidget {
  final String label;
  final Color? background;
  const _Badge({required this.label, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? NVColors.gold,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool small;
  final bool filled;

  const _GlassCircleButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.small = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = small ? 34.0 : 36.0;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? NVColors.beige : Colors.white.withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: small ? 15 : 17, color: iconColor),
      ),
    );
  }
}

class _QuickViewButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickViewButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NVColors.charcoal.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text(
          'QUICK VIEW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
class _SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 24,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? NVColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? NVColors.charcoal
                : NVColors.charcoal.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : NVColors.charcoal.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});
  @override
  Widget build(BuildContext context) {
    final isLight = color.computeLuminance() > 0.7;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isLight ? NVColors.charcoal.withValues(alpha: 0.2) : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }
}

// =================================================================
// SHIMMER LOADING PLACEHOLDERS
// =================================================================
class _ShimmerGridSliver extends StatelessWidget {
  final int columns;
  const _ShimmerGridSliver({required this.columns});

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        int cols;
        if (width < 560) {
          cols = 2;
        } else if (width < 820) {
          cols = 3;
        } else if (width < 1180) {
          cols = 4;
        } else {
          cols = 5;
        }
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 22,
            crossAxisSpacing: 18,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => const _ShimmerCard(),
            childCount: cols * 3,
          ),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: _Shimmer(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Shimmer(height: 10, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: _Shimmer(
                            height: 12, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _Shimmer(height: 22, borderRadius: BorderRadius.circular(6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dependency-free shimmer sweep built with a looping gradient.
class _Shimmer extends StatefulWidget {
  final double? height;
  final BorderRadius borderRadius;
  const _Shimmer({this.height, required this.borderRadius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: ShaderMask(
              shaderCallback: (bounds) {
                final t = _controller.value;
                return LinearGradient(
                  begin: Alignment(-1 + 3 * t, 0),
                  end: Alignment(0 + 3 * t, 0),
                  colors: [
                    NVColors.beige.withValues(alpha: 0.7),
                    NVColors.beige.withValues(alpha: 0.25),
                    NVColors.beige.withValues(alpha: 0.7),
                  ],
                ).createShader(bounds);
              },
              child: Container(color: NVColors.beige.withValues(alpha: 0.6)),
            ),
          ),
        );
      },
    );
  }
}

// =================================================================
// EMPTY STATE
// =================================================================
class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: NVColors.beige.withValues(alpha: 0.5),
            ),
            child: Icon(Icons.search_off_rounded,
                size: 32, color: NVColors.charcoal.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'No products match your filters',
            style: TextStyle(
              color: NVColors.charcoal,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting or resetting your filters to see more results.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NVColors.charcoal.withValues(alpha: 0.55),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 24),
          PremiumButton(
            label: 'Reset Filters',
            variant: ButtonVariant.outline,
            small: true,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

// =================================================================
// FILTER PANEL (shared content — used by sidebar & bottom sheet)
// =================================================================
class _FilterPanelContent extends StatelessWidget {
  final RangeValues priceRange;
  final Set<Color> selectedColors;
  final Set<String> selectedSizes;
  final Set<String> selectedCategories;
  final Set<String> selectedBrands;
  final bool inStockOnly;
  final double minRating;

  final ValueChanged<RangeValues> onPriceChanged;
  final ValueChanged<Color> onColorToggled;
  final ValueChanged<String> onSizeToggled;
  final ValueChanged<String> onCategoryToggled;
  final ValueChanged<String> onBrandToggled;
  final ValueChanged<bool> onInStockChanged;
  final ValueChanged<double> onRatingChanged;
  final VoidCallback onReset;

  const _FilterPanelContent({
    required this.priceRange,
    required this.selectedColors,
    required this.selectedSizes,
    required this.selectedCategories,
    required this.selectedBrands,
    required this.inStockOnly,
    required this.minRating,
    required this.onPriceChanged,
    required this.onColorToggled,
    required this.onSizeToggled,
    required this.onCategoryToggled,
    required this.onBrandToggled,
    required this.onInStockChanged,
    required this.onRatingChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FILTERS',
              style: TextStyle(
                color: NVColors.charcoal,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                foregroundColor: NVColors.gold,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _FilterSection(
          title: 'Price',
          child: Column(
            children: [
              RangeSlider(
                values: priceRange,
                min: 0,
                max: 500,
                divisions: 25,
                activeColor: NVColors.gold,
                inactiveColor: NVColors.charcoal.withValues(alpha: 0.12),
                labels: RangeLabels(
                  '\$${priceRange.start.round()}',
                  '\$${priceRange.end.round()}',
                ),
                onChanged: onPriceChanged,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${priceRange.start.round()}',
                      style: _labelStyle()),
                  Text('\$${priceRange.end.round()}', style: _labelStyle()),
                ],
              ),
            ],
          ),
        ),
        _FilterSection(
          title: 'Color',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _swatchColors.map((c) {
              final selected = selectedColors.contains(c);
              final isLight = c.computeLuminance() > 0.7;
              return InkWell(
                onTap: () => onColorToggled(c),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    border: Border.all(
                      color: selected
                          ? NVColors.gold
                          : (isLight
                              ? NVColors.charcoal.withValues(alpha: 0.2)
                              : Colors.transparent),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded,
                          size: 14,
                          color: isLight ? NVColors.charcoal : Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        _FilterSection(
          title: 'Size',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((s) {
              final selected = selectedSizes.contains(s);
              return _FilterChip(
                label: s,
                selected: selected,
                onTap: () => onSizeToggled(s),
              );
            }).toList(),
          ),
        ),
        _FilterSection(
          title: 'Category',
          child: Column(
            children: const [
  "tshirt",
  "hoodie",
  "shirt",
]
                .map(
                  (c) => _CheckRow(
                    label: c,
                    checked: selectedCategories.contains(c),
                    onTap: () => onCategoryToggled(c),
                  ),
                )
                .toList(),
          ),
        ),
        _FilterSection(
          title: 'Availability',
          child: _CheckRow(
            label: 'In Stock Only',
            checked: inStockOnly,
            onTap: () => onInStockChanged(!inStockOnly),
          ),
        ),
        _FilterSection(
          title: 'Ratings',
          child: Column(
            children: [4.0, 3.0, 2.0].map((r) {
              final selected = minRating == r;
              return _CheckRow(
                label: '${r.toInt()}+ Stars',
                checked: selected,
                icon: Icons.star_rounded,
                onTap: () => onRatingChanged(selected ? 0 : r),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  TextStyle _labelStyle() => TextStyle(
        fontSize: 11.5,
        color: NVColors.charcoal.withValues(alpha: 0.6),
        fontWeight: FontWeight.w600,
      );
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _FilterSection({required this.title, required this.child,});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(
            color: NVColors.charcoal,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        initiallyExpanded: true,
        iconColor: NVColors.charcoal,
        collapsedIconColor: NVColors.charcoal.withValues(alpha: 0.6),
        children: [child],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? NVColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? NVColors.charcoal
                : NVColors.charcoal.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : NVColors.charcoal,
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;
  final IconData icon;
  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
    this.icon = Icons.check_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? NVColors.charcoal : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: checked
                      ? NVColors.charcoal
                      : NVColors.charcoal.withValues(alpha: 0.3),
                ),
              ),
              child: checked
                  ? Icon(icon, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: NVColors.charcoal.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// MOBILE FILTER BOTTOM SHEET
// =================================================================
class _FilterBottomSheet extends StatefulWidget {
  final RangeValues priceRange;
  final Set<Color> selectedColors;
  final Set<String> selectedSizes;
  final Set<String> selectedCategories;
  final Set<String> selectedBrands;
  final bool inStockOnly;
  final double minRating;
  final void Function(
    RangeValues priceRange,
    Set<Color> colors,
    Set<String> sizes,
    Set<String> categories,
    Set<String> brands,
    bool inStock,
    double rating,
  ) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    required this.priceRange,
    required this.selectedColors,
    required this.selectedSizes,
    required this.selectedCategories,
    required this.selectedBrands,
    required this.inStockOnly,
    required this.minRating,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late RangeValues _priceRange = widget.priceRange;
  late final Set<Color> _colors = {...widget.selectedColors};
  late final Set<String> _sizes = {...widget.selectedSizes};
  late final Set<String> _categories = {...widget.selectedCategories};
  late final Set<String> _brands = {...widget.selectedBrands};
  late bool _inStock = widget.inStockOnly;
  late double _rating = widget.minRating;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: NVColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: NVColors.charcoal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _FilterPanelContent(
                    priceRange: _priceRange,
                    selectedColors: _colors,
                    selectedSizes: _sizes,
                    selectedCategories: _categories,
                    selectedBrands: _brands,
                    inStockOnly: _inStock,
                    minRating: _rating,
                    onPriceChanged: (v) => setState(() => _priceRange = v),
                    onColorToggled: (c) => setState(() {
                      _colors.contains(c) ? _colors.remove(c) : _colors.add(c);
                    }),
                    onSizeToggled: (s) => setState(() {
                      _sizes.contains(s) ? _sizes.remove(s) : _sizes.add(s);
                    }),
                    onCategoryToggled: (c) => setState(() {
                      _categories.contains(c)
                          ? _categories.remove(c)
                          : _categories.add(c);
                    }),
onBrandToggled: (_) {},
                    onInStockChanged: (v) => setState(() => _inStock = v),
                    onRatingChanged: (v) => setState(() => _rating = v),
                    onReset: () => setState(() {
                      _priceRange = const RangeValues(0, 500);
                      _colors.clear();
                      _sizes.clear();
                      _categories.clear();
                      _brands.clear();
                      _inStock = false;
                      _rating = 0;
                    }),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      label: 'Apply Filters',
                      variant: ButtonVariant.solid,
                      onTap: () {
                        widget.onApply(
                          _priceRange,
                          _colors,
                          _sizes,
                          _categories,
                          _brands,
                          _inStock,
                          _rating,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}