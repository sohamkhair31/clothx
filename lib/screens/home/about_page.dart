import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart'
    show NVColors, NVBreak, PremiumButton, ButtonVariant, NewsletterSection, FooterSection;

/// =================================================================
/// NV'S — BRAND STORY / ABOUT PAGE  (UI ONLY — single-file build)
/// =================================================================
/// Pure presentation layer. No backend, controller, model, Firebase,
/// routing, or state-management logic beyond what's needed to drive
/// this page's own visuals (reviews are kept in local widget state).
///
/// Reuses `NVColors`, `NVBreak`, `PremiumButton`, `NewsletterSection`
/// and `FooterSection` from home_screen.dart for full visual
/// consistency with the homepage — no new packages required.
///
/// WHAT CHANGED FROM THE PREVIOUS VERSION (see chat for full notes):
///  - Removed every hotlinked network image. All art is now drawn
///    with gradients/icons/typography, which is faster, works
///    offline, and can't silently fail to load mid-demo.
///  - Scroll-driven rebuilds are now scoped with a ValueNotifier so
///    only the top bar + hero parallax repaint on scroll, instead of
///    the whole page.
///  - "Why Choose NV'S" and the old "Achievements" section no longer
///    claim years of history / past customers — copy now reflects a
///    brand that hasn't launched yet.
///  - "Customer Love" is now a real (local, in-memory) review board:
///    people can add a name + star rating + review; no stock photos.
///  - The old dead "Our Story" button is gone. There's now a real
///    Our Story section on the page, and tapping "Our Story" (in the
///    hero or the top nav) smooth-scrolls to it.
///
/// INTEGRATION POINTS (search "TODO(integration)"):
///   - Wire Explore Collection / Shop Now to your real navigation.
///   - Swap the in-memory review list for Firestore/your backend
///     when ready — the widget boundary is already isolated for that.
/// =================================================================

// ---------------------------------------------------------------
// SHARED VISIBILITY HELPER (no external packages) — detects when a
// widget scrolls into view so animations/counters can trigger once.
// ---------------------------------------------------------------
class _VisibleOnScroll extends StatefulWidget {
  final Widget Function(BuildContext context, bool visible) builder;
  const _VisibleOnScroll({required this.builder});

  @override
  State<_VisibleOnScroll> createState() => _VisibleOnScrollState();
}

class _VisibleOnScrollState extends State<_VisibleOnScroll> {
  bool _visible = false;
  final GlobalKey _key = GlobalKey();

  void _check() {
    if (_visible) return;
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * 0.88) {
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        _check();
        return false;
      },
      child: KeyedSubtree(key: _key, child: widget.builder(context, _visible)),
    );
  }
}

/// Fade + slide entrance wrapper, triggered once the child scrolls
/// into view.
class _FadeSlideIn extends StatelessWidget {
  final Widget child;
  final double dy;
  const _FadeSlideIn({required this.child, this.dy = 0.08});

  @override
  Widget build(BuildContext context) {
    return _VisibleOnScroll(
      builder: (context, visible) {
        return AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : Offset(0, dy),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: child,
          ),
        );
      },
    );
  }
}

/// Counts up from 0 to [end] once [start] flips true.
class _CountUp extends StatefulWidget {
  final int end;
  final bool start;
  final TextStyle? style;
  final String suffix;
  const _CountUp({
    required this.end,
    required this.start,
    this.style,
    this.suffix = '',
  });

  @override
  State<_CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<_CountUp> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final Animation<int> _value = IntTween(begin: 0, end: widget.end)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (widget.start) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.start && !oldWidget.start) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _value,
      builder: (context, _) => Text('${_value.value}${widget.suffix}', style: widget.style),
    );
  }
}

// ---------------------------------------------------------------
// SECTION HEADER
// ---------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;
  final bool center;
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.description,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: NVColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: NVColors.charcoal,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              description!,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: NVColors.charcoal.withValues(alpha: 0.6),
                fontSize: 14.5,
                height: 1.7,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =================================================================
// ABOUT SCREEN
// =================================================================
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);
  final GlobalKey _ourStoryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // NOTE: this used to call setState() on every scroll tick, which
    // rebuilt the ENTIRE page (all sections) on every pixel scrolled.
    // A ValueNotifier + ValueListenableBuilder scopes that rebuild to
    // only the top bar and the hero's parallax layer.
    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  void _scrollToOurStory() {
    final ctx = _ourStoryKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _HeroMissionSection(
                  scrollOffset: _scrollOffset,
                  onOurStoryTap: _scrollToOurStory,
                ),
                const _FeatureGridSection(),
                const _WhyChooseSection(),
                _OurStorySection(key: _ourStoryKey),
                const _CoreValuesSection(),
                const _LuxuryExperienceSection(),
                const _ProcessSection(),
                const _RoadAheadSection(),
                const _ReviewsSection(),
                const _LookbookGallerySection(),
                const _FAQSection(),
                const NewsletterSection(),
                const FooterSection(),
              ],
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, _) => _AboutTopBar(
              scrollOffset: offset,
              onBrandTap: _scrollToOurStory,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// TOP BAR
// =================================================================
class _AboutTopBar extends StatelessWidget {
  final double scrollOffset;
  final VoidCallback onBrandTap;
  const _AboutTopBar({required this.scrollOffset, required this.onBrandTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final scrolled = scrollOffset > 30;
      final fg = scrolled ? NVColors.charcoal : Colors.white;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 18 : 40,
          vertical: isMobile ? 14 : 20,
        ),
        decoration: BoxDecoration(
          color: scrolled ? NVColors.white.withValues(alpha: 0.92) : Colors.transparent,
          boxShadow: scrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // FIX: the old version rendered "NV's" twice here.
            Text(
              "NV\u2019S",
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 18 : 22,
                letterSpacing: 0.4,
              ),
            ),
            isMobile
                ? Icon(Icons.menu_rounded, color: fg)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavLink(label: 'Collections', color: fg, onTap: () {}),
                      _NavLink(label: 'Brand', color: fg, onTap: onBrandTap),
                      _NavLink(label: 'Account', color: fg, onTap: () {}),
                      _NavLink(label: 'Search', color: fg, onTap: () {}),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// =================================================================
// HERO — MISSION + GLASS FEATURE CARDS
// =================================================================
class _HeroFeatureData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _HeroFeatureData(this.icon, this.title, this.subtitle);
}

const _heroFeatures = [
  _HeroFeatureData(Icons.diamond_outlined, 'PREMIUM QUALITY', 'Luxury Fabric'),
  _HeroFeatureData(Icons.public_rounded, 'WORLDWIDE SHIPPING', 'Moving Globe'),
  _HeroFeatureData(Icons.workspace_premium_outlined, 'LIMITED COLLECTIONS', 'Exclusivity'),
  _HeroFeatureData(Icons.eco_outlined, 'ECO FRIENDLY', 'Sustainable Material'),
];

class _HeroMissionSection extends StatefulWidget {
  final ValueListenable<double> scrollOffset;
  final VoidCallback onOurStoryTap;
  const _HeroMissionSection({required this.scrollOffset, required this.onOurStoryTap});

  @override
  State<_HeroMissionSection> createState() => _HeroMissionSectionState();
}

class _HeroMissionSectionState extends State<_HeroMissionSection> with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _drift.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entrance.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isMobile = NVBreak.isMobile(width);
      final isTablet = NVBreak.isTablet(width);
      final stacked = isMobile || isTablet;

      final fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
      final slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
          .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

      final mission = FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: stacked ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                'THE NV\u2019S PHILOSOPHY',
                textAlign: stacked ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  color: NVColors.gold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: stacked ? TextAlign.center : TextAlign.start,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isMobile ? 30 : (isTablet ? 40 : 48),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                  children: const [
                    TextSpan(text: "OUR MISSION ISN\u2019T SIMPLY\nTO SELL CLOTHING."),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: stacked ? WrapAlignment.center : WrapAlignment.start,
                children: [
                  _MissionLine(text: 'WE CREATE ', keyword: 'CONFIDENCE.', big: isMobile ? 22 : 30),
                  _MissionLine(text: 'WE CREATE ', keyword: 'IDENTITY.', big: isMobile ? 22 : 30),
                  _MissionLine(text: 'WE CREATE ', keyword: 'CULTURE.', big: isMobile ? 22 : 30),
                ],
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  'An independent luxury label crafting garments at the intersection '
                  'of architecture and attitude \u2014 for those who lead rather than follow.',
                  textAlign: stacked ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14.5,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              Wrap(
                alignment: stacked ? WrapAlignment.center : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 18,
                runSpacing: 14,
                children: [
                  PremiumButton(
                    label: 'Explore Collection',
                    variant: ButtonVariant.solid,
                    small: isMobile,
                    onTap: () {}, // TODO(integration): wire to real navigation
                  ),
                  PremiumButton(
                    label: 'Shop Now',
                    variant: ButtonVariant.outline,
                    small: isMobile,
                    onTap: () {}, // TODO(integration): wire to real navigation
                  ),
                  _OurStoryLink(onTap: widget.onOurStoryTap),
                ],
              ),
            ],
          ),
        ),
      );

      final cardsGrid = FadeTransition(
        opacity: fade,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: _heroFeatures
              .map((f) => SizedBox(
                    width: stacked ? (width - (isMobile ? 48 : 88)) / 2 : 190,
                    child: RepaintBoundary(child: _GlassFeatureCard(data: f)),
                  ))
              .toList(),
        ),
      );

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: stacked ? 0 : 640),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Decorative background: gradients + typography only, no
            // network image, so it never fails to load and never
            // triggers a network request.
            Positioned.fill(
              child: ValueListenableBuilder<double>(
                valueListenable: widget.scrollOffset,
                builder: (context, offset, child) {
                  final parallax = (offset * 0.3).clamp(0.0, 100.0);
                  return Transform.translate(offset: Offset(0, -parallax), child: child);
                },
                child: RepaintBoundary(child: _HeroBackgroundArt(driftController: _drift)),
              ),
            ),
            const Positioned(top: 90, left: 60, child: RepaintBoundary(child: _FloatingRing(size: 46))),
            const Positioned(bottom: 140, right: 90, child: RepaintBoundary(child: _FloatingRing(size: 30))),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 48,
                isMobile ? 110 : 150,
                isMobile ? 20 : 48,
                isMobile ? 48 : 70,
              ),
              child: stacked
                  ? Column(
                      children: [
                        mission,
                        const SizedBox(height: 44),
                        cardsGrid,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: mission),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 5,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _heroFeatures
                                .map((f) => SizedBox(
                                      width: 200,
                                      child: RepaintBoundary(child: _GlassFeatureCard(data: f)),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Center(child: _ScrollHint()),
            ),
          ],
        ),
      );
    });
  }
}

/// Purely decorative hero backdrop: layered gradients, a faint
/// diagonal texture, a soft drifting gold glow, and a huge low-opacity
/// monogram. Costs nothing over the network and can't fail to render.
class _HeroBackgroundArt extends StatelessWidget {
  final AnimationController driftController;
  const _HeroBackgroundArt({required this.driftController});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static base gradient.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NVColors.charcoal,
                  Color.lerp(NVColors.charcoal, Colors.black, 0.45)!,
                  NVColors.charcoal,
                ],
              ),
            ),
          ),
          // Static faint texture — painted once, never repaints.
          const RepaintBoundary(child: CustomPaint(painter: _DiagonalLinesPainter())),
          // Static giant monogram watermark.
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Text(
                'N',
                style: TextStyle(
                  fontSize: 420,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          // Only this small piece re-animates every frame.
          AnimatedBuilder(
            animation: driftController,
            builder: (context, _) {
              final align = Alignment.lerp(
                const Alignment(-0.7, -0.9),
                const Alignment(0.7, -0.5),
                driftController.value,
              )!;
              return Align(
                alignment: align,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        NVColors.gold.withValues(alpha: 0.20),
                        NVColors.gold.withValues(alpha: 0.0),
                      ],
                    ),
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

class _DiagonalLinesPainter extends CustomPainter {
  const _DiagonalLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const gap = 46.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalLinesPainter oldDelegate) => false;
}

class _MissionLine extends StatelessWidget {
  final String text;
  final String keyword;
  final double big;
  const _MissionLine({required this.text, required this.keyword, required this.big});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: big,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.35,
          ),
          children: [
            TextSpan(text: text),
            TextSpan(text: keyword, style: TextStyle(color: NVColors.gold)),
          ],
        ),
      ),
    );
  }
}

class _FloatingRing extends StatefulWidget {
  final double size;
  const _FloatingRing({required this.size});

  @override
  State<_FloatingRing> createState() => _FloatingRingState();
}

class _FloatingRingState extends State<_FloatingRing> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  late final Animation<double> _float =
      Tween<double>(begin: 0, end: 16).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.4),
        ),
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat(reverse: true);
  late final Animation<double> _float =
      Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(offset: Offset(0, _float.value), child: child),
      child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.7), size: 30),
    );
  }
}

/// Replaces the old dead "Our Story" button. Looks like a link, not a
/// CTA, and actually does something: smooth-scrolls to the real
/// Our Story section further down the page.
class _OurStoryLink extends StatefulWidget {
  final VoidCallback onTap;
  const _OurStoryLink({required this.onTap});

  @override
  State<_OurStoryLink> createState() => _OurStoryLinkState();
}

class _OurStoryLinkState extends State<_OurStoryLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _hover ? NVColors.gold : Colors.white.withValues(alpha: 0.4),
                width: 1.4,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Our Story',
                style: TextStyle(
                  color: _hover ? NVColors.gold : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSlide(
                offset: _hover ? const Offset(0, 0.15) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.arrow_downward_rounded, size: 15, color: _hover ? NVColors.gold : Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// GLASSMORPHISM CARD (shared)
// ---------------------------------------------------------------
class _GlassFeatureCard extends StatefulWidget {
  final _HeroFeatureData data;
  const _GlassFeatureCard({required this.data});

  @override
  State<_GlassFeatureCard> createState() => _GlassFeatureCardState();
}

class _GlassFeatureCardState extends State<_GlassFeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _hover ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _hover ? NVColors.gold.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: _hover
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NVColors.gold.withValues(alpha: 0.18),
                    ),
                    child: Icon(widget.data.icon, color: NVColors.gold, size: 20),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.data.subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11.5),
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

// =================================================================
// FEATURE GRID — "THE NV'S PROMISE" (10 features)
// =================================================================
class _PromiseFeature {
  final IconData icon;
  final String title;
  final String desc;
  const _PromiseFeature(this.icon, this.title, this.desc);
}

const _promiseFeatures = [
  _PromiseFeature(Icons.diamond_outlined, 'Premium Quality', 'Every garment engineered from fabrics chosen for feel and longevity.'),
  _PromiseFeature(Icons.public_rounded, 'Worldwide Shipping', 'Built to deliver to over 120 countries with reliable, trackable logistics.'),
  _PromiseFeature(Icons.workspace_premium_outlined, 'Limited Collections', 'Small-batch drops designed to stay exclusive, never oversaturated.'),
  _PromiseFeature(Icons.eco_outlined, 'Eco-Friendly Materials', 'Responsibly sourced textiles with a lighter footprint on the planet.'),
  _PromiseFeature(Icons.handyman_outlined, 'Handcrafted Excellence', 'Finished by skilled hands, not rushed off an assembly line.'),
  _PromiseFeature(Icons.replay_rounded, 'Easy Returns', 'A no-friction 30-day return window on every single order.'),
  _PromiseFeature(Icons.lock_outline_rounded, 'Secure Payments', 'Encrypted checkout with every major payment method supported.'),
  _PromiseFeature(Icons.support_agent_rounded, '24/7 Customer Support', 'A real human, day or night, whenever you need one.'),
  _PromiseFeature(Icons.eco_rounded, 'Sustainable Packaging', 'Recyclable, plastic-minimised packaging on every shipment.'),
  _PromiseFeature(Icons.favorite_border_rounded, 'Lifetime Customer Care', 'We\u2019ll stand behind what we make, long after you\u2019ve worn it in.'),
];

class _FeatureGridSection extends StatelessWidget {
  const _FeatureGridSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isMobile = NVBreak.isMobile(width);
      final isTablet = NVBreak.isTablet(width);
      final columns = isMobile ? 2 : (isTablet ? 3 : 5);

      return Container(
        color: NVColors.ivory,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'The NV\u2019S Promise',
                title: 'Why fashion houses like ours exist',
                description: 'Ten commitments that will shape every decision, from fabric mill to final stitch.',
                center: true,
              ),
            ),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _promiseFeatures.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: isMobile ? 0.92 : 0.98,
              ),
              itemBuilder: (context, i) => _FadeSlideIn(child: _PromiseCard(data: _promiseFeatures[i])),
            ),
          ],
        ),
      );
    });
  }
}

class _PromiseCard extends StatefulWidget {
  final _PromiseFeature data;
  const _PromiseCard({required this.data});

  @override
  State<_PromiseCard> createState() => _PromiseCardState();
}

class _PromiseCardState extends State<_PromiseCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: NVColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hover ? NVColors.gold.withValues(alpha: 0.5) : NVColors.charcoal.withValues(alpha: 0.06),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: NVColors.charcoal.withValues(alpha: _hover ? 0.1 : 0.03),
              blurRadius: _hover ? 20 : 8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.beige.withValues(alpha: 0.6)),
              child: Icon(widget.data.icon, color: NVColors.charcoal, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              widget.data.title,
              style: TextStyle(color: NVColors.charcoal, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                widget.data.desc,
                style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 11.5, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// WHY CHOOSE NV'S — stats, animated slogan, forward-looking roadmap
// (content rewritten: no fake "18 years" / "250K customers" claims
// for a brand that hasn't launched)
// =================================================================
const _slogans = [
  'Crafted with precision.',
  'Designed for confidence.',
  'Built to outlast trends.',
  'Independent by choice.',
  'Details define us.',
  'Luxury, redefined.',
];

class _RoadmapStep {
  final String date;
  final String title;
  final String desc;
  const _RoadmapStep(this.date, this.title, this.desc);
}

const _roadmap = [
  _RoadmapStep('Q1 2025', 'The Spark', 'Two friends, one frustration with same-old menswear, and a sketchbook.'),
  _RoadmapStep('Q3 2025', 'First Prototypes', 'Sample garments cut, unpicked, and sewn again until they felt right.'),
  _RoadmapStep('Q1 2026', 'Sourcing Partners', 'Ethical mills and small ateliers signed on across three countries.'),
  _RoadmapStep('Q2 2026', 'Building The Atelier', 'Our first studio takes shape \u2014 pattern tables, pins, a lot of coffee.'),
  _RoadmapStep('Q4 2026', 'Debut Collection', 'The first NV\u2019S pieces are cut, finished, and ready to ship.'),
  _RoadmapStep('What\u2019s Next', 'Global Launch', 'Opening our doors to the world \u2014 starting with you.'),
];

class _WhyChooseSection extends StatefulWidget {
  const _WhyChooseSection();

  @override
  State<_WhyChooseSection> createState() => _WhyChooseSectionState();
}

class _WhyChooseSectionState extends State<_WhyChooseSection> {
  final PageController _sloganController = PageController();
  Timer? _timer;
  int _sloganIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_sloganController.hasClients) return;
      _sloganIndex = (_sloganIndex + 1) % _slogans.length;
      _sloganController.animateToPage(
        _sloganIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sloganController.dispose();
    super.dispose();
  }

  void _goTo(int delta) {
    _sloganIndex = (_sloganIndex + delta) % _slogans.length;
    if (_sloganIndex < 0) _sloganIndex += _slogans.length;
    _sloganController.animateToPage(
      _sloganIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);

      return Container(
        width: double.infinity,
        color: NVColors.beige.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Why Choose NV\u2019S",
                    style: TextStyle(color: NVColors.charcoal, fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!isMobile) ...[
                  SizedBox(
                    width: 220,
                    height: 26,
                    child: PageView.builder(
                      controller: _sloganController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _slogans.length,
                      itemBuilder: (context, i) => Center(
                        child: Text(
                          _slogans[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _RoundArrow(icon: Icons.chevron_left_rounded, onTap: () => _goTo(-1)),
                  const SizedBox(width: 8),
                  _RoundArrow(icon: Icons.chevron_right_rounded, onTap: () => _goTo(1)),
                  const SizedBox(width: 12),
                  Text(
                    '0${_sloganIndex + 1} / 0${_slogans.length}',
                    style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 24,
                child: PageView.builder(
                  controller: _sloganController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _slogans.length,
                  itemBuilder: (context, i) => Center(
                    child: Text(
                      _slogans[i],
                      style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: isMobile ? 36 : 56),
            _FadeSlideIn(child: _StatsRow(isMobile: isMobile)),
            SizedBox(height: isMobile ? 48 : 70),
            _FadeSlideIn(child: _RoadmapTimeline(isMobile: isMobile)),
          ],
        ),
      );
    });
  }
}

class _RoundArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.2))),
        child: Icon(icon, size: 16, color: NVColors.charcoal),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final bool isMobile;
  const _StatsRow({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return _VisibleOnScroll(builder: (context, visible) {
      final stats = [
        _CountUp(end: 50, start: visible, suffix: '+', style: _statStyle()),
        _CountUp(end: 12, start: visible, style: _statStyle()),
        _CountUp(end: 100, start: visible, suffix: '%', style: _statStyle()),
        _CountUp(end: 120, start: visible, suffix: '+', style: _statStyle()),
      ];
      const labels = [
        'Pieces In Our Debut Collection',
        'Master Artisans On Our Team',
        'Ethically Sourced Fabrics',
        'Countries Ready For Shipping',
      ];
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 26,
        children: List.generate(4, (i) {
          return SizedBox(
            width: isMobile ? 150 : 200,
            child: Column(
              children: [
                stats[i],
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  TextStyle _statStyle() => TextStyle(color: NVColors.charcoal, fontSize: isMobile ? 30 : 40, fontWeight: FontWeight.w700);
}

class _RoadmapTimeline extends StatelessWidget {
  final bool isMobile;
  const _RoadmapTimeline({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: List.generate(_roadmap.length, (i) {
          final step = _roadmap[i];
          final isLast = i == _roadmap.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.gold)),
                    if (!isLast)
                      Expanded(child: Container(width: 2, color: NVColors.charcoal.withValues(alpha: 0.15))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _RoadmapText(step: step),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _roadmap.length,
        separatorBuilder: (context, i) => SizedBox(
          width: 46,
          child: Center(child: Container(height: 2, color: NVColors.charcoal.withValues(alpha: 0.15))),
        ),
        itemBuilder: (context, i) {
          final step = _roadmap[i];
          return SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.gold)),
                const SizedBox(height: 16),
                _RoadmapText(step: step),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoadmapText extends StatelessWidget {
  final _RoadmapStep step;
  const _RoadmapText({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.date, style: TextStyle(color: NVColors.gold, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(step.title, style: TextStyle(color: NVColors.charcoal, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(step.desc, style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5, height: 1.5)),
      ],
    );
  }
}

// =================================================================
// OUR STORY (new) — this is what the hero's "Our Story" link
// scrolls to.
// =================================================================
class _OurStorySection extends StatelessWidget {
  const _OurStorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final stacked = isMobile || NVBreak.isTablet(constraints.maxWidth);

      final textBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(eyebrow: 'How It Began', title: 'Our Story'),
          const SizedBox(height: 18),
          Text(
            'NV\u2019S started as a conversation between two friends who felt luxury '
            'menswear had stopped taking risks. Everything looked the same, felt the '
            'same, and said nothing about the person wearing it.',
            style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.75), fontSize: 14.5, height: 1.8),
          ),
          const SizedBox(height: 16),
          Text(
            'So we started sketching. Then sourcing. Then sitting with pattern-makers '
            'until a shoulder seam finally felt right. No investors rushing us, no '
            'trend cycle to chase \u2014 just a small team building the label we always '
            'wanted to wear ourselves.',
            style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.75), fontSize: 14.5, height: 1.8),
          ),
          const SizedBox(height: 16),
          Text(
            'We\u2019re not a heritage house with decades behind us. We\u2019re a first '
            'chapter, written carefully \u2014 and we\u2019d love for you to be part of it '
            'from page one.',
            style: TextStyle(color: NVColors.charcoal, fontSize: 15, fontWeight: FontWeight.w600, height: 1.8),
          ),
        ],
      );

      const artBlock = _StoryArt();

      return Container(
        color: NVColors.white,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: stacked
            ? const Column(children: [artBlock, SizedBox(height: 36), _StoryTextPlaceholder()])
                .let((_) => Column(children: [artBlock, const SizedBox(height: 36), textBlock]))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: textBlock),
                  const SizedBox(width: 50),
                  const Expanded(flex: 4, child: artBlock),
                ],
              ),
      );
    });
  }
}

class _StoryTextPlaceholder extends StatelessWidget {
  const _StoryTextPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

class _StoryArt extends StatelessWidget {
  const _StoryArt();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [NVColors.charcoal, Color.lerp(NVColors.charcoal, Colors.black, 0.3)!],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.08,
                child: Text('N', style: TextStyle(fontSize: 170, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: NVColors.gold.withValues(alpha: 0.6), width: 1.4),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Text(
                  'EST. 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: NVColors.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// CORE VALUES
// =================================================================
class _CoreValue {
  final IconData icon;
  final String title;
  final String desc;
  const _CoreValue(this.icon, this.title, this.desc);
}

const _coreValues = [
  _CoreValue(Icons.verified_outlined, 'Quality', 'Uncompromising standards from raw material to finished seam.'),
  _CoreValue(Icons.lightbulb_outline_rounded, 'Innovation', 'Rethinking silhouettes, fabrics, and how luxury is delivered.'),
  _CoreValue(Icons.eco_outlined, 'Sustainability', 'Responsible sourcing woven into every stage of production.'),
  _CoreValue(Icons.fingerprint_rounded, 'Authenticity', 'Original design language, never chasing someone else\u2019s trend.'),
  _CoreValue(Icons.precision_manufacturing_outlined, 'Craftsmanship', 'Skilled hands and decades of combined tailoring expertise.'),
  _CoreValue(Icons.emoji_emotions_outlined, 'Customer Satisfaction', 'Every interaction held to the same standard as our garments.'),
];

class _CoreValuesSection extends StatelessWidget {
  const _CoreValuesSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final isTablet = NVBreak.isTablet(constraints.maxWidth);
      final columns = isMobile ? 1 : (isTablet ? 2 : 3);

      return Container(
        color: NVColors.white,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            const _FadeSlideIn(child: _SectionHeader(eyebrow: 'What We Stand For', title: 'Our Core Values', center: true)),
            const SizedBox(height: 40),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _coreValues.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: isMobile ? 2.6 : 1.5,
              ),
              itemBuilder: (context, i) => _FadeSlideIn(child: _CoreValueCard(data: _coreValues[i])),
            ),
          ],
        ),
      );
    });
  }
}

class _CoreValueCard extends StatefulWidget {
  final _CoreValue data;
  const _CoreValueCard({required this.data});

  @override
  State<_CoreValueCard> createState() => _CoreValueCardState();
}

class _CoreValueCardState extends State<_CoreValueCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hover ? NVColors.beige.withValues(alpha: 0.4) : NVColors.ivory,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hover ? NVColors.gold.withValues(alpha: 0.4) : Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.data.icon, color: NVColors.gold, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.data.title, style: TextStyle(color: NVColors.charcoal, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(widget.data.desc, style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// LUXURY EXPERIENCE — icon-forward cards (no hotlinked photography)
// =================================================================
class _LuxuryExperienceSection extends StatelessWidget {
  const _LuxuryExperienceSection();

  static const _items = [
    ('Premium Fabrics', 'Sourced from mills we\u2019re proud to call partners.', Icons.texture_rounded),
    ('Exclusive Collections', 'Small-batch drops designed to never be repeated.', Icons.workspace_premium_outlined),
    ('Attention to Detail', 'Every stitch considered before a single thread is cut.', Icons.design_services_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);

      return Container(
        color: NVColors.beige.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            const _FadeSlideIn(child: _SectionHeader(eyebrow: 'The Luxury Experience', title: 'Where fabric meets philosophy', center: true)),
            const SizedBox(height: 36),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _items
                  .map((item) => SizedBox(
                        width: isMobile ? double.infinity : 340,
                        child: _FadeSlideIn(child: _ExperienceCard(title: item.$1, desc: item.$2, icon: item.$3)),
                      ))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _ExperienceCard extends StatefulWidget {
  final String title;
  final String desc;
  final IconData icon;
  const _ExperienceCard({required this.title, required this.desc, required this.icon});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        child: AspectRatio(
          aspectRatio: 0.95,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NVColors.charcoal, Color.lerp(NVColors.charcoal, Colors.black, 0.35)!],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(widget.icon, size: 140, color: Colors.white.withValues(alpha: _hover ? 0.10 : 0.06)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.gold.withValues(alpha: 0.18)),
                          child: Icon(widget.icon, color: NVColors.gold, size: 20),
                        ),
                        const Spacer(),
                        Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(widget.desc, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5, height: 1.5)),
                      ],
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

// =================================================================
// OUR PROCESS
// =================================================================
class _ProcessStepData {
  final IconData icon;
  final String title;
  final String desc;
  const _ProcessStepData(this.icon, this.title, this.desc);
}

const _processSteps = [
  _ProcessStepData(Icons.edit_outlined, 'Design', 'Sketches born from mood boards and street-level research.'),
  _ProcessStepData(Icons.texture_rounded, 'Fabric Selection', 'Sourcing textiles for hand-feel, drape, and durability.'),
  _ProcessStepData(Icons.handyman_outlined, 'Craftsmanship', 'Cut and sewn by artisans with decades of experience.'),
  _ProcessStepData(Icons.fact_check_outlined, 'Quality Check', 'Every piece inspected against a strict internal standard.'),
  _ProcessStepData(Icons.local_shipping_outlined, 'Delivery', 'Packed with care and shipped straight to your door.'),
];

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);

      return Container(
        color: NVColors.white,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            const _FadeSlideIn(child: _SectionHeader(eyebrow: 'How It\u2019s Made', title: 'Our Process', center: true)),
            const SizedBox(height: 40),
            _FadeSlideIn(
              child: isMobile
                  ? Column(
                      children: List.generate(_processSteps.length, (i) {
                        final isLast = i == _processSteps.length - 1;
                        return Column(
                          children: [
                            _ProcessNode(index: i, data: _processSteps[i]),
                            if (!isLast)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Icon(Icons.keyboard_arrow_down_rounded, color: NVColors.charcoal.withValues(alpha: 0.3)),
                              ),
                          ],
                        );
                      }),
                    )
                  : Row(
                      children: List.generate(_processSteps.length * 2 - 1, (i) {
                        if (i.isOdd) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.arrow_forward_rounded, color: NVColors.charcoal.withValues(alpha: 0.25)),
                            ),
                          );
                        }
                        final stepIndex = i ~/ 2;
                        return Expanded(flex: 3, child: _ProcessNode(index: stepIndex, data: _processSteps[stepIndex]));
                      }),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _ProcessNode extends StatelessWidget {
  final int index;
  final _ProcessStepData data;
  const _ProcessNode({required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.charcoal),
          child: Icon(data.icon, color: NVColors.gold, size: 26),
        ),
        const SizedBox(height: 12),
        Text('0${index + 1}', style: TextStyle(color: NVColors.gold, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(data.title, textAlign: TextAlign.center, style: TextStyle(color: NVColors.charcoal, fontSize: 13.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        SizedBox(
          width: 140,
          child: Text(data.desc, textAlign: TextAlign.center, style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 11.5, height: 1.5)),
        ),
      ],
    );
  }
}

// =================================================================
// THE ROAD AHEAD (formerly "Achievements & Milestones") — rewritten
// as forward-looking goals instead of fake past awards, since NV'S
// hasn't launched yet.
// =================================================================
const _roadAhead = [
  ('Q3 2026', 'Debut Collection Launch', Icons.rocket_launch_outlined),
  ('Q4 2026', 'First Flagship Pop-Up', Icons.storefront_outlined),
  ('2027', 'Certified Sustainable Sourcing', Icons.eco_outlined),
  ('2027', 'Shipping To 120+ Countries', Icons.public_rounded),
  ('2028', 'Our First Flagship Store', Icons.location_city_outlined),
];

class _RoadAheadSection extends StatelessWidget {
  const _RoadAheadSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      return Container(
        color: NVColors.charcoal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            _FadeSlideIn(
              child: Column(
                children: [
                  Text('THE ROAD AHEAD', style: TextStyle(color: NVColors.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
                  const SizedBox(height: 12),
                  Text('Where We\u2019re Headed', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _FadeSlideIn(
              child: SizedBox(
                height: isMobile ? null : 160,
                child: isMobile
                    ? Column(
                        children: _roadAhead.map((a) => Padding(padding: const EdgeInsets.only(bottom: 20), child: _RoadAheadTile(data: a))).toList(),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _roadAhead.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 28),
                        itemBuilder: (context, i) => SizedBox(width: 220, child: _RoadAheadTile(data: _roadAhead[i])),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RoadAheadTile extends StatelessWidget {
  final (String, String, IconData) data;
  const _RoadAheadTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.$3, color: NVColors.gold, size: 24),
          const SizedBox(height: 14),
          Text(data.$1, style: TextStyle(color: NVColors.gold, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(data.$2, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)),
        ],
      ),
    );
  }
}

// =================================================================
// CUSTOMER LOVE — now a real (local, in-memory) review board.
// No stock photos, no fake names — people can actually add a review.
// =================================================================
class _UserReview {
  final String name;
  final int rating;
  final String text;
  final DateTime date;
  const _UserReview({required this.name, required this.rating, required this.text, required this.date});
}

class _ReviewsSection extends StatefulWidget {
  const _ReviewsSection();

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  // TODO(integration): swap this in-memory list for Firestore reads/writes
  // when the backend is ready. The UI below doesn't care where the data
  // comes from.
  final List<_UserReview> _reviews = [];

  Future<void> _openReviewDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final textController = TextEditingController();
    int rating = 5;

    final result = await showDialog<_UserReview>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: NVColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: 24 + MediaQuery.of(dialogContext).viewInsets.bottom,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share Your Experience', style: TextStyle(color: NVColors.charcoal, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          'Your review helps shape NV\u2019S from day one.',
                          style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5),
                        ),
                        const SizedBox(height: 18),
                        Text('Your Rating', style: TextStyle(color: NVColors.charcoal, fontSize: 12.5, fontWeight: FontWeight.w600)),
                        _StarPicker(rating: rating, onChanged: (r) => setDialogState(() => rating = r)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: _inputDecoration('Your Name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: textController,
                          maxLines: 3,
                          decoration: _inputDecoration('Your Review'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please share a few words' : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: Text('Cancel', style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6))),
                            ),
                            const SizedBox(width: 8),
                            PremiumButton(
                              label: 'Submit',
                              variant: ButtonVariant.solid,
                              small: true,
                              onTap: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  Navigator.of(dialogContext).pop(
                                    _UserReview(
                                      name: nameController.text.trim(),
                                      rating: rating,
                                      text: textController.text.trim(),
                                      date: DateTime.now(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    textController.dispose();

    if (result != null && mounted) {
      setState(() => _reviews.insert(0, result));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: NVColors.charcoal.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: NVColors.gold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final avgRating = _reviews.isEmpty ? 0.0 : _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

      return Container(
        color: NVColors.ivory,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'Customer Love',
                title: 'Be Among The First To Share',
                description: 'We just opened our doors \u2014 your voice helps shape what NV\u2019S becomes. Leave the first review.',
                center: true,
              ),
            ),
            const SizedBox(height: 20),
            if (_reviews.isNotEmpty) _RatingSummary(average: avgRating, count: _reviews.length),
            const SizedBox(height: 28),
            PremiumButton(label: 'Write a Review', variant: ButtonVariant.solid, onTap: _openReviewDialog),
            const SizedBox(height: 36),
            Center(
              child: _reviews.isEmpty
                  ? const _EmptyReviewsHint()
                  : (isMobile
                      ? Column(
                          children: _reviews.map((r) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _ReviewCard(review: r))).toList(),
                        )
                      : Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          alignment: WrapAlignment.center,
                          children: _reviews.map((r) => SizedBox(width: 340, child: _ReviewCard(review: r))).toList(),
                        )),
            ),
          ],
        ),
      );
    });
  }
}

class _StarPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  const _StarPicker({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(i + 1),
          icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded, color: NVColors.gold, size: 26),
        );
      }),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final double average;
  final int count;
  const _RatingSummary({required this.average, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final filled = i < average.round();
            return Icon(filled ? Icons.star_rounded : Icons.star_border_rounded, color: NVColors.gold, size: 22);
          }),
        ),
        const SizedBox(height: 6),
        Text(
          '${average.toStringAsFixed(1)} out of 5 \u00b7 $count review${count == 1 ? '' : 's'}',
          style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5),
        ),
      ],
    );
  }
}

class _EmptyReviewsHint extends StatelessWidget {
  const _EmptyReviewsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, color: NVColors.gold, size: 30),
          const SizedBox(height: 12),
          Text('No reviews yet', style: TextStyle(color: NVColors.charcoal, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Be the very first to tell the world what you think of NV\u2019S.',
            textAlign: TextAlign.center,
            style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _UserReview review;
  const _ReviewCard({required this.review});

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: NVColors.charcoal.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_border_rounded, color: NVColors.gold, size: 16))),
          const SizedBox(height: 12),
          Text('\u201C${review.text}\u201D', style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.75), fontSize: 13.5, height: 1.6)),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: NVColors.beige,
                child: Text(
                  review.name.isNotEmpty ? review.name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(color: NVColors.charcoal, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name, style: TextStyle(color: NVColors.charcoal, fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(_formatDate(review.date), style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.5), fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================================
// LOOKBOOK — teaser tiles (no hotlinked photography; the real
// lookbook ships with the debut collection)
// =================================================================
const _lookbookTeasers = [
  ('Look 01', Icons.checkroom_outlined),
  ('Look 02', Icons.dry_cleaning_outlined),
  ('Look 03', Icons.local_mall_outlined),
  ('Look 04', Icons.style_outlined),
  ('Look 05', Icons.diamond_outlined),
  ('Look 06', Icons.auto_awesome_outlined),
  ('Look 07', Icons.watch_outlined),
  ('Look 08', Icons.shopping_bag_outlined),
];

class _LookbookGallerySection extends StatelessWidget {
  const _LookbookGallerySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final isTablet = NVBreak.isTablet(constraints.maxWidth);
      final columns = isMobile ? 2 : (isTablet ? 3 : 4);

      final heights = List.generate(_lookbookTeasers.length, (i) => 140.0 + (i % 3) * 50);
      final colBuckets = List.generate(columns, (_) => <int>[]);
      for (var i = 0; i < _lookbookTeasers.length; i++) {
        colBuckets[i % columns].add(i);
      }

      return Container(
        color: NVColors.white,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'Follow The Story',
                title: 'The Lookbook',
                description: 'Our first full lookbook drops alongside the debut collection \u2014 here\u2019s a preview of what\u2019s coming.',
                center: true,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: colBuckets
                  .map(
                    (indices) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: indices
                              .map((i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _GalleryTeaserTile(
                                      label: _lookbookTeasers[i].$1,
                                      icon: _lookbookTeasers[i].$2,
                                      height: heights[i],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _GalleryTeaserTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final double height;
  const _GalleryTeaserTile({required this.label, required this.icon, required this.height});

  @override
  State<_GalleryTeaserTile> createState() => _GalleryTeaserTileState();
}

class _GalleryTeaserTileState extends State<_GalleryTeaserTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _hover
                ? [NVColors.charcoal, Color.lerp(NVColors.charcoal, NVColors.gold, 0.35)!]
                : [NVColors.beige.withValues(alpha: 0.7), NVColors.beige.withValues(alpha: 0.35)],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: _hover ? Colors.white : NVColors.charcoal.withValues(alpha: 0.5), size: 26),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                color: _hover ? Colors.white : NVColors.charcoal.withValues(alpha: 0.6),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            if (_hover) ...[
              const SizedBox(height: 4),
              Text('Coming Soon', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}

// =================================================================
// FAQ ACCORDION
// =================================================================
const _faqs = [
  ('What makes NV\u2019S different from fast fashion?',
      'We produce in small, limited batches using higher-grade fabrics, and every piece is finished by hand rather than rushed through mass production.'),
  ('How long does shipping take?',
      'Once orders go live, domestic delivery is expected in 3\u20135 business days and international in 7\u201314 business days, depending on destination.'),
  ('What is your return policy?',
      'We\u2019ll offer a 30-day no-questions-asked return window on unworn items with original tags attached.'),
  ('Are your materials sustainably sourced?',
      'Yes \u2014 the majority of our textiles come from certified responsible mills, and we\u2019re expanding that percentage every season.'),
  ('Do you ship internationally?',
      'We\u2019re building for day-one shipping to over 120 countries worldwide with tracked, insured delivery.'),
];

class _FAQSection extends StatelessWidget {
  const _FAQSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      return Container(
        color: NVColors.beige.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            const _FadeSlideIn(child: _SectionHeader(eyebrow: 'Good To Know', title: 'Frequently Asked Questions', center: true)),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: _faqs.map((f) => _FadeSlideIn(child: _FAQItem(question: f.$1, answer: f.$2))).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _open ? NVColors.gold.withValues(alpha: 0.5) : NVColors.charcoal.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.question, style: TextStyle(color: NVColors.charcoal, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: NVColors.charcoal.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.answer, style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 13, height: 1.6)),
              ),
            ),
            crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}