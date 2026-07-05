import 'dart:ui';
import 'package:flutter/material.dart';

/// =================================================================
/// NV'S — COLLECTIONS PAGE  (single-file, zero third-party deps)
/// =================================================================
/// Pure Flutter SDK only — no google_fonts, no cached_network_image,
/// no external packages. Uses `Image.network` with a built-in
/// `loadingBuilder`/`errorBuilder`, and `dart:ui`'s `ImageFilter` for
/// the glass nav (both are part of the Flutter framework, not deps).
///
/// Drop this file in as `collections_page.dart` and push/route to
/// `CollectionsPage()` from your existing navigation/controllers —
/// no app logic, routing, providers, models, or Firebase calls are
/// touched here; this file is UI-only. Wire the `onTap` callback on
/// each `_CollectionData` entry to your existing navigation call.
/// =================================================================

/// ---------------------------------------------------------------
/// PALETTE — matches existing NV'S branding
/// ---------------------------------------------------------------
class NVColors {
  static const charcoal = Color(0xFF0D0D0D);
  static const charcoalLight = Color(0xFF1A1A1A);
  static const ivory = Color(0xFFF8F6F2);
  static const beige = Color(0xFFE9E1D3);
  static const softGray = Color(0xFFB9B4AC);
  static const gold = Color(0xFFC9A96E);
  static const white = Color(0xFFFFFFFF);
}

/// ---------------------------------------------------------------
/// BREAKPOINTS
/// ---------------------------------------------------------------
class NVBreakpoints {
  static const smallMobile = 400.0;
  static const mobile = 600.0;
  static const tablet = 1024.0;

  static bool isSmallMobile(double w) => w < smallMobile;
  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

/// ---------------------------------------------------------------
/// COLLECTION DATA MODEL
/// (Kept intentionally simple/UI-only — map this to your existing
/// model/provider data instead of the hardcoded list below.)
/// ---------------------------------------------------------------
class NVCollectionItem {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const NVCollectionItem({
    required this.title,
    required this.imageUrl,
    this.onTap,
  });
}

final List<NVCollectionItem> _collectionItems = [
  const NVCollectionItem(
    title: 'HOODIES',
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=1400&auto=format&fit=crop',
  ),
  const NVCollectionItem(
    title: 'KIDS COLLECTION',
    imageUrl:
        'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?q=80&w=1400&auto=format&fit=crop',
  ),
  const NVCollectionItem(
    title: 'LIMITED EDITION',
    imageUrl:
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=1400&auto=format&fit=crop',
  ),
  const NVCollectionItem(
    title: 'POLO T-SHIRTS',
    imageUrl:
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?q=80&w=1400&auto=format&fit=crop',
  ),
  const NVCollectionItem(
    title: 'OVERSIZED T-SHIRTS',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1400&auto=format&fit=crop',
  ),
  const NVCollectionItem(
    title: 'NEW ARRIVALS',
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1400&auto=format&fit=crop',
  ),
];

/// =================================================================
/// COLLECTIONS PAGE
/// =================================================================
class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreakpoints.isMobile(width);

    return Scaffold(
      backgroundColor: NVColors.charcoal,
      body: Stack(
        children: [
          // ---- Background: deep charcoal/black gradient ----
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  NVColors.charcoal,
                  NVColors.charcoalLight,
                  NVColors.charcoal,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: isMobile ? 84 : 104,
                bottom: 48,
              ),
              child: _CollectionsGridSection(width: width),
            ),
          ),
          // ---- Fixed glass nav bar on top ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _GlassNav(
                isMobile: isMobile,
                scrolled: _scrollOffset > 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================================
/// GLASS NAVIGATION BAR
/// =================================================================
class _GlassNav extends StatelessWidget {
  final bool isMobile;
  final bool scrolled;

  const _GlassNav({required this.isMobile, required this.scrolled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 14 : 20,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 26,
              vertical: isMobile ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: scrolled
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _NVLogo(),
                if (!isMobile) const _NavLinks(),
                _NavTrailing(isMobile: isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NVLogo extends StatelessWidget {
  const _NVLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: NVColors.white, width: 1.1),
          ),
          child: const Text(
            'N',
            style: TextStyle(
              color: NVColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          "NV's",
          style: TextStyle(
            color: NVColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _NavLinks extends StatelessWidget {
  const _NavLinks();

  static const items = ['New Arrivals', 'Collections', 'Brand', 'Account'];

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
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          // TODO: wire to existing router/controller navigation.
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _hover
                  ? Colors.white.withOpacity(0.08)
                  : Colors.transparent,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: NVColors.white.withOpacity(_hover ? 1 : 0.82),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTrailing extends StatefulWidget {
  final bool isMobile;
  const _NavTrailing({required this.isMobile});

  @override
  State<_NavTrailing> createState() => _NavTrailingState();
}

class _NavTrailingState extends State<_NavTrailing> {
  bool _searchHover = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleIconButton(
            icon: Icons.search_rounded,
            // TODO: wire to existing search controller/route.
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.menu_rounded,
            onTap: () => _openMenu(context),
          ),
        ],
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _searchHover = true),
      onExit: (_) => setState(() => _searchHover = false),
      child: AnimatedScale(
        scale: _searchHover ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: GestureDetector(
          // TODO: wire to existing search controller/route.
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_searchHover ? 0.14 : 0.06),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.search_rounded, color: NVColors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Search',
                  style: TextStyle(
                    color: NVColors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _MobileMenuSheet(),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: NVColors.gold.withOpacity(0.25),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Icon(icon, color: NVColors.white, size: 19),
        ),
      ),
    );
  }
}

class _MobileMenuSheet extends StatelessWidget {
  const _MobileMenuSheet();

  static const items = [
    'New Arrivals',
    'Collections',
    'Brand',
    'Account',
    'Search',
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
          decoration: BoxDecoration(
            color: NVColors.charcoalLight.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ...items.map(
                (label) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // TODO: wire each item to existing router/controller.
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: NVColors.gold.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              color: NVColors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// COLLECTIONS GRID SECTION
/// =================================================================
class _CollectionsGridSection extends StatelessWidget {
  final double width;
  const _CollectionsGridSection({required this.width});

  @override
  Widget build(BuildContext context) {
    final isSmallMobile = NVBreakpoints.isSmallMobile(width);
    final isMobile = NVBreakpoints.isMobile(width);
    final isTablet = NVBreakpoints.isTablet(width);

    // Responsive column + spacing + aspect ratio rules.
    final crossAxisCount = isSmallMobile ? 1 : (isTablet ? 2 : (isMobile ? 2 : 3));
    final horizontalPadding = isMobile ? 18.0 : (isTablet ? 32.0 : 56.0);
    final spacing = isMobile ? 16.0 : 24.0;
    final aspectRatio = isSmallMobile
        ? 0.95
        : (isMobile ? 0.78 : (isTablet ? 0.82 : 0.86));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(isMobile: isMobile),
          SizedBox(height: isMobile ? 28 : 44),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _collectionItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              return _StaggerFadeIn(
                delay: Duration(milliseconds: 90 * index),
                child: _CollectionCard(item: _collectionItems[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final bool isMobile;
  const _SectionHeader({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NV\u2019S EDIT',
          style: TextStyle(
            color: NVColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Collections',
          style: TextStyle(
            color: NVColors.ivory,
            fontSize: isMobile ? 30 : 46,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Six signature ranges. One uncompromising standard.',
          style: TextStyle(
            color: NVColors.softGray,
            fontSize: isMobile ? 13.5 : 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------
/// STAGGERED FADE-IN WRAPPER
/// Delays then fades + slides its child in — used to stagger the
/// grid card entrance animation without any animation package.
/// ---------------------------------------------------------------
class _StaggerFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _StaggerFadeIn({required this.child, required this.delay});

  @override
  State<_StaggerFadeIn> createState() => _StaggerFadeInState();
}

class _StaggerFadeInState extends State<_StaggerFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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

/// =================================================================
/// COLLECTION CARD
/// Full-bleed photo card with dark overlay, hover zoom + glow border,
/// bottom-left uppercase title, and a ripple on tap.
/// =================================================================
class _CollectionCard extends StatefulWidget {
  final NVCollectionItem item;
  const _CollectionCard({required this.item});

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = NVBreakpoints.isMobile(width);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.item.onTap ?? () {},
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: _hover
                      ? NVColors.gold.withOpacity(0.30)
                      : Colors.black.withOpacity(0.45),
                  blurRadius: _hover ? 28 : 18,
                  spreadRadius: _hover ? 1 : 0,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: _hover
                    ? NVColors.gold.withOpacity(0.55)
                    : Colors.white.withOpacity(0.08),
                width: _hover ? 1.4 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ---- Image with hover zoom ----
                  AnimatedScale(
                    scale: _hover ? 1.09 : 1.0,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOut,
                    child: Image.network(
                      widget.item.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: NVColors.charcoalLight,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              color: NVColors.gold.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: NVColors.charcoalLight,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withOpacity(0.25),
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // ---- Dark gradient overlay for legibility ----
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(_hover ? 0.35 : 0.25),
                          Colors.black.withOpacity(_hover ? 0.86 : 0.78),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),

                  // ---- Soft top reflection sheen ----
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 90,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(_hover ? 0.10 : 0.05),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ---- Title + accent underline ----
                  Positioned(
                    left: isMobile ? 16 : 24,
                    right: isMobile ? 16 : 24,
                    bottom: isMobile ? 16 : 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: NVColors.white,
                            fontSize: isMobile ? 17 : 21,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: _hover ? 42 : 22,
                          decoration: BoxDecoration(
                            color: NVColors.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---- Ripple layer (kept on top, transparent) ----
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.item.onTap ?? () {},
                        splashColor: NVColors.gold.withOpacity(0.18),
                        highlightColor: Colors.white.withOpacity(0.03),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
