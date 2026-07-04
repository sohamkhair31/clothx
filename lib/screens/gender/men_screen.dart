import 'dart:ui';

import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/models/product_model.dart';
// Reusing the exact same design system (colors + breakpoints) as the
// Home Page and Orders screen so the whole app feels like one brand.
// If your Home Page file lives at a different path, update this import.
import 'package:clothx/screens/home/home_screen.dart' show NVColors, NVBreak;
import 'package:clothx/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Decorative editorial placeholder photography for this screen only.
/// Swap for real campaign assets before shipping — none of these feed
/// into business logic, they are purely cosmetic image sources.
class _MenImages {
  static const hero = 'https://picsum.photos/seed/nv-men-hero-main/1600/1100';
  static const promo = 'https://picsum.photos/seed/nv-men-promo-hoodie/1400/1000';

  static const categoryBanners = {
    'all': 'https://picsum.photos/seed/nv-men-cat-all/700/900',
    'hoodies': 'https://picsum.photos/seed/nv-men-cat-hoodie/700/900',
    'tshirts': 'https://picsum.photos/seed/nv-men-cat-tee/700/900',
    'shirts': 'https://picsum.photos/seed/nv-men-cat-shirt/700/900',
    'pants': 'https://picsum.photos/seed/nv-men-cat-pants/700/900',
  };

  static const trending = [
    ('New Drop', 'https://picsum.photos/seed/nv-men-trend-newdrop/900/700'),
    ('Limited Edition', 'https://picsum.photos/seed/nv-men-trend-limited/900/700'),
    ('Best Seller', 'https://picsum.photos/seed/nv-men-trend-bestseller/900/700'),
    ('Premium Collection', 'https://picsum.photos/seed/nv-men-trend-premium/900/700'),
  ];

  static const styleInspiration = [
    ('Urban Essentials', 'https://picsum.photos/seed/nv-men-style-urban/700/950'),
    ('Minimal Streetwear', 'https://picsum.photos/seed/nv-men-style-minimal/700/950'),
    ('Luxury Casual', 'https://picsum.photos/seed/nv-men-style-luxury/700/950'),
    ('Weekend Collection', 'https://picsum.photos/seed/nv-men-style-weekend/700/950'),
  ];
}

class MenScreen extends StatefulWidget {
  const MenScreen({super.key});

  @override
  State<MenScreen> createState() => _MenScreenState();
}

class _MenScreenState extends State<MenScreen> {
  // ---- business logic untouched ----
  String selectedCategory = "all";

  final List<String> categories = [
    "all",
    "hoodies",
    "tshirts",
    "shirts",
    "pants",
  ];

  // ------------------------------------------------------------------
  // Everything below is PURELY local, presentation-only UI state. It
  // only narrows/reveals what's already been fetched & filtered above;
  // it never calls the controller, model, or Firebase.
  // ------------------------------------------------------------------
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _searchOpen = false;
  final GlobalKey _productsKey = GlobalKey();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(String c) {
    switch (c) {
      case 'hoodies':
        return 'Hoodies';
      case 'tshirts':
        return 'T-Shirts';
      case 'shirts':
        return 'Shirts';
      case 'pants':
        return 'Pants';
      default:
        return 'All';
    }
  }

  IconData _categoryIcon(String c) {
    switch (c) {
      case 'hoodies':
        return Icons.checkroom_rounded;
      case 'tshirts':
        return Icons.dry_cleaning_outlined;
      case 'shirts':
        return Icons.style_outlined;
      case 'pants':
        return Icons.straighten_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  void _scrollToProducts() {
    final ctx = _productsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        categories: categories,
        selected: selectedCategory,
        labelBuilder: _categoryLabel,
        iconBuilder: _categoryIcon,
        onSelect: (c) {
          setState(() => selectedCategory = c);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final isLoading = context.watch<ProductController>().isLoading;

    // ---- business logic: identical filtering as the original screen ----
    List<ProductModel> menProducts = products.where((p) {
      return p.gender == "men" && p.isActive;
    }).toList();

    if (selectedCategory != "all") {
      menProducts = menProducts.where((p) {
        return p.category == selectedCategory;
      }).toList();
    }

    // ---- presentation-only extra narrowing of the already-filtered
    // list for the search box; no controller/API/Firebase call here ----
    final visibleProducts = _searchQuery.trim().isEmpty
        ? menProducts
        : menProducts
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final width = MediaQuery.of(context).size.width;
    final desktop = NVBreak.isDesktop(width);
    final cols = NVBreak.gridColumns(width);

    return Scaffold(
      backgroundColor: NVColors.ivoryWhite,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _MenHeader(
              width: width,
              searchController: _searchController,
              searchOpen: _searchOpen,
              onBack: () => Navigator.maybePop(context),
              onToggleSearch: () => setState(() => _searchOpen = !_searchOpen),
              onSearchChanged: (v) => setState(() => _searchQuery = v),
              onFilterTap: _openFilterSheet,
            ),
          ),
          SliverToBoxAdapter(
            child: _HeroBanner(width: width, onExplore: _scrollToProducts),
          ),
          SliverToBoxAdapter(
            child: _CategoryShowcase(
              width: width,
              categories: categories,
              selected: selectedCategory,
              labelBuilder: _categoryLabel,
              onSelect: (c) {
                setState(() => selectedCategory = c);
                _scrollToProducts();
              },
            ),
          ),
          SliverToBoxAdapter(child: _TrendingShowcase(width: width)),
          SliverToBoxAdapter(
            key: _productsKey,
            child: _ProductsSection(
              width: width,
              cols: cols,
              isLoading: isLoading,
              products: visibleProducts,
              categories: categories,
              selectedCategory: selectedCategory,
              labelBuilder: _categoryLabel,
              iconBuilder: _categoryIcon,
              onCategorySelect: (c) => setState(() => selectedCategory = c),
              onOpenProduct: (p) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _StyleInspiration(width: width)),
          SliverToBoxAdapter(child: _WhyChooseUs(width: width)),
          SliverToBoxAdapter(child: _PromoBanner(width: width)),
          SliverToBoxAdapter(child: _MenFooter(width: width)),
        ],
      ),
    );
  }
}

/// ============================================================
/// HEADER — rich-black hero header, matches Orders/Home nav language.
/// ============================================================
class _MenHeader extends StatelessWidget {
  final double width;
  final TextEditingController searchController;
  final bool searchOpen;
  final VoidCallback onBack;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;

  const _MenHeader({
    required this.width,
    required this.searchController,
    required this.searchOpen,
    required this.onBack,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    final hPad = NVBreak.hPad(width);

    return _FadeSlideIn(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: NVColors.richBlack,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MEN'S COLLECTION",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: NVColors.ivoryWhite,
                          fontSize: desktop ? 24 : 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Designed for Confidence. Crafted for Everyday Luxury.",
                        style: TextStyle(color: Colors.white54, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                _CircleIconButton(icon: Icons.tune_rounded, onTap: onFilterTap),
                const SizedBox(width: 10),
                _CircleIconButton(icon: Icons.search_rounded, onTap: onToggleSearch),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              child: searchOpen
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.16)),
                            ),
                            child: TextField(
                              controller: searchController,
                              autofocus: true,
                              onChanged: onSearchChanged,
                              style: const TextStyle(color: NVColors.ivoryWhite, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "Search men's products...",
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 13.5),
                                prefixIcon: Icon(Icons.search, color: NVColors.champagneGold, size: 20),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: NVColors.champagneGold, size: 16),
      ),
    );
  }
}

/// ============================================================
/// HERO BANNER
/// ============================================================
class _HeroBanner extends StatelessWidget {
  final double width;
  final VoidCallback onExplore;
  const _HeroBanner({required this.width, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    return _FadeSlideIn(
      child: Container(
        margin: EdgeInsets.fromLTRB(NVBreak.hPad(width), 20, NVBreak.hPad(width), 0),
        height: desktop ? 560 : 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _HoverZoomImage(url: _MenImages.hero),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    NVColors.richBlack.withOpacity(0.88),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 26,
              right: 26,
              bottom: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "THE MEN'S EDIT · 2026",
                          style: TextStyle(
                            color: NVColors.warmGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Oversized Ease.\nUnmistakable Edge.",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            fontSize: desktop ? 36 : 26,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _MenButton(label: "EXPLORE COLLECTION", filled: true, onTap: onExplore),
                      ],
                    ),
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

class _HoverZoomImage extends StatefulWidget {
  final String url;
  const _HoverZoomImage({required this.url});

  @override
  State<_HoverZoomImage> createState() => _HoverZoomImageState();
}

class _HoverZoomImageState extends State<_HoverZoomImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Image.network(widget.url, fit: BoxFit.cover),
      ),
    );
  }
}

/// ============================================================
/// CATEGORY SHOWCASE — only the categories that actually exist in
/// `categories` are shown, so every card maps to a real, working
/// filter instead of a dead end.
/// ============================================================
class _CategoryShowcase extends StatelessWidget {
  final double width;
  final List<String> categories;
  final String selected;
  final String Function(String) labelBuilder;
  final ValueChanged<String> onSelect;

  const _CategoryShowcase({
    required this.width,
    required this.categories,
    required this.selected,
    required this.labelBuilder,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);
    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading("SHOP BY CATEGORY"),
            const SizedBox(height: 20),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final banner = _MenImages.categoryBanners[c] ??
                      _MenImages.categoryBanners['all']!;
                  return _CategoryCard(
                    label: labelBuilder(c),
                    image: banner,
                    active: c == selected,
                    onTap: () => onSelect(c),
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

class _CategoryCard extends StatefulWidget {
  final String label;
  final String image;
  final bool active;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.label,
    required this.image,
    required this.active,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 130,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.active ? NVColors.champagneGold : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.image, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        NVColors.richBlack.withOpacity(widget.active ? 0.78 : 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 12,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.active ? NVColors.champagneGold : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (widget.active)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.check_circle_rounded, color: NVColors.champagneGold, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// TRENDING SHOWCASE — decorative marketing banners with pill badges.
/// ============================================================
class _TrendingShowcase extends StatelessWidget {
  final double width;
  const _TrendingShowcase({required this.width});

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);
    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading("TRENDING NOW"),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _MenImages.trending.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final entry = _MenImages.trending[i];
                  return _TrendingCard(label: entry.$1, image: entry.$2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingCard extends StatefulWidget {
  final String label;
  final String image;
  const _TrendingCard({required this.label, required this.image});

  @override
  State<_TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<_TrendingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 260,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [NVColors.richBlack.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: _MarketingBadge(label: widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketingBadge extends StatelessWidget {
  final String label;
  const _MarketingBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: NVColors.champagneGold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: NVColors.richBlack,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// ============================================================
/// PRODUCTS SECTION — the functional core. Reads straight from the
/// already gender+category-filtered `products` list passed in from
/// build(); no data logic lives in this widget.
/// ============================================================
class _ProductsSection extends StatelessWidget {
  final double width;
  final int cols;
  final bool isLoading;
  final List<ProductModel> products;
  final List<String> categories;
  final String selectedCategory;
  final String Function(String) labelBuilder;
  final IconData Function(String) iconBuilder;
  final ValueChanged<String> onCategorySelect;
  final ValueChanged<ProductModel> onOpenProduct;

  const _ProductsSection({
    required this.width,
    required this.cols,
    required this.isLoading,
    required this.products,
    required this.categories,
    required this.selectedCategory,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onCategorySelect,
    required this.onOpenProduct,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading("ALL MEN'S PRODUCTS"),
          const SizedBox(height: 20),

          // ---- functional category pills (identical filtering logic) ----
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final c = categories[i];
                final active = c == selectedCategory;
                return _CategoryPill(
                  label: labelBuilder(c),
                  icon: iconBuilder(c),
                  active: active,
                  onTap: () => onCategorySelect(c),
                );
              },
            ),
          ),
          const SizedBox(height: 26),

          if (isLoading && products.isEmpty)
            _ProductGridShimmer(cols: cols)
          else if (products.isEmpty)
            const _EmptyProductsState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, i) {
                final product = products[i];
                return _FadeSlideIn(
                  key: ValueKey(product.name + i.toString()),
                  delay: Duration(milliseconds: 40 * (i % 8)),
                  child: _LuxuryProductCard(
                    product: product,
                    onTap: () => onOpenProduct(product),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? NVColors.richBlack : NVColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? NVColors.richBlack : NVColors.cardBorderBeige,
          ),
          boxShadow: active
              ? [BoxShadow(color: NVColors.richBlack.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? NVColors.champagneGold : NVColors.graphite),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? NVColors.ivoryWhite : NVColors.richBlack,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _LuxuryProductCard({required this.product, required this.onTap});

  @override
  State<_LuxuryProductCard> createState() => _LuxuryProductCardState();
}

class _LuxuryProductCardState extends State<_LuxuryProductCard> {
  bool _hovered = false;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final lowStock = product.stock <= 5 && product.stock > 0;
    final outOfStock = product.stock <= 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: NVColors.cardWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: NVColors.cardBorderBeige, width: 1),
            boxShadow: [
              BoxShadow(
                color: NVColors.richBlack.withOpacity(_hovered ? 0.18 : 0.08),
                blurRadius: _hovered ? 26 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      scale: _hovered ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: product.images.isNotEmpty
                          ? Image.network(product.images.first, fit: BoxFit.cover)
                          : Container(
                              color: NVColors.ivoryWhite,
                              child: const Icon(Icons.image_outlined, color: NVColors.graphite),
                            ),
                    ),
                    if (lowStock || outOfStock)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (outOfStock ? const Color(0xFFA24C42) : NVColors.warmGold)
                                .withOpacity(0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            outOfStock ? "SOLD OUT" : "ONLY ${product.stock} LEFT",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _favorite = !_favorite),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white.withOpacity(0.85),
                          child: Icon(
                            _favorite ? Icons.favorite : Icons.favorite_border,
                            size: 15,
                            color: _favorite ? NVColors.warmGold : NVColors.graphite,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedSlide(
                        offset: _hovered ? Offset.zero : const Offset(0, 1),
                        duration: const Duration(milliseconds: 220),
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            color: NVColors.richBlack.withOpacity(0.88),
                            alignment: Alignment.center,
                            child: const Text(
                              "VIEW DETAILS",
                              style: TextStyle(
                                color: NVColors.ivoryWhite,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: NVColors.richBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${product.price}",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: NVColors.richBlack,
                      ),
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

class _ProductGridShimmer extends StatelessWidget {
  final int cols;
  const _ProductGridShimmer({required this.cols});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cols * 2,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, i) => const _ShimmerProductCard(),
    );
  }
}

class _ShimmerProductCard extends StatefulWidget {
  const _ShimmerProductCard();

  @override
  State<_ShimmerProductCard> createState() => _ShimmerProductCardState();
}

class _ShimmerProductCardState extends State<_ShimmerProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NVColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NVColors.dividerPlatinum),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _shimmerBlock(radius: 0)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBlock(height: 12, radius: 4),
                const SizedBox(height: 8),
                SizedBox(width: 60, child: _shimmerBlock(height: 12, radius: 4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBlock({double height = double.infinity, double radius = 6}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 3, 0),
              end: Alignment(0 + t * 3, 0),
              colors: const [Color(0xFFEDE7DC), Color(0xFFF7F3EC), Color(0xFFEDE7DC)],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: NVColors.sectionBeige),
            child: const Icon(Icons.search_off_rounded, size: 34, color: NVColors.warmGold),
          ),
          const SizedBox(height: 18),
          const Text(
            "No products found",
            style: TextStyle(color: NVColors.richBlack, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try a different category or search term.",
            style: TextStyle(color: NVColors.warmGray, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// STYLE INSPIRATION
/// ============================================================
class _StyleInspiration extends StatelessWidget {
  final double width;
  const _StyleInspiration({required this.width});

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);
    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 56, hPad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading("STYLE INSPIRATION"),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _MenImages.styleInspiration.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final entry = _MenImages.styleInspiration[i];
                  return _StyleCard(label: entry.$1, image: entry.$2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleCard extends StatefulWidget {
  final String label;
  final String image;
  const _StyleCard({required this.label, required this.image});

  @override
  State<_StyleCard> createState() => _StyleCardState();
}

class _StyleCardState extends State<_StyleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: Container(
          width: 180,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [NVColors.richBlack.withOpacity(0.75), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 14,
                child: Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// WHY CHOOSE US
/// ============================================================
class _WhyChooseUs extends StatelessWidget {
  final double width;
  const _WhyChooseUs({required this.width});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    final pillars = [
      (Icons.diamond_outlined, "Premium Fabric Quality"),
      (Icons.auto_awesome_outlined, "Modern Gen-Z Designs"),
      (Icons.local_shipping_outlined, "Fast Delivery"),
      (Icons.eco_outlined, "Sustainable Fashion"),
      (Icons.autorenew_outlined, "Easy Returns"),
      (Icons.support_agent_outlined, "Trusted Support"),
    ];

    return _FadeSlideIn(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 56),
        color: NVColors.sectionBeige,
        padding: EdgeInsets.symmetric(horizontal: NVBreak.hPad(width), vertical: 56),
        child: Column(
          children: [
            const Text(
              "WHY CHOOSE NEW VISION'S",
              style: TextStyle(color: NVColors.warmGold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 28,
              runSpacing: 26,
              alignment: WrapAlignment.center,
              children: pillars
                  .map((p) => SizedBox(
                        width: desktop ? 160 : 140,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: NVColors.cardWhite),
                              child: Icon(p.$1, color: NVColors.warmGold, size: 24),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: NVColors.richBlack, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// PROMO BANNER
/// ============================================================
class _PromoBanner extends StatelessWidget {
  final double width;
  const _PromoBanner({required this.width});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    return _FadeSlideIn(
      child: Container(
        margin: EdgeInsets.fromLTRB(NVBreak.hPad(width), 56, NVBreak.hPad(width), 0),
        height: desktop ? 480 : 400,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(_MenImages.promo, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, NVColors.richBlack.withOpacity(0.88)],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DISCOVER WHAT'S NEW",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontSize: desktop ? 28 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Fresh silhouettes, elevated fabrics, dropped weekly.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _MenButton(label: "EXPLORE NOW", filled: true, onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// FOOTER — same visual language as the Home Page footer.
/// ============================================================
class _MenFooter extends StatefulWidget {
  final double width;
  const _MenFooter({required this.width});

  @override
  State<_MenFooter> createState() => _MenFooterState();
}

class _MenFooterState extends State<_MenFooter> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(widget.width);
    final hPad = NVBreak.hPad(widget.width);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 56),
      color: NVColors.richBlack,
      padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: NVColors.graphite, borderRadius: BorderRadius.circular(20)),
            child: Flex(
              direction: desktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: desktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "Join the inner circle for early drops & exclusive access.",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: desktop ? 0 : 16, width: desktop ? 20 : 0),
                SizedBox(
                  width: desktop ? 300 : double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(color: NVColors.richBlack),
                          decoration: InputDecoration(
                            hintText: "Your email",
                            hintStyle: const TextStyle(color: NVColors.warmGray),
                            filled: true,
                            fillColor: NVColors.cardWhite,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: NVColors.inputBorderGray),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Subscribed!")));
                          _emailController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          decoration:
                              BoxDecoration(color: NVColors.cardBorderBeige, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.arrow_forward, color: NVColors.richBlack, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Text(
            "New Vision's",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: desktop ? 26 : 21,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: NVColors.ivoryWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fashion for a generation that dresses for itself.",
            style: TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 36,
            runSpacing: 22,
            children: const [
              _FooterColumn(title: "SHOP", items: ["New Arrivals", "Men", "Women", "Best Sellers"]),
              _FooterColumn(title: "SUPPORT", items: ["Track Order", "Returns", "Shipping Info", "FAQs"]),
              _FooterColumn(title: "COMPANY", items: ["About Us", "Careers", "Press"]),
              _FooterColumn(title: "CONTACT", items: ["support@newvisions.com", "Mumbai, India"]),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _socialIcon(Icons.camera_alt_outlined),
              _socialIcon(Icons.music_note_outlined),
              _socialIcon(Icons.chat_bubble_outline),
              _socialIcon(Icons.facebook_outlined),
            ],
          ),
          const Divider(color: Colors.white24, height: 40),
          const Text("© 2026 New Vision's. All rights reserved.", style: TextStyle(color: Colors.white38, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
      child: Icon(icon, color: NVColors.champagneGold, size: 17),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: NVColors.champagneGold, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
          const SizedBox(height: 10),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(e, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              )),
        ],
      ),
    );
  }
}

/// ============================================================
/// FILTER SHEET — same categories, same setState logic, just an
/// alternate mobile-friendly entry point.
/// ============================================================
class _FilterSheet extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final String Function(String) labelBuilder;
  final IconData Function(String) iconBuilder;
  final ValueChanged<String> onSelect;

  const _FilterSheet({
    required this.categories,
    required this.selected,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
        decoration: const BoxDecoration(
          color: NVColors.cardWhite,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(26), topRight: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: NVColors.dividerPlatinum, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const Text(
              "Filter by Category",
              style: TextStyle(fontFamily: 'Georgia', color: NVColors.richBlack, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            ...categories.map((c) {
              final active = c == selected;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onSelect(c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: active ? NVColors.richBlack : NVColors.sectionBeige,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(iconBuilder(c), size: 18, color: active ? NVColors.champagneGold : NVColors.graphite),
                        const SizedBox(width: 12),
                        Text(
                          labelBuilder(c),
                          style: TextStyle(
                            color: active ? NVColors.ivoryWhite : NVColors.richBlack,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        const Spacer(),
                        if (active) const Icon(Icons.check_rounded, color: NVColors.champagneGold, size: 18),
                      ],
                    ),
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

/// ============================================================
/// SHARED WIDGETS
/// ============================================================
class _SectionHeading extends StatelessWidget {
  final String text;
  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 30, height: 3, color: NVColors.warmGold),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(color: NVColors.richBlack, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _MenButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _MenButton({required this.label, required this.onTap, this.filled = true});

  @override
  State<_MenButton> createState() => _MenButtonState();
}

class _MenButtonState extends State<_MenButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: widget.filled ? NVColors.cardBorderBeige : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: widget.filled ? NVColors.cardBorderBeige : NVColors.champagneGold, width: 1.4),
            boxShadow: _hovered
                ? [BoxShadow(color: NVColors.champagneGold.withOpacity(0.55), blurRadius: 18, spreadRadius: 1)]
                : [],
          ),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.filled ? NVColors.richBlack : NVColors.warmGold,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fade + slide entrance with optional stagger delay — same visual
/// language used across the Home Page and Orders screen.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_fade);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}