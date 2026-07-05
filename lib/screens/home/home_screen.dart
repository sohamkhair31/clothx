import 'package:clothx/screens/collections/collections_page.dart';
import 'package:clothx/screens/home/new_arrivals_page.dart';
import 'package:clothx/screens/home/profile_page.dart';
import 'package:clothx/screens/home/about_page.dart';
import 'dart:ui';
import 'package:flutter/material.dart';

/// =================================================================
/// NV'S — LUXURY FASHION BRAND HOMEPAGE  (single-file build)
/// =================================================================
/// Everything — theme, breakpoints, navbar, hero, and every section
/// down to the footer — lives in this one file for easy drop-in use.
///
/// This version has ZERO external package dependencies:
///   - No google_fonts        (uses Flutter's built-in TextStyle)
///   - No cached_network_image (uses Flutter's built-in Image.network)
///
/// Other files in this project (men_screen.dart, women_screen.dart,
/// order_screen.dart, etc.) import `NVColors` and `NVBreak` from this
/// file — both are defined below, so those imports will now resolve.
/// =================================================================



/// -----------------------------------------------------------------
/// APP ROOT
/// -----------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NV's — Luxury Redefined",
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _SmoothScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: NVColors.ivory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NVColors.gold,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        splashFactory: InkRipple.splashFactory,
      ),
      home: const HomePage(),
    );
  }
}

class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

/// -----------------------------------------------------------------
/// PALETTE & BREAKPOINTS
/// (Renamed to NVColors / NVBreak so other screens that already
/// `import 'home_screen.dart' show NVColors, NVBreak;` compile.)
/// -----------------------------------------------------------------
class NVColors {
  static const ivory = Color(0xFFF8F6F2);
  static const charcoal = Color(0xFF111111);
  static const beige = Color(0xFFE9E1D3);
  static const gold = Color(0xFFC9A96E);
  static const white = Color(0xFFFFFFFF);
}

class NVBreak {
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const desktop = 1440.0;

  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

/// -----------------------------------------------------------------
/// HOME PAGE — assembles every section into one scroll view, with
/// the glass navbar layered fixed on top via a Stack.
/// -----------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<double> _scrollOffset =
      ValueNotifier(0);

@override
void initState() {
  super.initState();

  _scrollController.addListener(() {
    _scrollOffset.value =
        _scrollController.offset;
  });
}

@override
void dispose() {
  _scrollController.dispose();
  _scrollOffset.dispose();
  super.dispose();
}

  void _scrollToContent() {
    _scrollController.animateTo(
      MediaQuery.of(context).size.height * 0.95,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);

    return Scaffold(
      backgroundColor: NVColors.ivory,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
ValueListenableBuilder<double>(
  valueListenable: _scrollOffset,
  builder: (_, offset, __) {
    return HeroSection(
      scrollOffset: offset,
      onScrollDownTap: _scrollToContent,
    );
  },
),
                const MarqueeStrip(),
                const CollectionsSection(),
                const BrandStorySection(),
                const LookbookSection(),
                const NewsletterSection(),
                const FooterSection(),
              ],
            ),
          ),
Positioned(
  top: 0,
  left: 0,
  right: 0,
  child: ValueListenableBuilder<double>(
    valueListenable: _scrollOffset,
    builder: (_, offset, __) {
      return GlassNavbar(
        isMobile: isMobile,
        scrollOffset: offset,
      );
    },
  ),
),
        ],
      ),
    );
  }
}

/// =================================================================
/// GLASS NAVBAR
/// =================================================================
class GlassNavbar extends StatelessWidget {
  final bool isMobile;
  final double scrollOffset;

  const GlassNavbar({
    super.key,
    required this.isMobile,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = NVBreak.isTablet(width);
    final compact = isMobile || isTablet;
    final scrolledPastHero = scrollOffset > 40;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 14 : 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 28,
              vertical: isMobile ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: scrolledPastHero
                  ? NVColors.charcoal.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Logo(compact: compact),
                if (!compact) const _NavLinks(),
                _NavActions(compact: compact),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final bool compact;
  const _Logo({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: NVColors.white, width: 1.2),
          ),
          child: const Text(
            'N',
            style: TextStyle(
              color: NVColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "NV's",
          style: TextStyle(
            color: NVColors.white,
            fontWeight: FontWeight.w600,
            fontSize: compact ? 18 : 20,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _NavLinks extends StatelessWidget {
  const _NavLinks();

  static const items = ['New Arrivals', 'Collections', 'Brand', 'About','profile'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.map((label) => _NavLink(label: label)).toList(),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  const _NavLink({required this.label});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    var mouseRegion3 = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: () {
  if (widget.label == 'Collections') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CollectionsPage(),
      ),
    );
  }
  if (widget.label == 'New Arrivals') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewArrivalsScreen(),
      ),
    );
  }
  if (widget.label == 'About') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }
  if (widget.label == 'profile') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountPage(),
      ),
    );
  }      
},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _hovering
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: NVColors.white.withValues(alpha: _hovering ? 1 : 0.88),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          )
        ),
      );

  
    var mouseRegion2 = mouseRegion3;
    var mouseRegion = mouseRegion2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: mouseRegion,
    );
  }
}

class _NavActions extends StatefulWidget {
  final bool compact;
  const _NavActions({required this.compact});

  @override
  State<_NavActions> createState() => _NavActionsState();
}

class _NavActionsState extends State<_NavActions> {
  bool _searchHover = false;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconPill(Icons.search_rounded),
          const SizedBox(width: 8),
          _iconPill(Icons.menu_rounded, onTap: () => _openMobileMenu(context)),
        ],
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _searchHover = true),
      onExit: (_) => setState(() => _searchHover = false),
      child: AnimatedScale(
        scale: _searchHover ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _searchHover ? 0.22 : 0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_rounded, color: Colors.white, size: 17),
              const SizedBox(width: 6),
              const Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconPill(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _openMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _MobileMenuSheet(),
    );
  }
}

class _MobileMenuSheet extends StatelessWidget {
  const _MobileMenuSheet();

  static const items = [
    'New Arrivals',
    'Collections',
    'Brand',
    'About',
    'profile',
    'Search',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: NVColors.charcoal.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ...items.map(
  (label) => ListTile(
    title: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    ),
    onTap: () {
      Navigator.pop(context);

      switch (label) {
        case 'New Arrivals':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewArrivalsScreen(),
            ),
          );
          break;

        case 'Collections':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CollectionsPage(),
            ),
          );
          break;

        case 'About':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AboutScreen(),
            ),
          );
          break;

        case 'profile':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AccountPage(),
            ),
          );
          break;

        case 'Search':
          // TODO: Open search screen
          break;
      }
    },
  ),
),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// PREMIUM BUTTON — hover scale + press feedback CTA
/// =================================================================
enum ButtonVariant { solid, outline }

class PremiumButton extends StatefulWidget {
  final String label;
  final ButtonVariant variant;
  final VoidCallback onTap;
  final bool small;

  const PremiumButton({
    super.key,
    required this.label,
    required this.variant,
    required this.onTap,
    this.small = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSolid = widget.variant == ButtonVariant.solid;

    final bgColor = isSolid
        ? Colors.white
        : (_hover ? Colors.white.withValues(alpha: 0.12) : Colors.transparent);
    final textColor = isSolid ? Colors.black : Colors.white;
    final borderColor = isSolid ? Colors.transparent : Colors.white;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hover ? 1.045 : 1.0),
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(
              horizontal: widget.small ? 26 : 34,
              vertical: widget.small ? 14 : 18,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: borderColor, width: 1.4),
              boxShadow: isSolid && _hover
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontSize: widget.small ? 13.5 : 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// SCROLL DOWN INDICATOR
/// =================================================================
class ScrollIndicator extends StatefulWidget {
  final VoidCallback onTap;
  const ScrollIndicator({super.key, required this.onTap});

  @override
  State<ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SCROLL DOWN',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 26,
              height: 42,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 1.4,
                ),
              ),
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, _float.value),
                      child: Container(
                        width: 4,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
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
  }
}

/// =================================================================
/// HERO SECTION — 100vh cinematic hero with parallax + fade-in
/// =================================================================
class HeroSection extends StatefulWidget {
  final double scrollOffset;
  final VoidCallback onScrollDownTap;

  const HeroSection({
    super.key,
    required this.scrollOffset,
    required this.onScrollDownTap,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // High-resolution cinematic lifestyle photography: urban golden-hour
  // street style. Replace with your own campaign photography for launch.
  static const _heroImageUrl =
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=2400&auto=format&fit=crop';

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) => _entrance.forward());
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isMobile = NVBreak.isMobile(width);
    final isTablet = NVBreak.isTablet(width);

    final parallaxShift = (widget.scrollOffset * 0.35).clamp(0.0, 120.0);

    final headlineSize = isMobile ? 34.0 : (isTablet ? 52.0 : 72.0);
    final subtitleSize = isMobile ? 15.0 : 18.0;

    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, -parallaxShift),
            child: SizedBox(
              height: size.height + 140,
              width: double.infinity,
              child: Image.network(
                _heroImageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: NVColors.charcoal);
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: NVColors.charcoal,
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white24, size: 40),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.30),
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      children: [
                        Text(
                          'NV\u2019S \u2014 SIGNATURE COLLECTION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: NVColors.gold,
                            fontSize: isMobile ? 11 : 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: isMobile ? 3 : 4,
                          ),
                        ),
                        SizedBox(height: isMobile ? 18 : 26),
                        Text(
                          "WE DON'T FOLLOW\nTRENDS. WE CREATE THEM.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: headlineSize,
                            fontWeight: FontWeight.w600,
                            height: 1.12,
                            letterSpacing: isMobile ? 0 : -0.5,
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 22),
                        Text(
                          'Luxury starts with confidence.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: isMobile ? 34 : 46),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.center,
                          children: [
                            PremiumButton(
                              label: 'Explore Collection',
                              variant: ButtonVariant.solid,
                              small: isMobile,
                              onTap: widget.onScrollDownTap,
                            ),
                            PremiumButton(
                              label: 'Shop Now',
                              variant: ButtonVariant.outline,
                              small: isMobile,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: isMobile ? 26 : 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fade,
              child: Center(
                child: ScrollIndicator(onTap: widget.onScrollDownTap),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================================
/// MARQUEE STRIP — auto-scrolling brand ticker
/// =================================================================
class MarqueeStrip extends StatefulWidget {
  const MarqueeStrip({super.key});

  @override
  State<MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<MarqueeStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();

  static const _items = [
    'CRAFTED WITH PRECISION',
    'LIMITED EDITION DROPS',
    'DESIGNED FOR CONFIDENCE',
    'GLOBAL LUXURY STANDARD',
    'TIMELESS SILHOUETTES',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(_tick);

    _controller.repeat();
  }

void _tick() {
  if (!_scrollController.hasClients) return;

  final position = _scrollController.position;

  if (!position.hasContentDimensions) return;

  final max = position.maxScrollExtent;
  final target = _controller.value * max;

  _scrollController.jumpTo(target);
}

  @override
  void dispose() {
    _controller.removeListener(_tick);
    _controller.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final line = List.generate(
      3,
      (_) => _items.join('   \u2726   '),
    ).join('   \u2726   ');

    return Container(
      color: NVColors.charcoal,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: SizedBox(
        height: 20,
        child: ListView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Text(
              '   $line   $line   ',
              style: TextStyle(
                color: NVColors.beige.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================================================================
/// COLLECTIONS SECTION — responsive grid with hover-zoom cards
/// =================================================================
class _CollectionItem {
  final String title;
  final String subtitle;
  final String image;
  const _CollectionItem(this.title, this.subtitle, this.image);
}

const _collections = [
  _CollectionItem(
    'Womenswear',
    'Tailored elegance',
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=1200&auto=format&fit=crop',
  ),
  _CollectionItem(
    'Menswear',
    'Modern power dressing',
    'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=1200&auto=format&fit=crop',
  ),
  _CollectionItem(
    'Accessories',
    'Details that define you',
    'https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=1200&auto=format&fit=crop',
  ),
  _CollectionItem(
    'New Season',
    'Autumn / Winter drop',
    'https://images.unsplash.com/photo-1503341504253-dff4815485f1?q=80&w=1200&auto=format&fit=crop',
  ),
];

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);
    final isTablet = NVBreak.isTablet(width);
    final columns = isMobile ? 1 : (isTablet ? 2 : 4);

    return Container(
      color: NVColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 56 : 90,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'CURATED COLLECTIONS',
            style: TextStyle(
              color: NVColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Shop by category',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NVColors.charcoal,
              fontSize: isMobile ? 26 : 38,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isMobile ? 36 : 54),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _collections.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: isMobile ? 1.15 : 0.78,
            ),
            itemBuilder: (context, i) => _CollectionCard(item: _collections[i]),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final _CollectionItem item;
  const _CollectionCard({required this.item});

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedScale(
              scale: _hover ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Image.network(
                widget.item.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: NVColors.beige);
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: NVColors.beige,
                  child: const Icon(Icons.image_outlined,
                      color: Colors.white70),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: _hover ? 0.75 : 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 20,
              child: AnimatedSlide(
                offset: _hover ? const Offset(0, -0.04) : Offset.zero,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(top: 10),
                      height: _hover ? 1.4 : 0,
                      width: 34,
                      color: NVColors.gold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================================================================
/// BRAND STORY SECTION — editorial split image/text
/// =================================================================
class BrandStorySection extends StatelessWidget {
  const BrandStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);
    final isTablet = NVBreak.isTablet(width);
    final stacked = isMobile || isTablet;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: stacked ? 16 / 10 : 4 / 5,
        child: Image.network(
          'https://images.unsplash.com/photo-1520975954732-35dd22299614?q=80&w=1400&auto=format&fit=crop',
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: NVColors.beige);
          },
          errorBuilder: (context, error, stackTrace) =>
              Container(color: NVColors.beige),
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE NV\u2019S PHILOSOPHY',
          style: TextStyle(
            color: NVColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Confidence is\nthe ultimate accessory.',
          style: TextStyle(
            color: NVColors.charcoal,
            fontSize: isMobile ? 28 : 40,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Every NV\u2019S piece is designed at the intersection of '
          'architecture and attitude \u2014 engineered fabrics, considered '
          'silhouettes, and a refusal to blend in. We don\u2019t chase '
          'seasons; we set the pace for them.',
          style: TextStyle(
            color: NVColors.charcoal.withValues(alpha: 0.7),
            fontSize: 15.5,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            _StatBlock(value: '120+', label: 'Countries shipped'),
            const SizedBox(width: 36),
            _StatBlock(value: '18Y', label: 'Of craftsmanship'),
          ],
        ),
        const SizedBox(height: 34),
        PremiumButton(
          label: 'Our Story',
          variant: ButtonVariant.solid,
          onTap: () {},
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: NVColors.beige.withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: isMobile ? 56 : 100,
      ),
      child: stacked
          ? Column(
              children: [
                image,
                const SizedBox(height: 36),
                text,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: image),
                const SizedBox(width: 64),
                Expanded(child: text),
              ],
            ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: NVColors.charcoal,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: NVColors.charcoal.withValues(alpha: 0.6),
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}

/// =================================================================
/// LOOKBOOK SECTION — horizontal-scroll dark gallery
/// =================================================================
const _lookImages = [
  'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?q=80&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1509631179647-0177331693ae?q=80&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=1000&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?q=80&w=1000&auto=format&fit=crop',
];

class LookbookSection extends StatelessWidget {
  const LookbookSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);
    final cardWidth = isMobile ? width * 0.72 : 320.0;

    return Container(
      width: double.infinity,
      color: NVColors.charcoal,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE LOOKBOOK',
                  style: TextStyle(
                    color: NVColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Street-cast. City-lit.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 26 : 38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 30 : 44),
          SizedBox(
            height: isMobile ? 420 : 460,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
              itemCount: _lookImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (context, i) {
                return _LookCard(imageUrl: _lookImages[i], width: cardWidth);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LookCard extends StatefulWidget {
  final String imageUrl;
  final double width;
  const _LookCard({required this.imageUrl, required this.width});

  @override
  State<_LookCard> createState() => _LookCardState();
}

class _LookCardState extends State<_LookCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.width,
        transform: Matrix4.translationValues(0, _hover ? -8 : 0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(color: Colors.white.withValues(alpha: 0.06));
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white.withValues(alpha: 0.06),
              child: const Icon(Icons.image_outlined, color: Colors.white24),
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// NEWSLETTER SECTION — email capture band
/// =================================================================
class NewsletterSection extends StatefulWidget {
  const NewsletterSection({super.key});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;
  bool _hover = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);

    return Container(
      width: double.infinity,
      color: NVColors.ivory,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 60 : 90,
      ),
      child: Column(
        children: [
          Text(
            'JOIN THE INNER CIRCLE',
            style: TextStyle(
              color: NVColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Be first to know.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NVColors.charcoal,
              fontSize: isMobile ? 26 : 36,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Early access to drops, private previews, and members-only pricing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: NVColors.charcoal.withValues(alpha: 0.6),
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: isMobile
                ? Column(
                    children: [
                      _emailField(),
                      const SizedBox(height: 12),
                      _submitButton(),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _emailField()),
                      const SizedBox(width: 12),
                      _submitButton(),
                    ],
                  ),
          ),
          if (_submitted) ...[
            const SizedBox(height: 14),
            Text(
              "Welcome to NV's. Check your inbox.",
              style: TextStyle(
                color: NVColors.charcoal.withValues(alpha: 0.7),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.15)),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 14.5, color: NVColors.charcoal),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your email',
          hintStyle: TextStyle(
            color: NVColors.charcoal.withValues(alpha: 0.4),
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _submitted = true),
        child: AnimatedScale(
          scale: _hover ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: NVColors.charcoal,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'Subscribe',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// FOOTER SECTION — watermark wordmark + link columns
/// =================================================================
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreak.isMobile(width);
    final isTablet = NVBreak.isTablet(width);
    final stacked = isMobile || isTablet;

    return Container(
      width: double.infinity,
      color: NVColors.charcoal,
      child: Stack(
        children: [
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Text(
                  "NV'S",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.045),
                    fontSize: isMobile ? 110 : 260,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 22 : 48,
              isMobile ? 56 : 90,
              isMobile ? 22 : 48,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _brandBlock(),
                          const SizedBox(height: 44),
                          _linkColumns(stacked: true),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _brandBlock()),
                          Expanded(flex: 6, child: _linkColumns(stacked: false)),
                        ],
                      ),
                SizedBox(height: isMobile ? 50 : 80),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                const SizedBox(height: 22),
                stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _copyright(),
                          const SizedBox(height: 14),
                          _legalLinks(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_copyright(), _legalLinks()],
                      ),
                SizedBox(height: isMobile ? 40 : 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "NV's",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 300,
          child: Text(
            'Independent luxury fashion house. Designed for those who '
            'set the standard, not follow it.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13.5,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            _HoverIcon(icon: Icons.camera_alt_outlined),
            const SizedBox(width: 10),
            _HoverIcon(icon: Icons.play_arrow_rounded),
            const SizedBox(width: 10),
            _HoverIcon(icon: Icons.alternate_email_rounded),
          ],
        ),
      ],
    );
  }

  Widget _linkColumns({required bool stacked}) {
    final columns = [
      const _FooterColumn(title: 'Shop', items: [
        'New Arrivals',
        'Womenswear',
        'Menswear',
        'Accessories',
      ]),
      const _FooterColumn(title: 'Brand', items: [
        'Our Story',
        'Sustainability',
        'Craftsmanship',
        'Careers',
      ]),
      const _FooterColumn(title: 'Support', items: [
        'Contact Us',
        'Shipping',
        'Returns',
        'Size Guide',
      ]),
    ];

    if (stacked) {
      return Wrap(
        spacing: 40,
        runSpacing: 32,
        children: columns,
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.map((c) => Expanded(child: c)).toList(),
    );
  }

  Widget _copyright() {
    return Text(
      '\u00A9 ${DateTime.now().year} NV\'S. All rights reserved.',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 12.5,
      ),
    );
  }

  Widget _legalLinks() {
    return Wrap(
      spacing: 20,
      children: ['Privacy Policy', 'Terms of Service', 'Cookies']
          .map(
            (t) => Text(
              t,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12.5,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HoverLink(label: item),
          ),
        ),
      ],
    );
  }
}

class _HoverLink extends StatefulWidget {
  final String label;
  const _HoverLink({required this.label});

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          color: _hover ? NVColors.gold : Colors.white.withValues(alpha: 0.6),
          fontSize: 13.5,
        ),
        child: Text(widget.label),
      ),
    );
  }
}

class _HoverIcon extends StatefulWidget {
  final IconData icon;
  const _HoverIcon({required this.icon});

  @override
  State<_HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<_HoverIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _hover ? NVColors.gold : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Icon(
          widget.icon,
          color: _hover ? NVColors.gold : Colors.white70,
          size: 17,
        ),
      ),
    );
  }
}