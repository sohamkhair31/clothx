import 'dart:ui';

import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/models/product_model.dart';
// Reusing the exact same design system (colors + breakpoints) as the
// Home Page, Orders screen and Men's Collection screen so the whole
// app feels like one brand. Update this import if your Home Page file
// lives at a different path.
import 'package:clothx/screens/home/home_screen.dart' show NVColors, NVBreak;
import 'package:clothx/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WomenScreen extends StatefulWidget {
  const WomenScreen({super.key});

  @override
  State<WomenScreen> createState() => _WomenScreenState();
}

class _WomenScreenState extends State<WomenScreen> {
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
  // ADDED: these were referenced by the header (searchOpen,
  // searchController, _searchQuery, onBack/onFilterTap/onToggleSearch/
  // onSearchChanged) but never declared anywhere in the pasted file.
  // Purely local, presentation-only UI state — same pattern as the
  // Orders screen's search box. Never touches the controller/API.
  // ------------------------------------------------------------------
  bool searchOpen = false;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ---- ADDED: presentation-only display label/icon per category key.
  // Referenced by _ProductsSection / _SeasonalEditShowcase but not
  // defined anywhere in the pasted file. Doesn't alter filtering logic.
  String _categoryLabel(String c) {
    switch (c) {
      case "all":
        return "All";
      case "hoodies":
        return "Hoodies";
      case "tshirts":
        return "T-Shirts";
      case "shirts":
        return "Shirts";
      case "pants":
        return "Pants";
      default:
        return c.isEmpty ? c : c[0].toUpperCase() + c.substring(1);
    }
  }

  IconData _categoryIcon(String c) {
    switch (c) {
      case "all":
        return Icons.grid_view_rounded;
      case "hoodies":
        return Icons.checkroom_rounded;
      case "tshirts":
        return Icons.dry_cleaning_rounded;
      case "shirts":
        return Icons.checkroom_rounded;
      case "pants":
        return Icons.accessibility_new_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductController>().products;
    final isLoading = context.watch<ProductController>().isLoading;

    // ---- business logic: identical filtering as the original screen ----
    List<ProductModel> womenProducts = products.where((p) {
      return p.gender == "women" && p.isActive;
    }).toList();

    if (selectedCategory != "all") {
      womenProducts = womenProducts.where((p) {
        return p.category == selectedCategory;
      }).toList();
    }

    // ---- presentation-only extra narrowing of the already-filtered
    // list for the search box; no controller/API/Firebase call here ----
    final visibleProducts = _searchQuery.trim().isEmpty
        ? womenProducts
        : womenProducts
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final width = MediaQuery.of(context).size.width;
    final desktop = NVBreak.isDesktop(width);
    final cols = NVBreak.gridColumns(width);

    // ------------------------------------------------------------------
    // ADDED: build() previously only ever returned the header — the
    // Hero banner, Seasonal Edit, Editor's Picks and Products sections
    // below were fully built but never called from anywhere. Wiring
    // them in here so the screen actually renders as designed.
    // ------------------------------------------------------------------
    return Scaffold(
      backgroundColor: NVColors.ivoryWhite,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _WomenHeaderBar(
              width: width,
              desktop: desktop,
              searchOpen: searchOpen,
              searchController: searchController,
              onBack: () => Navigator.maybePop(context),
              onFilterTap: () {},
              onToggleSearch: () => setState(() => searchOpen = !searchOpen),
              onSearchChanged: (v) => setState(() => _searchQuery = v),
            ),
            _HeroBanner(
              width: width,
              onExplore: () {},
            ),
            _SeasonalEditShowcase(
              width: width,
              categories: categories,
              selected: selectedCategory,
              labelBuilder: _categoryLabel,
              onSelect: (c) => setState(() => selectedCategory = c),
            ),
            _EditorsPicks(width: width),
            _ProductsSection(
              width: width,
              cols: cols,
              isLoading: isLoading,
              products: visibleProducts,
              categories: categories,
              selectedCategory: selectedCategory,
              labelBuilder: _categoryLabel,
              iconBuilder: _categoryIcon,
              onCategorySelect: (c) => setState(() => selectedCategory = c),
              onOpenProduct: (product) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// HEADER — rich-black bar with back button, title/subtitle, filter
/// and search toggle, and an expandable glass search field. Mirrors
/// the header language on the Orders and Men's Collection screens.
///
/// ADDED: this was the exact Row/AnimatedSize block that used to sit
/// directly (and only) inside _WomenScreenState.build(), wrapped in a
/// plain AppBar Scaffold. That left ivoryWhite/white54 text sitting on
/// a plain white AppBar (unreadable) and callbacks/fields it never
/// declared. Pulled out into its own widget, wrapped in the same
/// rich-black rounded container the Orders/Men's headers use, and
/// wired to real state from the parent. The Row/AnimatedSize content
/// itself is unchanged from what was pasted.
/// ============================================================
class _WomenHeaderBar extends StatelessWidget {
  final double width;
  final bool desktop;
  final bool searchOpen;
  final TextEditingController searchController;
  final VoidCallback onBack;
  final VoidCallback onFilterTap;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;

  const _WomenHeaderBar({
    required this.width,
    required this.desktop,
    required this.searchOpen,
    required this.searchController,
    required this.onBack,
    required this.onFilterTap,
    required this.onToggleSearch,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                        "WOMEN'S COLLECTION",
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
                        "Where Elegance Meets Everyday Confidence.",
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
                                hintText: "Search women's products...",
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
/// HERO — asymmetric editorial composition: full-bleed image with
/// the glass panel floating to one side rather than centered, for a
/// more feminine, magazine-style feel distinct from the Men's page.
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
        height: desktop ? 600 : 460,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _HoverZoomImage(url: _WomenImages.hero),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NVColors.richBlack.withOpacity(0.55),
                    Colors.transparent,
                    NVColors.richBlack.withOpacity(0.75),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: desktop ? null : 24,
              top: desktop ? null : 30,
              bottom: 30,
              width: desktop ? 440 : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "THE WOMEN'S EDIT · 2026",
                          style: TextStyle(
                            color: NVColors.warmGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Soft Power.\nSharp Silhouettes.",
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            fontSize: desktop ? 36 : 27,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Fluid tailoring and elevated basics for every hour of your day.",
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 18),
                        _WomenButton(label: "EXPLORE COLLECTION", filled: true, onTap: onExplore),
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
/// SEASONAL EDIT SHOWCASE — only the categories that actually exist
/// in `categories` are shown, so every card maps to a real filter.
/// First card rendered larger for an asymmetric editorial rhythm.
/// ============================================================
class _SeasonalEditShowcase extends StatelessWidget {
  final double width;
  final List<String> categories;
  final String selected;
  final String Function(String) labelBuilder;
  final ValueChanged<String> onSelect;

  const _SeasonalEditShowcase({
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
            const _SectionHeading("SEASONAL EDIT"),
            const SizedBox(height: 20),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final banner = _WomenImages.categoryBanners[c] ??
                      _WomenImages.categoryBanners['all']!;
                  return _CategoryCard(
                    label: labelBuilder(c),
                    image: banner,
                    active: c == selected,
                    large: i == 0,
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
  final bool large;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.label,
    required this.image,
    required this.active,
    required this.onTap,
    this.large = false,
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
            width: widget.large ? 165 : 130,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
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
                  left: 12,
                  right: 12,
                  bottom: 14,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.active ? NVColors.champagneGold : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: widget.large ? 15 : 13,
                    ),
                  ),
                ),
                if (widget.active)
                  const Positioned(
                    top: 10,
                    right: 10,
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
/// EDITOR'S PICKS — overlapping, magazine-style floating cards with
/// premium badges. Purely decorative marketing content.
/// ============================================================
class _EditorsPicks extends StatelessWidget {
  final double width;
  const _EditorsPicks({required this.width});

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);
    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, 52, hPad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading("EDITOR'S PICKS"),
            const SizedBox(height: 22),
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _WomenImages.editorsPicks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 24),
                itemBuilder: (context, i) {
                  final entry = _WomenImages.editorsPicks[i];
                  return _EditorsPickCard(label: entry.$1, image: entry.$2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorsPickCard extends StatefulWidget {
  final String label;
  final String image;
  const _EditorsPickCard({required this.label, required this.image});

  @override
  State<_EditorsPickCard> createState() => _EditorsPickCardState();
}

class _EditorsPickCardState extends State<_EditorsPickCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: SizedBox(
          width: 190,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 14),
                height: 250,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: NVColors.richBlack.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                          colors: [NVColors.richBlack.withOpacity(0.6), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: NVColors.champagneGold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: NVColors.champagneGold.withOpacity(0.4), blurRadius: 10)],
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: NVColors.richBlack,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
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
      padding: EdgeInsets.fromLTRB(hPad, 52, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading("ALL WOMEN'S PRODUCTS"),
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

/// ADDED / REPAIRED: the pasted version of this widget's build()
/// method was corrupted mid-way — a stray `Text("No products found")`
/// and an unrelated `ListView.builder`/`Card`/`ListTile` block (from
/// an older, simpler product-list screen) were spliced into the
/// middle of the stock-badge `Container`, with a dangling `:` that
/// didn't belong to any `?`, and the card never had a name/price
/// footer at all. The image + low-stock/out-of-stock badge logic
/// below is exactly what was pasted; the favorite toggle and the
/// name/price footer are new, needed for this to be a usable product
/// card (the `_favorite` field existed but was never used anywhere).
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
            borderRadius: BorderRadius.circular(20),
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
                            outOfStock ? "SOLD OUT" : "LOW STOCK",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    // ADDED: favorite toggle — wires up the previously
                    // unused `_favorite` field.
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _favorite = !_favorite),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: _favorite ? const Color(0xFFA24C42) : NVColors.graphite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ADDED: name/price footer — missing entirely from the
              // pasted file, but required for the card to be usable.
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
                        color: NVColors.richBlack,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      outOfStock ? "Out of stock" : "₹${product.price}",
                      style: TextStyle(
                        color: outOfStock ? NVColors.warmGray : NVColors.richBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
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

/// ADDED: referenced by _ProductsSection but never defined anywhere
/// in the pasted file. Matches the shimmer style used on the Orders
/// screen.
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

class _ShimmerProductCardState extends State<_ShimmerProductCard> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 3, 0),
              end: Alignment(0 + t * 3, 0),
              colors: const [
                Color(0xFFEDE7DC),
                Color(0xFFF7F3EC),
                Color(0xFFEDE7DC),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ADDED: referenced by _ProductsSection but never defined anywhere
/// in the pasted file. The "No products found" copy is the same line
/// that was stranded in the middle of _LuxuryProductCard's corrupted
/// build() — this is almost certainly where it originally belonged.
class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: NVColors.warmGray),
            const SizedBox(height: 14),
            const Text(
              "No products found",
              style: TextStyle(color: NVColors.graphite, fontSize: 14, fontWeight: FontWeight.w600),
            ),
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

class _WomenButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _WomenButton({required this.label, required this.onTap, this.filled = true});

  @override
  State<_WomenButton> createState() => _WomenButtonState();
}

class _WomenButtonState extends State<_WomenButton> {
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
/// language used across the Home Page, Orders and Men's screens.
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

/// ADDED: referenced by _HeroBanner / _SeasonalEditShowcase /
/// _EditorsPicks (`_WomenImages.hero`, `.categoryBanners`,
/// `.editorsPicks`) but never defined anywhere in the pasted file.
/// These are placeholder stock-photo URLs only — swap them for your
/// own hosted product/editorial imagery.
class _WomenImages {
  static const String hero =
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=1200&q=80';

  static const Map<String, String> categoryBanners = {
    'all': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&q=80',
    'hoodies': 'https://images.unsplash.com/photo-1509551388413-e18d0ac5d495?w=600&q=80',
    'tshirts': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&q=80',
    'shirts': 'https://images.unsplash.com/photo-1551803091-e20673f15770?w=600&q=80',
    'pants': 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80',
  };

  static const List<(String, String)> editorsPicks = [
    ('Tailored Blazer', 'https://images.unsplash.com/photo-1591369822096-ffd140ec948f?w=500&q=80'),
    ('Silk Slip Dress', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&q=80'),
    ('Wide-Leg Trousers', 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=500&q=80'),
    ('Cashmere Knit', 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=500&q=80'),
  ];
}