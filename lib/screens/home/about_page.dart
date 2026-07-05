import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../home/home_screen.dart'
    show NVColors, NVBreak, PremiumButton, ButtonVariant, NewsletterSection, FooterSection;

/// =================================================================
/// NV'S — BRAND STORY / ABOUT PAGE  (UI ONLY — single-file build)
/// =================================================================
/// Pure presentation layer. No backend, controller, model, Firebase,
/// routing, or state-management logic is included or assumed beyond
/// what's needed to drive this page's own visuals.
///
/// Reuses `NVColors`, `NVBreak`, `PremiumButton`, `NewsletterSection`
/// and `FooterSection` from home_screen.dart for full visual
/// consistency with the homepage — no new packages required.
///
/// INTEGRATION POINTS (search "TODO(integration)"):
///   - Replace mock copy/stats/testimonials with real CMS/Firestore data.
///   - Wire CTA button `onTap`s to your existing navigation.
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

class _CountUpState extends State<_CountUp> with SingleTickerProviderStateMixin {
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
                _HeroMissionSection(scrollOffset: _scrollOffset),
                const _FeatureGridSection(),
                const _WhyChooseSection(),
                const _CoreValuesSection(),
                const _LuxuryExperienceSection(),
                const _ProcessSection(),
                const _AchievementsSection(),
                const _TestimonialsSection(),
                const _LookbookGallerySection(),
                const _FAQSection(),
                const NewsletterSection(),
                const FooterSection(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _AboutTopBar(scrollOffset: _scrollOffset),
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
  const _AboutTopBar({required this.scrollOffset});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final scrolled = scrollOffset > 30;
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
            Text(
              "NV's",
              style: TextStyle(
                color: scrolled ? NVColors.charcoal : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              "NV's",
              style: TextStyle(
                color: scrolled ? NVColors.charcoal : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 18 : 22,
                letterSpacing: 0.4,
              ),
            ),
            isMobile
                ? Icon(Icons.menu_rounded, color: scrolled ? NVColors.charcoal : Colors.white)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Collections', 'Brand', 'Account', 'Search']
                        .map((l) => Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: Text(
                                l,
                                style: TextStyle(
                                  color: (scrolled ? NVColors.charcoal : Colors.white)
                                      .withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      );
    });
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

const _missionKeywords = ['CONFIDENCE', 'IDENTITY', 'CULTURE'];

class _HeroMissionSection extends StatefulWidget {
  final double scrollOffset;
  const _HeroMissionSection({required this.scrollOffset});

  @override
  State<_HeroMissionSection> createState() => _HeroMissionSectionState();
}

class _HeroMissionSectionState extends State<_HeroMissionSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..forward();
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat(reverse: true);

  static const _bgUrl =
      'https://images.unsplash.com/photo-1490578474895-699cd4e2cf59?q=80&w=2400&auto=format&fit=crop';

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
      final parallax = (widget.scrollOffset * 0.3).clamp(0.0, 100.0);

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
                    TextSpan(text: "OUR MISSION ISN\u2019T SIMPLY\nTO SELL CLOTHING.\n\n"),
                  ],
                ),
              ),
              const SizedBox(height: 6),
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
                  'Independent luxury fashion house crafting garments at the '
                  'intersection of architecture and attitude \u2014 for those '
                  'who lead rather than follow.',
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
                spacing: 14,
                runSpacing: 14,
                children: [
                  PremiumButton(
                    label: 'Explore Collection',
                    variant: ButtonVariant.solid,
                    small: isMobile,
                    onTap: () {},
                  ),
                  PremiumButton(
                    label: 'Our Story',
                    variant: ButtonVariant.outline,
                    small: isMobile,
                    onTap: () {},
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
                    child: _GlassFeatureCard(data: f),
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
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -parallax),
                child: AnimatedBuilder(
                  animation: _drift,
                  builder: (context, child) {
                    final scale = 1.0 + (_drift.value * 0.03);
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Image.network(
                    _bgUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : Container(color: NVColors.charcoal),
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: NVColors.charcoal),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      NVColors.charcoal.withValues(alpha: 0.78),
                      NVColors.charcoal.withValues(alpha: 0.55),
                      NVColors.charcoal.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Floating decorative rings
            const Positioned(top: 90, left: 60, child: _FloatingRing(size: 46)),
            const Positioned(bottom: 140, right: 90, child: _FloatingRing(size: 30)),
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
                                .map((f) => SizedBox(width: 200, child: _GlassFeatureCard(data: f)))
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
            TextSpan(
              text: keyword,
              style: TextStyle(color: NVColors.gold),
            ),
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

class _FloatingRingState extends State<_FloatingRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat(reverse: true);
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

class _ScrollHintState extends State<_ScrollHint> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))
        ..repeat(reverse: true);
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
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _hover ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _hover
                      ? NVColors.gold.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.22),
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
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11.5,
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
  _PromiseFeature(Icons.public_rounded, 'Worldwide Shipping', 'Delivered to over 120 countries with reliable, trackable logistics.'),
  _PromiseFeature(Icons.workspace_premium_outlined, 'Limited Collections', 'Small-batch drops designed to stay exclusive, never oversaturated.'),
  _PromiseFeature(Icons.eco_outlined, 'Eco-Friendly Materials', 'Responsibly sourced textiles with a lighter footprint on the planet.'),
  _PromiseFeature(Icons.handyman_outlined, 'Handcrafted Excellence', 'Finished by skilled hands, not rushed off an assembly line.'),
  _PromiseFeature(Icons.replay_rounded, 'Easy Returns', 'A no-friction 30-day return window on every single order.'),
  _PromiseFeature(Icons.lock_outline_rounded, 'Secure Payments', 'Encrypted checkout with every major payment method supported.'),
  _PromiseFeature(Icons.support_agent_rounded, '24/7 Customer Support', 'A real human, day or night, whenever you need one.'),
  _PromiseFeature(Icons.eco_rounded, 'Sustainable Packaging', 'Recyclable, plastic-minimised packaging on every shipment.'),
  _PromiseFeature(Icons.favorite_border_rounded, 'Lifetime Customer Care', 'We stand behind what we make, long after you\u2019ve worn it in.'),
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'The NV\u2019S Promise',
                title: 'Why fashion houses like ours exist',
                description:
                    'Ten commitments that shape every decision, from fabric mill to final stitch.',
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
              itemBuilder: (context, i) =>
                  _FadeSlideIn(child: _PromiseCard(data: _promiseFeatures[i])),
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NVColors.beige.withValues(alpha: 0.6),
              ),
              child: Icon(widget.data.icon, color: NVColors.charcoal, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              widget.data.title,
              style: TextStyle(
                color: NVColors.charcoal,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                widget.data.desc,
                style: TextStyle(
                  color: NVColors.charcoal.withValues(alpha: 0.6),
                  fontSize: 11.5,
                  height: 1.5,
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
// WHY CHOOSE NV'S — stats, animated slogan, journey timeline
// =================================================================
const _slogans = [
  'Crafted with precision.',
  'Designed for confidence.',
  'Built to outlast trends.',
  'Independent by choice.',
  'Details define us.',
  'Luxury, redefined.',
];

const _journey = [
  _JourneyStep('2008', 'The Idea', 'Two tailors and one belief: menswear needed an edge.'),
  _JourneyStep('2012', 'First Atelier', 'Our first small studio opens above a Milan fabric market.'),
  _JourneyStep('2016', 'Global Reach', 'NV\u2019S ships internationally for the first time.'),
  _JourneyStep('2020', 'Sustainable Shift', 'A full transition to responsibly-sourced textiles.'),
  _JourneyStep('2023', 'Flagship Launch', 'Our first flagship store opens its doors.'),
  _JourneyStep('2026', 'Today', '120+ countries, one uncompromising standard.'),
];

class _JourneyStep {
  final String year;
  final String title;
  final String desc;
  const _JourneyStep(this.year, this.title, this.desc);
}

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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Why Choose NV\u2019S",
                    style: TextStyle(
                      color: NVColors.charcoal,
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.w700,
                    ),
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
                          style: TextStyle(
                            color: NVColors.charcoal.withValues(alpha: 0.6),
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
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
                    style: TextStyle(
                      color: NVColors.charcoal.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                      style: TextStyle(
                        color: NVColors.charcoal.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: isMobile ? 36 : 56),
            _FadeSlideIn(child: _StatsRow(isMobile: isMobile)),
            SizedBox(height: isMobile ? 48 : 70),
            _FadeSlideIn(child: _JourneyTimeline(isMobile: isMobile)),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: NVColors.charcoal.withValues(alpha: 0.2)),
        ),
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
        _CountUp(end: 18, start: visible, suffix: 'Y', style: _statStyle()),
        _CountUp(end: 250, start: visible, suffix: 'K+', style: _statStyle()),
        _CountUp(end: 480, start: visible, suffix: '+', style: _statStyle()),
        _CountUp(end: 120, start: visible, suffix: '+', style: _statStyle()),
      ];
      const labels = [
        'Years of Excellence',
        'Happy Customers',
        'Premium Products',
        'Countries Served',
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
                  style: TextStyle(
                    color: NVColors.charcoal.withValues(alpha: 0.6),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }

  TextStyle _statStyle() => TextStyle(
        color: NVColors.charcoal,
        fontSize: isMobile ? 30 : 40,
        fontWeight: FontWeight.w700,
      );
}

class _JourneyTimeline extends StatelessWidget {
  final bool isMobile;
  const _JourneyTimeline({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: List.generate(_journey.length, (i) {
          final step = _journey[i];
          final isLast = i == _journey.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.gold),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: NVColors.charcoal.withValues(alpha: 0.15)),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _JourneyText(step: step),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _journey.length,
        separatorBuilder: (context, i) => SizedBox(
          width: 46,
          child: Center(
            child: Container(height: 2, color: NVColors.charcoal.withValues(alpha: 0.15)),
          ),
        ),
        itemBuilder: (context, i) {
          final step = _journey[i];
          return SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: NVColors.gold),
                ),
                const SizedBox(height: 16),
                _JourneyText(step: step),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _JourneyText extends StatelessWidget {
  final _JourneyStep step;
  const _JourneyText({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.year,
          style: TextStyle(color: NVColors.gold, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          step.title,
          style: TextStyle(color: NVColors.charcoal, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          step.desc,
          style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12.5, height: 1.5),
        ),
      ],
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
  _CoreValue(Icons.precision_manufacturing_outlined, 'Craftsmanship', 'Skilled hands and decades of tailoring expertise.'),
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'What We Stand For',
                title: 'Our Core Values',
                center: true,
              ),
            ),
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
          border: Border.all(
            color: _hover ? NVColors.gold.withValues(alpha: 0.4) : Colors.transparent,
          ),
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
                  Text(
                    widget.data.title,
                    style: TextStyle(color: NVColors.charcoal, fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.data.desc,
                    style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 12, height: 1.5),
                  ),
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
// LUXURY EXPERIENCE — image overlay cards
// =================================================================
class _LuxuryExperienceSection extends StatelessWidget {
  const _LuxuryExperienceSection();

  static const _items = [
    ('Premium Fabrics', 'Sourced from mills we\u2019ve trusted for a decade.',
        'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=1200&auto=format&fit=crop'),
    ('Exclusive Collections', 'Limited runs designed never to be reproduced.',
        'https://images.unsplash.com/photo-1490114538077-0a7f8cb49891?q=80&w=1200&auto=format&fit=crop'),
    ('Attention to Detail', 'Every stitch considered, nothing left to chance.',
        'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=1200&auto=format&fit=crop'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);

      return Container(
        color: NVColors.beige.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'The Luxury Experience',
                title: 'Where fabric meets philosophy',
                center: true,
              ),
            ),
            const SizedBox(height: 36),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: _items
                  .map((item) => SizedBox(
                        width: isMobile ? double.infinity : 340,
                        child: _FadeSlideIn(
                          child: _ExperienceCard(title: item.$1, desc: item.$2, image: item.$3),
                        ),
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
  final String image;
  const _ExperienceCard({required this.title, required this.desc, required this.image});

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
      child: AspectRatio(
        aspectRatio: 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _hover ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 380),
                child: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : Container(color: NVColors.beige),
                  errorBuilder: (context, error, stackTrace) => Container(color: NVColors.beige),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: _hover ? 0.8 : 0.6)],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      opacity: _hover ? 1 : 0.8,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.desc,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.5),
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(eyebrow: 'How It\u2019s Made', title: 'Our Process', center: true),
            ),
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
                                child: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: NVColors.charcoal.withValues(alpha: 0.3)),
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
                              child: Icon(Icons.arrow_forward_rounded,
                                  color: NVColors.charcoal.withValues(alpha: 0.25)),
                            ),
                          );
                        }
                        final stepIndex = i ~/ 2;
                        return Expanded(
                          flex: 3,
                          child: _ProcessNode(index: stepIndex, data: _processSteps[stepIndex]),
                        );
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NVColors.charcoal,
          ),
          child: Icon(data.icon, color: NVColors.gold, size: 26),
        ),
        const SizedBox(height: 12),
        Text(
          '0${index + 1}',
          style: TextStyle(color: NVColors.gold, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: TextStyle(color: NVColors.charcoal, fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 140,
          child: Text(
            data.desc,
            textAlign: TextAlign.center,
            style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 11.5, height: 1.5),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// ACHIEVEMENTS & MILESTONES
// =================================================================
const _achievements = [
  ('2015', 'Best Emerging Menswear Label', Icons.emoji_events_outlined),
  ('2018', '1 Million Garments Shipped', Icons.local_shipping_outlined),
  ('2021', 'Sustainability Excellence Award', Icons.eco_outlined),
  ('2023', 'Flagship Store of the Year', Icons.storefront_outlined),
  ('2025', 'Global Design Honour', Icons.workspace_premium_outlined),
];

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      return Container(
        color: NVColors.charcoal,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: Column(
                children: [
                  Text(
                    'MILESTONES',
                    style: TextStyle(color: NVColors.gold, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Achievements Along the Way',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _FadeSlideIn(
              child: SizedBox(
                height: isMobile ? null : 160,
                child: isMobile
                    ? Column(
                        children: _achievements
                            .map((a) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _AchievementTile(data: a),
                                ))
                            .toList(),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _achievements.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 28),
                        itemBuilder: (context, i) =>
                            SizedBox(width: 220, child: _AchievementTile(data: _achievements[i])),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AchievementTile extends StatelessWidget {
  final (String, String, IconData) data;
  const _AchievementTile({required this.data});

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
          Text(
            data.$2,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// TESTIMONIALS CAROUSEL
// =================================================================
class _Testimonial {
  final String name;
  final String role;
  final String quote;
  final int rating;
  const _Testimonial(this.name, this.role, this.quote, this.rating);
}

const _testimonials = [
  _Testimonial('James Whitfield', 'Verified Buyer', 'The stitching, the drape, the finish — nothing about NV\u2019S feels mass-produced.', 5),
  _Testimonial('Aiden Cole', 'Verified Buyer', 'I\u2019ve rebuilt half my wardrobe around this brand. Consistently excellent.', 5),
  _Testimonial('Marcus Lee', 'Verified Buyer', 'Shipping was fast even internationally, and the packaging alone felt premium.', 4),
  _Testimonial('Ravi Patel', 'Verified Buyer', 'Customer support resolved a sizing issue in minutes. Rare these days.', 5),
];

class _TestimonialsSection extends StatefulWidget {
  const _TestimonialsSection();

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  final PageController _controller = PageController(viewportFraction: 0.86);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _index = (_index + 1) % _testimonials.length;
      _controller.animateToPage(_index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      return Container(
        color: NVColors.ivory,
        padding: EdgeInsets.symmetric(vertical: isMobile ? 56 : 90),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
              child: _FadeSlideIn(
                child: _SectionHeader(
                  eyebrow: 'Customer Love',
                  title: 'What They\u2019re Saying',
                  center: true,
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _controller,
                itemCount: _testimonials.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _TestimonialCard(data: _testimonials[i]),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_testimonials.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? NVColors.gold : NVColors.charcoal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

class _TestimonialCard extends StatelessWidget {
  final _Testimonial data;
  const _TestimonialCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NVColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: NVColors.charcoal.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < data.rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: NVColors.gold,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              '\u201C${data.quote}\u201D',
              style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.75), fontSize: 13.5, height: 1.6),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: NVColors.beige,
                child: Text(
                  data.name.substring(0, 1),
                  style: TextStyle(color: NVColors.charcoal, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name, style: TextStyle(color: NVColors.charcoal, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(data.role, style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.5), fontSize: 11.5)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================================
// LOOKBOOK / INSTAGRAM MASONRY GALLERY
// =================================================================
const _galleryImages = [
  'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1509631179647-0177331693ae?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1520975954732-35dd22299614?q=80&w=800&auto=format&fit=crop',
];

class _LookbookGallerySection extends StatelessWidget {
  const _LookbookGallerySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      final isTablet = NVBreak.isTablet(constraints.maxWidth);
      final columns = isMobile ? 2 : (isTablet ? 3 : 4);

      final heights = List.generate(
        _galleryImages.length,
        (i) => 160.0 + (i % 3) * 60,
      );

      final colBuckets = List.generate(columns, (_) => <int>[]);
      for (var i = 0; i < _galleryImages.length; i++) {
        colBuckets[i % columns].add(i);
      }

      return Container(
        color: NVColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(eyebrow: 'Follow The Story', title: 'The Lookbook', center: true),
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
                                    child: _GalleryTile(
                                      url: _galleryImages[i],
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

class _GalleryTile extends StatefulWidget {
  final String url;
  final double height;
  const _GalleryTile({required this.url, required this.height});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScale(
                scale: _hover ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 350),
                child: Image.network(
                  widget.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : Container(color: NVColors.beige),
                  errorBuilder: (context, error, stackTrace) => Container(color: NVColors.beige),
                ),
              ),
              AnimatedOpacity(
                opacity: _hover ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
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
// FAQ ACCORDION
// =================================================================
const _faqs = [
  ('What makes NV\u2019S different from fast fashion?',
      'We produce in small, limited batches using higher-grade fabrics, and every piece is finished by hand rather than rushed through mass production.'),
  ('How long does shipping take?',
      'Domestic orders typically arrive in 3\u20135 business days; international orders in 7\u201314 business days depending on destination.'),
  ('What is your return policy?',
      'We offer a 30-day no-questions-asked return window on unworn items with original tags attached.'),
  ('Are your materials sustainably sourced?',
      'Yes \u2014 the majority of our textiles come from certified responsible mills, and we continue expanding that percentage every season.'),
  ('Do you ship internationally?',
      'We currently ship to over 120 countries worldwide with tracked, insured delivery.'),
];

class _FAQSection extends StatelessWidget {
  const _FAQSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = NVBreak.isMobile(constraints.maxWidth);
      return Container(
        color: NVColors.beige.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 56 : 90,
        ),
        child: Column(
          children: [
            _FadeSlideIn(
              child: _SectionHeader(
                eyebrow: 'Good To Know',
                title: 'Frequently Asked Questions',
                center: true,
              ),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: _faqs
                    .map((f) => _FadeSlideIn(child: _FAQItem(question: f.$1, answer: f.$2)))
                    .toList(),
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
        border: Border.all(
          color: _open ? NVColors.gold.withValues(alpha: 0.5) : NVColors.charcoal.withValues(alpha: 0.08),
        ),
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
                    child: Text(
                      widget.question,
                      style: TextStyle(color: NVColors.charcoal, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
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
                child: Text(
                  widget.answer,
                  style: TextStyle(color: NVColors.charcoal.withValues(alpha: 0.6), fontSize: 13, height: 1.6),
                ),
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