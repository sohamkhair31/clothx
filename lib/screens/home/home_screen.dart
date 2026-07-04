import 'dart:async';
import 'dart:ui';

import 'package:clothx/controllers/product_controller.dart';
import 'package:clothx/models/product_model.dart';
import 'package:clothx/screens/cart/cart_screen.dart';
import 'package:clothx/screens/gender/men_screen.dart';
import 'package:clothx/screens/gender/women_screen.dart';
import 'package:clothx/screens/product/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ============================================================
/// NEW VISION'S — LUXURY DESIGN SYSTEM
/// (Color theme only — palette below matches the approved
/// Ivory / Rich Black / Champagne Gold brand system)
/// ============================================================
class NVColors {
  static const Color richBlack = Color(0xFF0A0A0A); // Navbar / Footer / Hero Heading / Price
  static const Color ivoryWhite = Color(0xFFFAF8F5); // Main Background
  static const Color graphite = Color(0xFF2B2B2B); // Paragraph Text / Icon Stroke
  static const Color warmGray = Color(0xFF5F5A54); // Secondary Text
  static const Color warmGold = Color(0xFFC8A86B); // Section Labels / View All
  static const Color champagneGold = Color(0xFFD6C08D); // Navbar/Footer Icons, Active Link
  static const Color cardWhite = Color(0xFFFFFFFF); // Card Background / Input Field
  static const Color sectionBeige = Color(0xFFE9E1D3); // Section Background
  static const Color cardBorderBeige = Color(0xFFEFCDBA); // Card Border / Primary CTA
  static const Color dividerPlatinum = Color(0xFFE3DED8); // Divider Lines
  static const Color inputBorderGray = Color(0xFFD9D9D9); // Input Border
}

/// Responsive breakpoints for Flutter Web.
class NVBreak {
  static bool isMobile(double w) => w < 700;
  static bool isTablet(double w) => w >= 700 && w < 1100;
  static bool isDesktop(double w) => w >= 1100;

  static double hPad(double w) {
    if (w < 380) return 14;
    if (isMobile(w)) return 20;
    if (isTablet(w)) return 48;
    return 96;
  }

  static int gridColumns(double w) {
    if (isMobile(w)) return 2;
    if (isTablet(w)) return 3;
    return 4;
  }
}

/// Placeholder editorial photography — replace with real campaign
/// assets before shipping. Business logic is untouched; only these
/// are cosmetic image sources.
class NVImages {
  static const heroSlides = [
    'https://picsum.photos/seed/nv-hero-a/1600/1000',
    'https://picsum.photos/seed/nv-hero-b/1600/1000',
    'https://picsum.photos/seed/nv-hero-c/1600/1000',
  ];
  static const menBanner =
      'https://picsum.photos/seed/nv-men-editorial/1400/1000';
  static const womenBanner =
      'https://picsum.photos/seed/nv-women-editorial/1200/1400';
  static const exploreBanner =
      'https://picsum.photos/seed/nv-explore-cinema/1600/900';
  static const hoodiePromo =
      'https://picsum.photos/seed/nv-hoodie-promo/1400/1000';

  static const categories = {
    'Hoodies': 'https://picsum.photos/seed/nv-c-hoodie/700/900',
    'Oversized Tees': 'https://picsum.photos/seed/nv-c-tee/700/900',
    'Cargo Pants': 'https://picsum.photos/seed/nv-c-cargo/700/900',
    'Denim': 'https://picsum.photos/seed/nv-c-denim/700/900',
    'Jackets': 'https://picsum.photos/seed/nv-c-jacket/700/900',
    'Accessories': 'https://picsum.photos/seed/nv-c-accessory/700/900',
    'Sneakers': 'https://picsum.photos/seed/nv-c-sneaker/700/900',
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _navSolid = false;

  @override
  void initState() {
    super.initState();

    // ---- business logic untouched ----
    Future.microtask(() async {
      await context.read<ProductController>().fetchProducts();
    });

    _scrollController.addListener(() {
      final solid = _scrollController.offset > 40;
      if (solid != _navSolid) setState(() => _navSolid = solid);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    final products = productController.products;

    final menProducts = products.where((p) => p.gender == "men").toList();
    final womenProducts = products.where((p) => p.gender == "women").toList();
    final bestSellers = products.take(8).toList();

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: NVColors.ivoryWhite,
      drawer: NVBreak.isDesktop(width) ? null : const _NVDrawer(),
      body: productController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: NVColors.champagneGold),
            )
          : products.isEmpty
              ? const Center(child: Text("No products found"))
              : Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(child: _HeroCarousel(width: width)),
                        SliverToBoxAdapter(
                          child: _MenSection(
                            width: width,
                            onShopMen: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MenScreen(),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _WomenSection(
                            width: width,
                            onShopWomen: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WomenScreen(),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: _ExploreBanner(width: width)),
                        SliverToBoxAdapter(child: _BrandStory(width: width)),
                        SliverToBoxAdapter(
                            child: _CategoryShowcase(width: width)),
                        SliverToBoxAdapter(
                            child: _HoodiePromoBanner(width: width)),
                        SliverToBoxAdapter(
                          child: _BestSellersSection(
                            width: width,
                            title: "BEST SELLERS",
                            items: bestSellers,
                            onOpen: (p) => _openProduct(context, p),
                          ),
                        ),
                        if (menProducts.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _BestSellersSection(
                              width: width,
                              title: "MEN'S PICKS",
                              items: menProducts.take(8).toList(),
                              onOpen: (p) => _openProduct(context, p),
                            ),
                          ),
                        if (womenProducts.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _BestSellersSection(
                              width: width,
                              title: "WOMEN'S PICKS",
                              items: womenProducts.take(8).toList(),
                              onOpen: (p) => _openProduct(context, p),
                            ),
                          ),
                        SliverToBoxAdapter(child: _NVFooter(width: width)),
                      ],
                    ),
                    _NVNavBar(
                      solid: _navSolid,
                      width: width,
                      onCart: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      ),
                      onMen: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MenScreen()),
                      ),
                      onWomen: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WomenScreen()),
                      ),
                      onHome: () => _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      ),
                    ),
                  ],
                ),
    );
  }

  static void _openProduct(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product)),
    );
  }
}

/// ============================================================
/// NAVIGATION — permanent rich-black luxury bar with a slim
/// gold-on-black announcement strip on top (reference-matched).
/// Business logic (callbacks, scroll-solid state) is unchanged —
/// only presentation/styling was elevated.
/// ============================================================
class _NVNavBar extends StatelessWidget {
  final bool solid;
  final double width;
  final VoidCallback onCart;
  final VoidCallback onMen;
  final VoidCallback onWomen;
  final VoidCallback onHome;

  const _NVNavBar({
    required this.solid,
    required this.width,
    required this.onCart,
    required this.onMen,
    required this.onWomen,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: solid ? 16 : 0,
            sigmaY: solid ? 16 : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- slim gold-on-black announcement strip ----
              if (desktop) _NVAnnouncementBar(width: width),

              // ---- main navigation row ----
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  horizontal: NVBreak.hPad(width),
                  vertical: solid ? 14 : 20,
                ),
                decoration: BoxDecoration(
                  color: NVColors.richBlack,
                  border: const Border(
                    bottom: BorderSide(
                      color: Color(0x33D6C08D),
                      width: 0.6,
                    ),
                  ),
                  boxShadow: solid
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ---- logo (shrinks to fit — never overflows) ----
                    Flexible(
                      flex: desktop ? 2 : 3,
                      fit: FlexFit.loose,
                      child: GestureDetector(
                        onTap: onHome,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _NVLogo(desktop: desktop),
                        ),
                      ),
                    ),

                    // ---- centered nav links ----
                    if (desktop)
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _NavLink("Home", onHome),
                            _NavLink("Men", onMen),
                            _NavLink("Women", onWomen),
                            _NavLink("New Arrivals", () {}),
                            _NavLink("Collections", () {}),
                            _NavLink("Best Sellers", () {}),
                            _NavLink("About", () {}),
                            _NavLink("Contact", () {}),
                          ],
                        ),
                      ),

                    // ---- right icon cluster ----
                    Flexible(
                      flex: desktop ? 2 : 2,
                      fit: FlexFit.loose,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (desktop) ...[
                            _NavIcon(Icons.search, () => _openSearch(context)),
                            _NVIconDivider(),
                            _NavIcon(Icons.favorite_border, () {}),
                            _NVIconDivider(),
                          ],
                          _NavIcon(
                            Icons.shopping_bag_outlined,
                            onCart,
                            compact: !desktop,
                          ),
                          if (!desktop)
                            Builder(
                              builder: (ctx) => IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                                icon: const Icon(Icons.menu,
                                    size: 22, color: NVColors.champagneGold),
                              ),
                            ),
                        ],
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

  static void _openSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: NVColors.richBlack,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 40, vertical: 200),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            autofocus: true,
            style: const TextStyle(color: NVColors.ivoryWhite),
            decoration: const InputDecoration(
              hintText: "Search New Vision's...",
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: NVColors.champagneGold),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// Slim gold-accented announcement strip that sits above the main
/// navbar, echoing the reference layout's "Free shipping..." bar.
class _NVAnnouncementBar extends StatelessWidget {
  final double width;
  const _NVAnnouncementBar({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF050505),
      padding: EdgeInsets.symmetric(
        horizontal: NVBreak.hPad(width),
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_shipping_outlined,
                    size: 13, color: NVColors.champagneGold),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "FREE SHIPPING ON ALL ORDERS ABOVE ₹999",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: NVColors.champagneGold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (width >= 1250) ...[
            const SizedBox(width: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _NVTopLinkText("Help"),
                SizedBox(width: 22),
                _NVTopLinkText("Track Order"),
                SizedBox(width: 22),
                _NVTopLinkText("Returns"),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NVTopLinkText extends StatelessWidget {
  final String text;
  const _NVTopLinkText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Elegant serif wordmark used in the navbar.
class _NVLogo extends StatelessWidget {
  final bool desktop;
  const _NVLogo({required this.desktop});

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      text: TextSpan(
        children: [
          TextSpan(
            text: "NEW VISION",
            style: TextStyle(
              fontFamily: 'Georgia',
              color: NVColors.ivoryWhite,
              fontSize: desktop ? 25 : 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
            ),
          ),
          TextSpan(
            text: "'S",
            style: TextStyle(
              fontFamily: 'Georgia',
              color: NVColors.champagneGold,
              fontSize: desktop ? 25 : 19,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin vertical hairline used between navbar icons for a
/// jewellery-case, boutique feel.
class _NVIconDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white24,
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color:
                      _hovered ? NVColors.champagneGold : NVColors.ivoryWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  shadows: _hovered
                      ? [
                          Shadow(
                            color: NVColors.champagneGold.withOpacity(0.9),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Text(widget.label),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 1.2,
                width: _hovered ? 20 : 0,
                color: NVColors.champagneGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;
  const _NavIcon(this.icon, this.onTap, {this.compact = false});

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: IconButton(
        onPressed: widget.onTap,
        padding: widget.compact ? EdgeInsets.zero : null,
        constraints: widget.compact
            ? const BoxConstraints(minWidth: 36, minHeight: 36)
            : null,
        iconSize: widget.compact ? 22 : 24,
        icon: Icon(
          widget.icon,
          color: _hovered ? NVColors.ivoryWhite : NVColors.champagneGold,
        ),
      ),
    );
  }
}

class _NVDrawer extends StatelessWidget {
  const _NVDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: NVColors.richBlack,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                "NEW VISION'S",
                style: TextStyle(
                  color: NVColors.champagneGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            for (final item in [
              "Home",
              "Men",
              "Women",
              "New Arrivals",
              "Collections",
              "Best Sellers",
              "About",
              "Contact",
            ])
              ListTile(
                title: Text(item,
                    style: const TextStyle(color: NVColors.ivoryWhite)),
                onTap: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// HERO — full-screen auto-playing cinematic carousel
/// ============================================================
class _HeroCarousel extends StatefulWidget {
  final double width;
  const _HeroCarousel({required this.width});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  int _index = 0;
  Timer? _timer;

  final _headlines = [
    ("THE 2026 EDIT", "Own Every Room\nYou Walk Into"),
    ("STREET MEETS LUXURY", "Comfort Cut\nWith Confidence"),
    ("LIMITED DROP", "Wear What\nCan't Be Copied"),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _index = (_index + 1) % NVImages.heroSlides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(widget.width);
    final height = MediaQuery.of(context).size.height;
    final headline = _headlines[_index % _headlines.length];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 900),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Image.network(
              NVImages.heroSlides[_index],
              key: ValueKey(_index),
              fit: BoxFit.cover,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.05),
                  NVColors.richBlack.withOpacity(0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            left: NVBreak.hPad(widget.width),
            right: NVBreak.hPad(widget.width),
            bottom: desktop ? 90 : 60,
            child: _FadeSlideIn(
              key: ValueKey('headline-$_index'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: desktop ? 560 : double.infinity,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          headline.$1,
                          style: const TextStyle(
                            color: NVColors.warmGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          headline.$2,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            fontSize: desktop ? 42 : 30,
                            height: 1.12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 14,
                          runSpacing: 12,
                          children: [
                            _NVButton(
                              label: "EXPLORE COLLECTION",
                              filled: true,
                              onTap: () {},
                            ),
                            _NVButton(
                              label: "SHOP NOW",
                              filled: false,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(NVImages.heroSlides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 26 : 8,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? NVColors.champagneGold
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// MEN'S EDITORIAL SECTION — full-bleed overlay layout
/// ============================================================
class _MenSection extends StatefulWidget {
  final double width;
  final VoidCallback onShopMen;
  const _MenSection({required this.width, required this.onShopMen});

  @override
  State<_MenSection> createState() => _MenSectionState();
}

class _MenSectionState extends State<_MenSection> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(widget.width);
    return _FadeSlideIn(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          height: desktop ? 620 : 460,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _hovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: Image.network(NVImages.menBanner, fit: BoxFit.cover),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      NVColors.richBlack.withOpacity(0.85),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
              Positioned(
                left: NVBreak.hPad(widget.width),
                right: NVBreak.hPad(widget.width),
                bottom: 44,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "THE MEN'S EDIT",
                      style: TextStyle(
                        color: NVColors.warmGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tailored Ease.\nUnapologetic Attitude.",
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color: Colors.white,
                        fontSize: desktop ? 38 : 26,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: const Text(
                        "Oversized silhouettes, premium fabrics, and a fit "
                        "built for the way you actually move through your day.",
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _NVButton(
                      label: "SHOP MEN",
                      filled: true,
                      onTap: widget.onShopMen,
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

/// ============================================================
/// WOMEN'S EDITORIAL SECTION — split panel layout (distinct
/// composition so it never repeats the Men's section pattern)
/// ============================================================
class _WomenSection extends StatelessWidget {
  final double width;
  final VoidCallback onShopWomen;
  const _WomenSection({required this.width, required this.onShopWomen});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    final textPanel = Container(
      color: NVColors.sectionBeige,
      padding: EdgeInsets.symmetric(
        horizontal: NVBreak.hPad(width),
        vertical: desktop ? 0 : 44,
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "THE WOMEN'S EDIT",
            style: TextStyle(
              color: NVColors.warmGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Soft Power.\nSharp Silhouettes.",
            style: TextStyle(
              fontFamily: 'Georgia',
              color: NVColors.richBlack,
              fontSize: desktop ? 38 : 26,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Fluid tailoring and elevated basics designed to move between "
            "boardroom, brunch, and everything after dark.",
            style: TextStyle(
                color: NVColors.graphite, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 22),
          _NVButton(label: "SHOP WOMEN", filled: false, onTap: onShopWomen),
        ],
      ),
    );

    final imagePanel = _HoverScale(
      scale: 1.03,
      child: SizedBox(
        height: desktop ? 560 : 420,
        width: double.infinity,
        child: Image.network(NVImages.womenBanner, fit: BoxFit.cover),
      ),
    );

    return _FadeSlideIn(
      child: desktop
          ? SizedBox(
              height: 560,
              child: Row(
                children: [
                  Expanded(child: imagePanel),
                  Expanded(child: textPanel),
                ],
              ),
            )
          : Column(
              children: [imagePanel, textPanel],
            ),
    );
  }
}

/// ============================================================
/// EXPLORE — cinematic banner with subtle looping gradient glow
/// ============================================================
class _ExploreBanner extends StatefulWidget {
  final double width;
  const _ExploreBanner({required this.width});

  @override
  State<_ExploreBanner> createState() => _ExploreBannerState();
}

class _ExploreBannerState extends State<_ExploreBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(widget.width);
    return _FadeSlideIn(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          NVBreak.hPad(widget.width),
          56,
          NVBreak.hPad(widget.width),
          0,
        ),
        height: desktop ? 340 : 260,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: const NetworkImage(NVImages.exploreBanner),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              NVColors.richBlack.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (context, _) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      NVColors.champagneGold
                          .withOpacity(0.10 + _glow.value * 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "EXPLORE THE NEW COLLECTION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _NVButton(label: "SHOP NOW", filled: true, onTap: () {}),
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
/// BRAND STORY
/// ============================================================
class _BrandStory extends StatelessWidget {
  final double width;
  const _BrandStory({required this.width});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    final pillars = [
      (Icons.diamond_outlined, "Premium Quality"),
      (Icons.eco_outlined, "Sustainable Craft"),
      (Icons.bolt_outlined, "Individuality"),
      (Icons.spa_outlined, "All-Day Comfort"),
      (Icons.timelapse_outlined, "Timeless Design"),
    ];

    return _FadeSlideIn(
      child: Container(
        width: double.infinity,
        color: NVColors.sectionBeige,
        padding: EdgeInsets.symmetric(
          horizontal: NVBreak.hPad(width),
          vertical: 64,
        ),
        child: Column(
          children: [
            const Text(
              "WHY NEW VISION'S",
              style: TextStyle(
                color: NVColors.warmGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: desktop ? 780 : 600),
              child: const Text(
                "New Vision's isn't built on trends — it's built on craft. "
                "Every piece is small-batch made with premium fabrics that "
                "hold their shape and their story. We design for confidence, "
                "not conformity, so what you wear feels as individual as you "
                "are. This is timeless fashion, cut for a generation that "
                "leads the culture instead of chasing it.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: NVColors.graphite,
                  fontSize: 15.5,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 34),
            Wrap(
              spacing: 28,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: pillars
                  .map(
                    (p) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.$1, color: NVColors.warmGold, size: 26),
                        const SizedBox(height: 8),
                        Text(
                          p.$2,
                          style: const TextStyle(
                            color: NVColors.richBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// CATEGORY SHOWCASE
/// ============================================================
class _CategoryShowcase extends StatelessWidget {
  final double width;
  const _CategoryShowcase({required this.width});

  @override
  Widget build(BuildContext context) {
    final entries = NVImages.categories.entries.toList();
    final cols = NVBreak.gridColumns(width);

    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NVBreak.hPad(width),
          64,
          NVBreak.hPad(width),
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeading("SHOP BY CATEGORY"),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, i) {
                return _CategoryCard(
                  name: entries[i].key,
                  image: entries[i].value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final String name;
  final String image;
  const _CategoryCard({required this.name, required this.image});

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
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 220),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _hovered ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: Image.network(widget.image, fit: BoxFit.cover),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      NVColors.richBlack.withOpacity(_hovered ? 0.75 : 0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              if (_hovered)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _hovered ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Shop Now →",
                          style: TextStyle(
                            color: NVColors.warmGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

/// ============================================================
/// HOODIE PROMO BANNER — "Discover What's New"
/// ============================================================
class _HoodiePromoBanner extends StatelessWidget {
  final double width;
  const _HoodiePromoBanner({required this.width});

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(width);
    return _FadeSlideIn(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            NVBreak.hPad(width), 64, NVBreak.hPad(width), 0),
        height: desktop ? 520 : 440,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(NVImages.hoodiePromo, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    NVColors.richBlack.withOpacity(0.85),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DISCOVER WHAT'S NEW",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontSize: desktop ? 30 : 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _PulsingButton(label: "EXPLORE"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingButton extends StatefulWidget {
  final String label;
  const _PulsingButton({required this.label});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
        final scale = 1.0 + (_controller.value * 0.04);
        return Transform.scale(scale: scale, child: child);
      },
      child: _NVButton(label: widget.label, filled: true, onTap: () {}),
    );
  }
}

/// ============================================================
/// PRODUCT GRID SECTION — used for Best Sellers / Men's / Women's picks
/// (reads directly from ProductController results — logic unchanged)
/// ============================================================
class _BestSellersSection extends StatelessWidget {
  final double width;
  final String title;
  final List<ProductModel> items;
  final void Function(ProductModel) onOpen;

  const _BestSellersSection({
    required this.width,
    required this.title,
    required this.items,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cols = NVBreak.gridColumns(width);

    return _FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NVBreak.hPad(width),
          64,
          NVBreak.hPad(width),
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(title),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, i) => _ProductCard(
                product: items[i],
                onTap: () => onOpen(items[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;
  bool _favorite = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
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
            border: Border.all(
              color: NVColors.cardBorderBeige,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    NVColors.richBlack.withOpacity(_hovered ? 0.18 : 0.08),
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
                          ? Image.network(product.images.first,
                              fit: BoxFit.cover)
                          : Container(
                              color: NVColors.ivoryWhite,
                              child: const Icon(Icons.image_outlined,
                                  color: NVColors.graphite),
                            ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: NVColors.richBlack.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
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
                            color: _favorite
                                ? NVColors.warmGold
                                : NVColors.graphite,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: NVColors.richBlack.withOpacity(0.85),
                          alignment: Alignment.center,
                          child: const Text(
                            "QUICK VIEW",
                            style: TextStyle(
                              color: NVColors.ivoryWhite,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
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

/// ============================================================
/// FOOTER — logo, newsletter, links, social, contact
/// ============================================================
class _NVFooter extends StatefulWidget {
  final double width;
  const _NVFooter({required this.width});

  @override
  State<_NVFooter> createState() => _NVFooterState();
}

class _NVFooterState extends State<_NVFooter> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = NVBreak.isDesktop(widget.width);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 64),
      color: NVColors.richBlack,
      padding: EdgeInsets.fromLTRB(
        NVBreak.hPad(widget.width),
        56,
        NVBreak.hPad(widget.width),
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Newsletter
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NVColors.graphite,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Flex(
              direction: desktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: desktop
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    "Join the inner circle for early drops & exclusive access.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: desktop ? 0 : 16, width: desktop ? 20 : 0),
                SizedBox(
                  width: desktop ? 320 : double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(color: NVColors.richBlack),
                          decoration: InputDecoration(
                            hintText: "Your email",
                            hintStyle:
                                const TextStyle(color: NVColors.warmGray),
                            filled: true,
                            fillColor: NVColors.cardWhite,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: NVColors.inputBorderGray,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: NVColors.inputBorderGray,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: NVColors.champagneGold,
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Subscribed!")),
                          );
                          _emailController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: NVColors.cardBorderBeige,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: NVColors.richBlack, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          Text(
  "New Vision's",
  style: TextStyle(
    fontFamily: "serif",
    fontSize: desktop ? 28 : 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.8,
    color: NVColors.ivoryWhite,
  ),
),
          const SizedBox(height: 10),
          const Text(
            "Fashion for a generation that dresses for itself.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 32),

          Wrap(
            spacing: 40,
            runSpacing: 24,
            children: const [
              _FooterColumn(
                title: "SHOP",
                items: [
                  "New Arrivals",
                  "Men",
                  "Women",
                  "Best Sellers",
                  "Collections"
                ],
              ),
              _FooterColumn(
                title: "CUSTOMER SERVICE",
                items: [
                  "Track Order",
                  "Returns & Exchanges",
                  "Shipping Info",
                  "FAQs"
                ],
              ),
              _FooterColumn(
                title: "COMPANY",
                items: ["About Us", "Careers", "Sustainability", "Press"],
              ),
              _FooterColumn(
                title: "CONTACT",
                items: [
                  "support@newvisions.com",
                  "+91 98765 43210",
                  "Mumbai, India"
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              _socialIcon(Icons.camera_alt_outlined),
              _socialIcon(Icons.music_note_outlined),
              _socialIcon(Icons.chat_bubble_outline),
              _socialIcon(Icons.facebook_outlined),
            ],
          ),
          const Divider(color: Colors.white24, height: 44),
          const Text(
            "© 2026 New Vision's. All rights reserved.",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return _HoverScale(
      scale: 1.1,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: NVColors.champagneGold, size: 18),
      ),
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
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: NVColors.champagneGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HoverTextLink(e),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverTextLink extends StatefulWidget {
  final String text;
  const _HoverTextLink(this.text);

  @override
  State<_HoverTextLink> createState() => _HoverTextLinkState();
}

class _HoverTextLinkState extends State<_HoverTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          color: _hovered ? NVColors.champagneGold : Colors.white70,
          fontSize: 13,
        ),
        child: Text(widget.text),
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
          style: const TextStyle(
            color: NVColors.richBlack,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

/// Primary CTA (e.g. Shop Now) / Secondary CTA (e.g. Explore Collection).
class _NVButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _NVButton({
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  @override
  State<_NVButton> createState() => _NVButtonState();
}

class _NVButtonState extends State<_NVButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled
                ? NVColors.cardBorderBeige
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.filled
                  ? NVColors.cardBorderBeige
                  : NVColors.champagneGold,
              width: 1.4,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: NVColors.champagneGold.withOpacity(0.55),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.filled ? NVColors.richBlack : NVColors.warmGold,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Scale-on-hover wrapper reused across cards/icons.
class _HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  const _HoverScale({required this.child, this.scale = 1.03});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fade + slide entrance used to give every section a premium
/// "reveal" feel as the page renders.
class _FadeSlideIn extends StatefulWidget {
  final Widget child;
  const _FadeSlideIn({super.key, required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
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