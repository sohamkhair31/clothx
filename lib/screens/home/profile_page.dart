import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// =================================================================
/// NV'S — ACCOUNT / PROFILE PAGE   (single-file, zero third-party deps)
/// =================================================================
/// Pure Flutter SDK only. UI-only file: every data model, list, and
/// callback below is placeholder/demo content clearly marked with
/// `// TODO:` — wire these to your existing controllers, providers,
/// models, Firebase calls, and navigation/routing. Nothing about your
/// business logic, auth flow, or app structure is assumed or altered.
///
/// Visual language matches the Collections page: matte charcoal/black
/// gradient background, glassmorphism cards, 20-24px rounded corners,
/// champagne-gold accents, ivory/beige/soft-gray text, staggered
/// fade-in entrances, and hover micro-interactions on desktop.
/// =================================================================

/// ---------------------------------------------------------------
/// PALETTE — identical to the rest of the NV'S app
/// ---------------------------------------------------------------
class NVColors {
  static const charcoal = Color(0xFF0D0D0D);
  static const charcoalLight = Color(0xFF1A1A1A);
  static const ivory = Color(0xFFF8F6F2);
  static const beige = Color(0xFFE9E1D3);
  static const softGray = Color(0xFFB9B4AC);
  static const gold = Color(0xFFC9A96E);
  static const white = Color(0xFFFFFFFF);
  static const success = Color(0xFF7FB77E);
  static const warning = Color(0xFFD9A441);
  static const danger = Color(0xFFC96A5A);
  static const info = Color(0xFF7FA7C9);
}

/// ---------------------------------------------------------------
/// BREAKPOINTS
/// ---------------------------------------------------------------
class NVBreakpoints {
  static const smallMobile = 400.0;
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const desktop = 1440.0;

  static bool isSmallMobile(double w) => w < smallMobile;
  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

/// =================================================================
/// PLACEHOLDER DATA MODELS
/// Replace every list/const below with your real models & providers.
/// =================================================================

enum MembershipTier { silver, gold, platinum, elite }

extension MembershipTierX on MembershipTier {
  String get label => switch (this) {
        MembershipTier.silver => 'SILVER',
        MembershipTier.gold => 'GOLD',
        MembershipTier.platinum => 'PLATINUM',
        MembershipTier.elite => 'ELITE',
      };

  Color get color => switch (this) {
        MembershipTier.silver => const Color(0xFFC7CBD1),
        MembershipTier.gold => NVColors.gold,
        MembershipTier.platinum => const Color(0xFFE5E4E2),
        MembershipTier.elite => const Color(0xFFEAC98A),
      };
}

enum OrderStatus { delivered, shipped, processing, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.shipped => 'SHIPPED',
        OrderStatus.processing => 'PROCESSING',
        OrderStatus.cancelled => 'CANCELLED',
      };

  Color get color => switch (this) {
        OrderStatus.delivered => NVColors.success,
        OrderStatus.shipped => NVColors.info,
        OrderStatus.processing => NVColors.warning,
        OrderStatus.cancelled => NVColors.danger,
      };

  IconData get icon => switch (this) {
        OrderStatus.delivered => Icons.check_circle_rounded,
        OrderStatus.shipped => Icons.local_shipping_rounded,
        OrderStatus.processing => Icons.hourglass_top_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
      };
}

class NVOrder {
  final String id;
  final String title;
  final String imageUrl;
  final int itemCount;
  final double total;
  final OrderStatus status;
  final String date;
  final String etaOrDelivered;

  const NVOrder({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.date,
    required this.etaOrDelivered,
  });
}

class NVProduct {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final bool inStock;
  final bool isWishlisted;

  const NVProduct({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    this.inStock = true,
    this.isWishlisted = true,
  });
}

class NVAddress {
  final String label;
  final String fullAddress;
  final bool isDefault;
  const NVAddress(this.label, this.fullAddress, {this.isDefault = false});
}

class NVPaymentMethod {
  final String brand;
  final String last4;
  final bool isDefault;
  const NVPaymentMethod(this.brand, this.last4, {this.isDefault = false});
}

class NVNotification {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;
  const NVNotification({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

class NVCoupon {
  final String code;
  final String description;
  final String expiry;
  const NVCoupon(this.code, this.description, this.expiry);
}

class NVFaq {
  final String question;
  final String answer;
  const NVFaq(this.question, this.answer);
}

class NVTestimonial {
  final String name;
  final String quote;
  final double rating;
  const NVTestimonial(this.name, this.quote, this.rating);
}

/// ---------------- Demo data (swap for real providers) ----------------

const _demoOrders = [
  NVOrder(
    id: '#NV20481',
    title: 'Oversized Essential Tee + 2 more',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=800&auto=format&fit=crop',
    itemCount: 3,
    total: 189.00,
    status: OrderStatus.delivered,
    date: 'Jun 12, 2026',
    etaOrDelivered: 'Delivered Jun 15',
  ),
  NVOrder(
    id: '#NV20477',
    title: 'Signature Wool Overcoat',
    imageUrl:
        'https://images.unsplash.com/photo-1520975954732-35dd22299614?q=80&w=800&auto=format&fit=crop',
    itemCount: 1,
    total: 420.00,
    status: OrderStatus.shipped,
    date: 'Jun 28, 2026',
    etaOrDelivered: 'Arriving Jul 08',
  ),
  NVOrder(
    id: '#NV20465',
    title: 'Limited Edition Box Set',
    imageUrl:
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=800&auto=format&fit=crop',
    itemCount: 1,
    total: 610.00,
    status: OrderStatus.processing,
    date: 'Jul 02, 2026',
    etaOrDelivered: 'Est. delivery Jul 10',
  ),
  NVOrder(
    id: '#NV20411',
    title: 'Classic Polo — Black',
    imageUrl:
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?q=80&w=800&auto=format&fit=crop',
    itemCount: 2,
    total: 96.00,
    status: OrderStatus.cancelled,
    date: 'May 20, 2026',
    etaOrDelivered: 'Refunded in full',
  ),
];

const _demoWishlist = [
  NVProduct(
    id: 'w1',
    title: 'Beige Heavyweight Hoodie',
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=800&auto=format&fit=crop',
    price: 145,
  ),
  NVProduct(
    id: 'w2',
    title: 'Ivory Oversized Tee',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=800&auto=format&fit=crop',
    price: 79,
    oldPrice: 95,
  ),
  NVProduct(
    id: 'w3',
    title: 'Charcoal Polo Shirt',
    imageUrl:
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?q=80&w=800&auto=format&fit=crop',
    price: 98,
    inStock: false,
  ),
  NVProduct(
    id: 'w4',
    title: 'Kids Premium Set',
    imageUrl:
        'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?q=80&w=800&auto=format&fit=crop',
    price: 65,
  ),
];

const _demoRecommended = [
  NVProduct(
    id: 'r1',
    title: 'New Arrival — Street Tee',
    imageUrl:
        'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=800&auto=format&fit=crop',
    price: 88,
  ),
  NVProduct(
    id: 'r2',
    title: 'Signature Wool Overcoat',
    imageUrl:
        'https://images.unsplash.com/photo-1520975954732-35dd22299614?q=80&w=800&auto=format&fit=crop',
    price: 420,
  ),
  NVProduct(
    id: 'r3',
    title: 'Limited Edition Box',
    imageUrl:
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?q=80&w=800&auto=format&fit=crop',
    price: 610,
  ),
  NVProduct(
    id: 'r4',
    title: 'Beige Heavyweight Hoodie',
    imageUrl:
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?q=80&w=800&auto=format&fit=crop',
    price: 145,
  ),
];

const _demoAddresses = [
  NVAddress('Home', '24 Marine Drive, Mumbai, MH 400002', isDefault: true),
  NVAddress('Office', 'WeWork BKC, G Block, Mumbai, MH 400051'),
];

const _demoPayments = [
  NVPaymentMethod('Visa', '4821', isDefault: true),
  NVPaymentMethod('Mastercard', '1190'),
];

const _demoNotifications = [
  NVNotification(
    icon: Icons.local_shipping_rounded,
    title: 'Your order has shipped',
    subtitle: 'Order #NV20477 is on its way',
    time: '2h ago',
    unread: true,
  ),
  NVNotification(
    icon: Icons.local_offer_rounded,
    title: 'Members-only preview',
    subtitle: 'Autumn/Winter drop unlocks early for Gold+',
    time: '1d ago',
    unread: true,
  ),
  NVNotification(
    icon: Icons.inventory_2_rounded,
    title: 'Back in stock',
    subtitle: 'Charcoal Polo Shirt, size M',
    time: '3d ago',
  ),
  NVNotification(
    icon: Icons.shield_rounded,
    title: 'New sign-in detected',
    subtitle: 'Chrome on Windows — Mumbai, IN',
    time: '6d ago',
  ),
];

const _demoCoupons = [
  NVCoupon('NVGOLD10', '10% off your next order', 'Expires Jul 31'),
  NVCoupon('WELCOME25', '₹25 off orders over ₹150', 'Expires Aug 15'),
];

const _demoFaqs = [
  NVFaq('How do I track my order?',
      'Go to Order History and tap Track on any active order to see live status.'),
  NVFaq('What is your return policy?',
      'Unworn items can be returned within 30 days for a full refund.'),
  NVFaq('How do reward points work?',
      'Earn 1 point per ₹1 spent. Redeem points for discounts at checkout.'),
];

const _demoTestimonials = [
  NVTestimonial('Amelia R.', 'The quality feels like it belongs on a runway, not a rack.', 5),
  NVTestimonial('Devansh K.', 'Fastest luxury checkout experience I have used.', 4.5),
  NVTestimonial('Sara L.', 'Customer support resolved my return in minutes.', 5),
];

/// =================================================================
/// SHARED UI PRIMITIVES
/// =================================================================

/// Frosted glass panel used throughout the page.
class NVGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool highlight;

  const NVGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(highlight ? 0.07 : 0.045),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: highlight
                  ? NVColors.gold.withOpacity(0.35)
                  : Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small gold label used as a section eyebrow.
class NVEyebrow extends StatelessWidget {
  final String text;
  const NVEyebrow(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: NVColors.gold,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.6,
      ),
    );
  }
}

/// Section header: eyebrow + title (+ optional trailing action).
class NVSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isMobile;

  const NVSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVEyebrow(eyebrow),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: NVColors.ivory,
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: const TextStyle(
              color: NVColors.softGray,
              fontSize: 13.5,
            ),
          ),
        ],
      ],
    );

    if (trailing == null) return header;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: header),
        trailing!,
      ],
    );
  }
}

/// Animated up-counting number — no external animation package.
class NVAnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimals;

  const NVAnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        final text = decimals == 0
            ? v.round().toString()
            : v.toStringAsFixed(decimals);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

/// Staggered fade + slide entrance wrapper.
class NVStaggerIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const NVStaggerIn({super.key, required this.child, required this.delay});

  @override
  State<NVStaggerIn> createState() => _NVStaggerInState();
}

class _NVStaggerInState extends State<NVStaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
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

/// Shimmer skeleton box for loading states.
class NVShimmer extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  const NVShimmer(
      {super.key, this.height = 16, this.width = double.infinity, this.radius = 8});

  @override
  State<NVShimmer> createState() => _NVShimmerState();
}

class _NVShimmerState extends State<NVShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 3, 0),
              end: Alignment(1 + _c.value * 3, 0),
              colors: [
                Colors.white.withOpacity(0.04),
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.04),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Order status pill.
class NVStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const NVStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: status.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 12, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic pill button (used for Edit/Share/Settings/Track/Reorder…).
class NVPillButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool solid;
  final bool small;

  const NVPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.solid = false,
    this.small = false,
  });

  @override
  State<NVPillButton> createState() => _NVPillButtonState();
}

class _NVPillButtonState extends State<NVPillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.solid
        ? NVColors.gold.withOpacity(_hover ? 0.92 : 1)
        : Colors.white.withOpacity(_hover ? 0.12 : 0.06);
    final fg = widget.solid ? NVColors.charcoal : NVColors.ivory;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(100),
          splashColor: NVColors.gold.withOpacity(0.25),
          child: AnimatedScale(
            scale: _hover ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                horizontal: widget.small ? 14 : 18,
                vertical: widget.small ? 9 : 12,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(100),
                border: widget.solid
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.14)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: widget.small ? 14 : 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: fg,
                      fontSize: widget.small ? 12.5 : 13.5,
                      fontWeight: FontWeight.w600,
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

/// =================================================================
/// ACCOUNT PAGE — ROOT WIDGET
/// =================================================================
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // TODO: replace with your auth/user provider state.
  final String _customerName = 'Aanya Kapoor';
  final MembershipTier _tier = MembershipTier.gold;
  final int _loyaltyPoints = 2840;
  final double _profileCompletion = 0.78;
  final int _cartCount = 3;
  final int _wishlistCount = _demoWishlist.length;

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
    final isTablet = NVBreakpoints.isTablet(width);
    final horizontalPadding = isMobile ? 18.0 : (isTablet ? 32.0 : 56.0);

    return Scaffold(
      backgroundColor: NVColors.charcoal,
      body: Stack(
        children: [
          const _AnimatedBackdrop(),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: isMobile ? 84 : 104, bottom: 60),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NVStaggerIn(
                      delay: Duration.zero,
                      child: _ProfileHeroHeader(
                        name: _customerName,
                        tier: _tier,
                        loyaltyPoints: _loyaltyPoints,
                        completion: _profileCompletion,
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(height: isMobile ? 28 : 40),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 80),
                      child: _QuickAccessRow(
                        cartCount: _cartCount,
                        wishlistCount: _wishlistCount,
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(height: isMobile ? 28 : 40),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 140),
                      child: _StatsGrid(
                        isMobile: isMobile,
                        isTablet: isTablet,
                        cartCount: _cartCount,
                        wishlistCount: _wishlistCount,
                      ),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 180),
                      child: _AccountSectionsGrid(
                          isMobile: isMobile, isTablet: isTablet),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 220),
                      child: _OrderHistorySection(isMobile: isMobile),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 260),
                      child: _WishlistSection(
                          isMobile: isMobile, isTablet: isTablet),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 300),
                      child: _LoyaltyDashboard(
                        tier: _tier,
                        points: _loyaltyPoints,
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 340),
                      child: _NotificationCenter(isMobile: isMobile),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 380),
                      child: _RecommendedSection(
                          isMobile: isMobile, isTablet: isTablet),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 420),
                      child: _TestimonialsSection(isMobile: isMobile),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 460),
                      child: _FaqSection(isMobile: isMobile),
                    ),
                    SizedBox(height: isMobile ? 40 : 56),
                    NVStaggerIn(
                      delay: const Duration(milliseconds: 500),
                      child: _SupportSection(isMobile: isMobile),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _AccountGlassNav(
                isMobile: isMobile,
                scrolled: _scrollOffset > 12,
                cartCount: _cartCount,
                wishlistCount: _wishlistCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle animated floating gradient blobs behind everything.
class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop();

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value * 2 * math.pi;
          return Stack(
            children: [
              Positioned(
                top: 80 + math.sin(t) * 20,
                left: -80 + math.cos(t) * 20,
                child: _blob(NVColors.gold.withOpacity(0.10), 260),
              ),
              Positioned(
                bottom: 40 + math.cos(t) * 24,
                right: -100 + math.sin(t) * 24,
                child: _blob(NVColors.beige.withOpacity(0.06), 320),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

/// =================================================================
/// TOP GLASS NAV — adds Cart + Wishlist icons with live badge counts
/// =================================================================
class _AccountGlassNav extends StatelessWidget {
  final bool isMobile;
  final bool scrolled;
  final int cartCount;
  final int wishlistCount;

  const _AccountGlassNav({
    required this.isMobile,
    required this.scrolled,
    required this.cartCount,
    required this.wishlistCount,
  });

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
              horizontal: isMobile ? 14 : 26,
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
                Row(
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
                      child: const Text('N',
                          style: TextStyle(
                              color: NVColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ),
                    const SizedBox(width: 9),
                    const Text("NV's",
                        style: TextStyle(
                            color: NVColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.4)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BadgedIconButton(
                      icon: Icons.favorite_border_rounded,
                      count: wishlistCount,
                      // TODO: navigate to existing Wishlist route/provider.
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _BadgedIconButton(
                      icon: Icons.shopping_bag_outlined,
                      count: cartCount,
                      // TODO: navigate to existing Cart route/provider.
                      onTap: () {},
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 8),
                      _BadgedIconButton(
                        icon: Icons.search_rounded,
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgedIconButton extends StatefulWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onTap;
  const _BadgedIconButton({required this.icon, required this.onTap, this.count});

  @override
  State<_BadgedIconButton> createState() => _BadgedIconButtonState();
}

class _BadgedIconButtonState extends State<_BadgedIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const CircleBorder(),
          splashColor: NVColors.gold.withOpacity(0.25),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(_hover ? 0.14 : 0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: Icon(widget.icon, color: NVColors.white, size: 18),
              ),
              if (widget.count != null && widget.count! > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: NVColors.gold,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: NVColors.charcoal, width: 1.4),
                    ),
                    constraints: const BoxConstraints(minWidth: 17),
                    child: Text(
                      '${widget.count}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: NVColors.charcoal,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// PROFILE HERO HEADER
/// =================================================================
class _ProfileHeroHeader extends StatelessWidget {
  final String name;
  final MembershipTier tier;
  final int loyaltyPoints;
  final double completion;
  final bool isMobile;

  const _ProfileHeroHeader({
    required this.name,
    required this.tier,
    required this.loyaltyPoints,
    required this.completion,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = _EditableAvatar(size: isMobile ? 92 : 116);

    final identity = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                color: NVColors.ivory,
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 10),
            _MembershipBadge(tier: tier),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, size: 16, color: NVColors.gold),
            const SizedBox(width: 6),
            NVAnimatedCounter(
              value: loyaltyPoints,
              suffix: ' loyalty points',
              style: const TextStyle(
                color: NVColors.softGray,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: isMobile ? 220 : 260,
          child: _ProfileCompletionBar(completion: completion),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        NVPillButton(
          label: 'Edit Profile',
          icon: Icons.edit_rounded,
          solid: true,
          small: isMobile,
          // TODO: hook to existing edit-profile flow/controller.
          onTap: () {},
        ),
        NVPillButton(
          label: 'Share Profile',
          icon: Icons.ios_share_rounded,
          small: isMobile,
          onTap: () {},
        ),
        NVPillButton(
          label: 'Settings',
          icon: Icons.settings_outlined,
          small: isMobile,
          onTap: () {},
        ),
      ],
    );

    return NVGlassCard(
      radius: 24,
      highlight: true,
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      child: isMobile
          ? Column(
              children: [
                avatar,
                const SizedBox(height: 18),
                identity,
                const SizedBox(height: 20),
                actions,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(width: 28),
                Expanded(child: identity),
                actions,
              ],
            ),
    );
  }
}

class _EditableAvatar extends StatefulWidget {
  final double size;
  const _EditableAvatar({required this.size});

  @override
  State<_EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<_EditableAvatar> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // TODO: hook to existing avatar-upload logic.
        onTap: () {},
        child: Container(
          width: widget.size,
          height: widget.size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [NVColors.gold, NVColors.beige],
            ),
            boxShadow: [
              BoxShadow(
                color: NVColors.gold.withOpacity(_hover ? 0.45 : 0.25),
                blurRadius: _hover ? 26 : 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=400&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: NVColors.charcoalLight,
                    child: const Icon(Icons.person_rounded,
                        color: NVColors.softGray, size: 40),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hover ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                    alignment: Alignment.center,
                    child: const Icon(Icons.camera_alt_rounded,
                        color: NVColors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MembershipBadge extends StatelessWidget {
  final MembershipTier tier;
  const _MembershipBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          colors: [tier.color.withOpacity(0.9), tier.color.withOpacity(0.5)],
        ),
        boxShadow: [
          BoxShadow(color: tier.color.withOpacity(0.4), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded,
              size: 12, color: NVColors.charcoal),
          const SizedBox(width: 4),
          Text(
            tier.label,
            style: const TextStyle(
              color: NVColors.charcoal,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCompletionBar extends StatelessWidget {
  final double completion;
  const _ProfileCompletionBar({required this.completion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile completion',
                style: TextStyle(color: NVColors.softGray, fontSize: 11.5)),
            Text('${(completion * 100).round()}%',
                style: const TextStyle(
                    color: NVColors.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 6,
            color: Colors.white.withOpacity(0.08),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: completion),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [NVColors.gold, NVColors.beige],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// =================================================================
/// QUICK ACCESS ROW — prominent Cart & Wishlist entry points
/// =================================================================
class _QuickAccessRow extends StatelessWidget {
  final int cartCount;
  final int wishlistCount;
  final bool isMobile;

  const _QuickAccessRow({
    required this.cartCount,
    required this.wishlistCount,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _QuickAccessTile(
        icon: Icons.shopping_bag_rounded,
        title: 'My Cart',
        subtitle: '$cartCount item${cartCount == 1 ? '' : 's'} ready to checkout',
        color: NVColors.gold,
        // TODO: navigate to existing Cart page/provider.
        onTap: () {},
      ),
      _QuickAccessTile(
        icon: Icons.favorite_rounded,
        title: 'My Wishlist',
        subtitle: '$wishlistCount saved piece${wishlistCount == 1 ? '' : 's'}',
        color: NVColors.beige,
        // TODO: navigate to existing Wishlist page/provider.
        onTap: () {},
      ),
    ];

    return isMobile
        ? Column(
            children: [
              tiles[0],
              const SizedBox(height: 14),
              tiles[1],
            ],
          )
        : Row(
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 20),
              Expanded(child: tiles[1]),
            ],
          );
  }
}

class _QuickAccessTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickAccessTile> createState() => _QuickAccessTileState();
}

class _QuickAccessTileState extends State<_QuickAccessTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: NVGlassCard(
            radius: 20,
            highlight: _hover,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withOpacity(0.16),
                    border: Border.all(color: widget.color.withOpacity(0.4)),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              color: NVColors.ivory,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(widget.subtitle,
                          style: const TextStyle(
                              color: NVColors.softGray, fontSize: 12.5)),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _hover ? 0.02 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// STATS GRID — Orders, Wishlist, Saved Items, Points, Coupons, Reviews
/// =================================================================
class _StatsGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final int cartCount;
  final int wishlistCount;

  const _StatsGrid({
    required this.isMobile,
    required this.isTablet,
    required this.cartCount,
    required this.wishlistCount,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(Icons.receipt_long_rounded, 'Orders', 24, NVColors.info),
      _StatData(Icons.favorite_rounded, 'Wishlist', wishlistCount, NVColors.beige),
      _StatData(Icons.bookmark_rounded, 'Saved Items', 12, NVColors.gold),
      _StatData(Icons.stars_rounded, 'Reward Points', 2840, NVColors.warning),
      _StatData(Icons.local_offer_rounded, 'Coupons', _demoCoupons.length, NVColors.success),
      _StatData(Icons.reviews_rounded, 'Reviews', 9, NVColors.danger),
    ];

    final columns = isMobile ? 2 : (isTablet ? 3 : 6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: isMobile ? 1.05 : 1.15,
      ),
      itemBuilder: (context, i) => _StatCard(data: stats[i]),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.color);
}

class _StatCard extends StatefulWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hover ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: NVGlassCard(
          radius: 18,
          highlight: _hover,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(widget.data.icon, color: widget.data.color, size: 22),
              const SizedBox(height: 10),
              NVAnimatedCounter(
                value: widget.data.value,
                style: const TextStyle(
                  color: NVColors.ivory,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.data.label,
                style: const TextStyle(color: NVColors.softGray, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// ACCOUNT SECTIONS GRID
/// Personal Info, Addresses, Payment Methods, Order History, Wishlist,
/// Recently Viewed, Saved Collections, Rewards, Notifications,
/// Security, Preferences, Support.
/// =================================================================
class _AccountSectionsGrid extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  const _AccountSectionsGrid({required this.isMobile, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final items = <_SectionTileData>[
      _SectionTileData(Icons.person_outline_rounded, 'Personal Information',
          'Name, email, phone & DOB'),
      _SectionTileData(Icons.location_on_outlined, 'Shipping Addresses',
          '${_demoAddresses.length} saved addresses'),
      _SectionTileData(Icons.credit_card_outlined, 'Payment Methods',
          '${_demoPayments.length} cards on file'),
      _SectionTileData(Icons.receipt_long_outlined, 'Order History',
          '${_demoOrders.length} orders placed'),
      _SectionTileData(Icons.favorite_border_rounded, 'Wishlist',
          '${_demoWishlist.length} items saved'),
      _SectionTileData(Icons.visibility_outlined, 'Recently Viewed',
          'Continue where you left off'),
      _SectionTileData(Icons.collections_bookmark_outlined, 'Saved Collections',
          'Your curated edits'),
      _SectionTileData(Icons.workspace_premium_outlined, 'Rewards & Membership',
          'Gold tier — 2,840 pts'),
      _SectionTileData(Icons.notifications_none_rounded, 'Notifications',
          '${_demoNotifications.where((n) => n.unread).length} unread'),
      _SectionTileData(Icons.shield_outlined, 'Security & Privacy',
          'Password, 2FA & sessions'),
      _SectionTileData(Icons.tune_rounded, 'Preferences',
          'Language, currency & theme'),
      _SectionTileData(Icons.support_agent_rounded, 'Support',
          'Chat, FAQs & contact'),
    ];

    final columns = isMobile ? 1 : (isTablet ? 2 : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Manage',
          title: 'Account Settings',
          subtitle: 'Everything about your NV\u2019S account, in one place.',
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 20 : 28),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: isMobile ? 3.4 : (isTablet ? 2.6 : 2.9),
          ),
          itemBuilder: (context, i) => _SectionTile(data: items[i]),
        ),
      ],
    );
  }
}

class _SectionTileData {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionTileData(this.icon, this.title, this.subtitle);
}

class _SectionTile extends StatefulWidget {
  final _SectionTileData data;
  const _SectionTile({required this.data});

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // TODO: navigate to the corresponding existing sub-page/route.
        onTap: () {},
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: NVGlassCard(
            radius: 18,
            highlight: _hover,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NVColors.gold.withOpacity(_hover ? 0.22 : 0.12),
                  ),
                  child: Icon(widget.data.icon,
                      color: NVColors.gold, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: NVColors.ivory,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(widget.data.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: NVColors.softGray, fontSize: 11.5)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.35), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// ORDER HISTORY — timeline with status, tracking, reorder, invoice
/// =================================================================
class _OrderHistorySection extends StatelessWidget {
  final bool isMobile;
  const _OrderHistorySection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Timeline',
          title: 'Order History',
          subtitle: 'Track, reorder, or download invoices in one tap.',
          isMobile: isMobile,
          trailing: NVPillButton(
            label: 'View All',
            icon: Icons.arrow_outward_rounded,
            small: true,
            onTap: () {},
          ),
        ),
        SizedBox(height: isMobile ? 20 : 28),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _demoOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) => _OrderCard(order: _demoOrders[i], isMobile: isMobile),
        ),
      ],
    );
  }
}

class _OrderCard extends StatefulWidget {
  final NVOrder order;
  final bool isMobile;
  const _OrderCard({required this.order, required this.isMobile});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: NVGlassCard(
        radius: 20,
        highlight: _hover,
        padding: EdgeInsets.all(widget.isMobile ? 14 : 18),
        child: Column(
          children: [
            widget.isMobile ? _mobileHeader(o) : _desktopHeader(o),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: _expanded ? _expandedDetails(o) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(NVOrder o) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        o.imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: NVColors.charcoalLight,
          child: const Icon(Icons.image_outlined, color: NVColors.softGray),
        ),
      ),
    );
  }

  Widget _desktopHeader(NVOrder o) {
    return Row(
      children: [
        _thumb(o),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.title,
                  style: const TextStyle(
                      color: NVColors.ivory,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${o.id}  \u00b7  ${o.date}',
                  style: const TextStyle(color: NVColors.softGray, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NVStatusBadge(status: o.status),
              const SizedBox(height: 6),
              Text(o.etaOrDelivered,
                  style: const TextStyle(color: NVColors.softGray, fontSize: 11.5)),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text('\$${o.total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: NVColors.gold,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        _orderActions(o),
      ],
    );
  }

  Widget _mobileHeader(NVOrder o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _thumb(o),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: NVColors.ivory,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${o.id}  \u00b7  ${o.date}',
                      style: const TextStyle(color: NVColors.softGray, fontSize: 11.5)),
                  const SizedBox(height: 6),
                  NVStatusBadge(status: o.status),
                ],
              ),
            ),
            Text('\$${o.total.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: NVColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        _orderActions(o),
      ],
    );
  }

  Widget _orderActions(NVOrder o) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NVPillButton(
          label: 'Track',
          icon: Icons.map_outlined,
          small: true,
          onTap: () {},
        ),
        NVPillButton(
          label: 'Reorder',
          icon: Icons.replay_rounded,
          small: true,
          onTap: () {},
        ),
        NVPillButton(
          label: 'Invoice',
          icon: Icons.download_rounded,
          small: true,
          onTap: () {},
        ),
        _IconOnlyToggle(
          expanded: _expanded,
          onTap: () => setState(() => _expanded = !_expanded),
        ),
      ],
    );
  }

  Widget _expandedDetails(NVOrder o) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          const SizedBox(height: 14),
          Text('${o.itemCount} item${o.itemCount > 1 ? 's' : ''} in this order',
              style: const TextStyle(color: NVColors.softGray, fontSize: 12.5)),
          const SizedBox(height: 10),
          _timelineRow(Icons.receipt_rounded, 'Order placed', o.date, true),
          _timelineRow(Icons.inventory_2_rounded, 'Processing', o.date, true),
          _timelineRow(
            Icons.local_shipping_rounded,
            'Shipped',
            o.status == OrderStatus.processing ? 'Pending' : o.date,
            o.status != OrderStatus.processing,
          ),
          _timelineRow(
            Icons.home_rounded,
            'Delivered',
            o.status == OrderStatus.delivered ? o.etaOrDelivered : 'Pending',
            o.status == OrderStatus.delivered,
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(IconData icon, String label, String date, bool done) {
    final color = done ? NVColors.gold : Colors.white.withOpacity(0.25);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: done ? NVColors.ivory : NVColors.softGray,
                    fontSize: 12.5)),
          ),
          Text(date, style: const TextStyle(color: NVColors.softGray, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _IconOnlyToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  const _IconOnlyToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: NVColors.gold.withOpacity(0.2),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: NVColors.ivory, size: 18),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// WISHLIST SECTION — product grid matching New Arrivals card style,
/// with quick view, add-to-cart, stock state, and remove animation.
/// =================================================================
class _WishlistSection extends StatefulWidget {
  final bool isMobile;
  final bool isTablet;
  const _WishlistSection({required this.isMobile, required this.isTablet});

  @override
  State<_WishlistSection> createState() => _WishlistSectionState();
}

class _WishlistSectionState extends State<_WishlistSection> {
  late List<NVProduct> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(_demoWishlist);
  }

  void _remove(NVProduct p) {
    // TODO: call existing wishlist provider/controller removal method.
    setState(() => _items.remove(p));
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.isMobile ? 2 : (widget.isTablet ? 3 : 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Saved for later',
          title: 'Your Wishlist',
          subtitle: '${_items.length} pieces waiting for you.',
          isMobile: widget.isMobile,
          trailing: NVPillButton(
            label: 'View All',
            icon: Icons.arrow_outward_rounded,
            small: true,
            onTap: () {},
          ),
        ),
        SizedBox(height: widget.isMobile ? 20 : 28),
        _items.isEmpty
            ? _emptyState()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: widget.isMobile ? 0.68 : 0.72,
                ),
                itemBuilder: (context, i) {
                  final p = _items[i];
                  return _WishlistProductCard(
                    product: p,
                    onRemove: () => _remove(p),
                  );
                },
              ),
      ],
    );
  }

  Widget _emptyState() {
    return NVGlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.favorite_border_rounded,
              size: 34, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('Your wishlist is empty',
              style: TextStyle(color: NVColors.ivory, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tap the heart icon on any product to save it here.',
              style: TextStyle(color: NVColors.softGray, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _WishlistProductCard extends StatefulWidget {
  final NVProduct product;
  final VoidCallback onRemove;
  const _WishlistProductCard({required this.product, required this.onRemove});

  @override
  State<_WishlistProductCard> createState() => _WishlistProductCardState();
}

class _WishlistProductCardState extends State<_WishlistProductCard> {
  bool _hover = false;
  bool _addedToCart = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: NVGlassCard(
          radius: 18,
          highlight: _hover,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hover ? 1.07 : 1.0,
                        duration: const Duration(milliseconds: 380),
                        child: Image.network(
                          p.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const NVShimmer(height: double.infinity, radius: 14);
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: NVColors.charcoalLight,
                            child: const Icon(Icons.image_outlined, color: NVColors.softGray),
                          ),
                        ),
                      ),
                      if (!p.inStock)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.55),
                            alignment: Alignment.center,
                            child: const Text('OUT OF STOCK',
                                style: TextStyle(
                                    color: NVColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8)),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _circleAction(
                          icon: Icons.favorite_rounded,
                          color: NVColors.danger,
                          onTap: widget.onRemove,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _circleAction(
                          icon: Icons.remove_red_eye_outlined,
                          color: NVColors.ivory,
                          // TODO: open existing quick-view modal/route.
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: NVColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('\$${p.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: NVColors.gold, fontSize: 13.5, fontWeight: FontWeight.w700)),
                  if (p.oldPrice != null) ...[
                    const SizedBox(width: 6),
                    Text('\$${p.oldPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                            color: NVColors.softGray.withOpacity(0.7),
                            fontSize: 11.5,
                            decoration: TextDecoration.lineThrough)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: NVPillButton(
                  label: _addedToCart ? 'Added \u2713' : 'Add to Cart',
                  icon: _addedToCart ? Icons.check_rounded : Icons.shopping_bag_outlined,
                  small: true,
                  solid: p.inStock,
                  // TODO: call existing add-to-cart controller/provider method.
                  onTap: p.inStock
                      ? () {
                          setState(() => _addedToCart = true);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) setState(() => _addedToCart = false);
                          });
                        }
                      : () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.45),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

/// =================================================================
/// LOYALTY DASHBOARD
/// Membership progress, points, offers, referral, coupons, cashback,
/// birthday reward, achievement badges.
/// =================================================================
class _LoyaltyDashboard extends StatelessWidget {
  final MembershipTier tier;
  final int points;
  final bool isMobile;
  final bool isTablet;

  const _LoyaltyDashboard({
    required this.tier,
    required this.points,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    const nextTierAt = 4000;
    final progress = (points / nextTierAt).clamp(0.0, 1.0);

    final badges = [
      ('First Order', Icons.local_shipping_rounded, true),
      ('5-Star Reviewer', Icons.star_rounded, true),
      ('Early Adopter', Icons.bolt_rounded, true),
      ('Referral Pro', Icons.groups_rounded, false),
      ('Big Spender', Icons.diamond_rounded, false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Loyalty',
          title: 'Rewards & Membership',
          subtitle: 'Climb tiers, unlock perks, earn as you shop.',
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 20 : 28),
        NVGlassCard(
          radius: 22,
          highlight: true,
          padding: EdgeInsets.all(isMobile ? 18 : 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _MembershipBadge(tier: tier),
                      const SizedBox(width: 10),
                      Text('$points pts',
                          style: const TextStyle(
                              color: NVColors.ivory,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('${nextTierAt - points} pts to Platinum',
                      style: const TextStyle(color: NVColors.softGray, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  height: 8,
                  color: Colors.white.withOpacity(0.08),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: v,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                              colors: [NVColors.gold, NVColors.beige]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _perksRow(),
              const SizedBox(height: 22),
              const Text('Achievements',
                  style: TextStyle(
                      color: NVColors.ivory, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: badges
                    .map((b) => _AchievementBadge(label: b.$1, icon: b.$2, unlocked: b.$3))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _perksRow() {
    final perks = [
      ('Cashback', '\$18.40', Icons.savings_rounded),
      ('Coupons', '${_demoCoupons.length} active', Icons.local_offer_rounded),
      ('Referral', 'Earn \$10', Icons.groups_rounded),
      ('Birthday', 'Jul 21 gift', Icons.cake_rounded),
    ];

    final columns = isMobile ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: perks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, i) {
        final p = perks[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(p.$3, color: NVColors.gold, size: 18),
              Text(p.$1, style: const TextStyle(color: NVColors.softGray, fontSize: 11)),
              Text(p.$2,
                  style: const TextStyle(
                      color: NVColors.ivory, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool unlocked;
  const _AchievementBadge({required this.label, required this.icon, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? NVColors.gold : Colors.white.withOpacity(0.25);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: unlocked ? NVColors.gold.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        border: Border.all(color: unlocked ? NVColors.gold.withOpacity(0.4) : Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: unlocked ? NVColors.ivory : NVColors.softGray,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// =================================================================
/// NOTIFICATION CENTER
/// =================================================================
class _NotificationCenter extends StatelessWidget {
  final bool isMobile;
  const _NotificationCenter({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Stay updated',
          title: 'Notifications',
          isMobile: isMobile,
          trailing: NVPillButton(
            label: 'Mark all read',
            icon: Icons.done_all_rounded,
            small: true,
            onTap: () {},
          ),
        ),
        SizedBox(height: isMobile ? 20 : 28),
        NVGlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            children: _demoNotifications
                .map((n) => _NotificationRow(notification: n))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatefulWidget {
  final NVNotification notification;
  const _NotificationRow({required this.notification});

  @override
  State<_NotificationRow> createState() => _NotificationRowState();
}

class _NotificationRowState extends State<_NotificationRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          splashColor: NVColors.gold.withOpacity(0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _hover ? Colors.white.withOpacity(0.04) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NVColors.gold.withOpacity(0.12),
                      ),
                      child: Icon(n.icon, size: 17, color: NVColors.gold),
                    ),
                    if (n.unread)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: NVColors.danger),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title,
                          style: const TextStyle(
                              color: NVColors.ivory, fontSize: 13.5, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(n.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: NVColors.softGray, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(n.time, style: const TextStyle(color: NVColors.softGray, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// RECOMMENDED FOR YOU / CONTINUE SHOPPING CAROUSEL
/// =================================================================
class _RecommendedSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  const _RecommendedSection({required this.isMobile, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final cardWidth = isMobile ? 168.0 : 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Just for you',
          title: 'Recommended & Continue Shopping',
          subtitle: 'Curated from your browsing and purchase history.',
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 20 : 28),
        SizedBox(
          height: isMobile ? 258 : 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _demoRecommended.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) =>
                _RecommendedCard(product: _demoRecommended[i], width: cardWidth),
          ),
        ),
      ],
    );
  }
}

class _RecommendedCard extends StatefulWidget {
  final NVProduct product;
  final double width;
  const _RecommendedCard({required this.product, required this.width});

  @override
  State<_RecommendedCard> createState() => _RecommendedCardState();
}

class _RecommendedCardState extends State<_RecommendedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: widget.width,
        transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
        child: NVGlassCard(
          radius: 18,
          highlight: _hover,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hover ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 380),
                        child: Image.network(
                          p.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: NVColors.charcoalLight,
                            child: const Icon(Icons.image_outlined, color: NVColors.softGray),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // TODO: hook to existing wishlist toggle.
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.45),
                              ),
                              child: const Icon(Icons.favorite_border_rounded,
                                  size: 13, color: NVColors.ivory),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: NVColors.ivory, fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text('\$${p.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: NVColors.gold, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================================================================
/// TESTIMONIALS
/// =================================================================
class _TestimonialsSection extends StatelessWidget {
  final bool isMobile;
  const _TestimonialsSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Loved by customers',
          title: 'What They\u2019re Saying',
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 20 : 28),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _demoTestimonials.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final t = _demoTestimonials[i];
              return SizedBox(
                width: isMobile ? 260 : 320,
                child: NVGlassCard(
                  radius: 18,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < t.rating.floor();
                          final half = t.rating - t.rating.floor() >= 0.5 && i == t.rating.floor();
                          return Icon(
                            half ? Icons.star_half_rounded : (filled ? Icons.star_rounded : Icons.star_border_rounded),
                            size: 15,
                            color: NVColors.gold,
                          );
                        }),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '\u201c${t.quote}\u201d',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: NVColors.softGray, fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ),
                      Text('\u2014 ${t.name}',
                          style: const TextStyle(color: NVColors.ivory, fontSize: 12.5, fontWeight: FontWeight.w600)),
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

/// =================================================================
/// FAQ SECTION
/// =================================================================
class _FaqSection extends StatefulWidget {
  final bool isMobile;
  const _FaqSection({required this.isMobile});

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(
          eyebrow: 'Need help?',
          title: 'Frequently Asked Questions',
          isMobile: widget.isMobile,
        ),
        SizedBox(height: widget.isMobile ? 20 : 28),
        NVGlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
            children: List.generate(_demoFaqs.length, (i) {
              final faq = _demoFaqs[i];
              final open = _openIndex == i;
              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _openIndex = open ? null : i),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(faq.question,
                                  style: const TextStyle(
                                      color: NVColors.ivory, fontSize: 13.5, fontWeight: FontWeight.w600)),
                            ),
                            AnimatedRotation(
                              turns: open ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(Icons.expand_more_rounded,
                                  color: Colors.white.withOpacity(0.4), size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    child: open
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 24, 14),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(faq.answer,
                                  style: const TextStyle(color: NVColors.softGray, fontSize: 12.5, height: 1.5)),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (i != _demoFaqs.length - 1)
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// =================================================================
/// SUPPORT SECTION — live chat, contact, return policy, social links
/// =================================================================
class _SupportSection extends StatelessWidget {
  final bool isMobile;
  const _SupportSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      ('Live Chat', Icons.chat_bubble_outline_rounded, NVColors.success),
      ('Call Us', Icons.call_outlined, NVColors.info),
      ('Email', Icons.mail_outline_rounded, NVColors.gold),
      ('Return Policy', Icons.assignment_return_outlined, NVColors.warning),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NVSectionHeader(eyebrow: 'We\u2019re here', title: 'Support', isMobile: isMobile),
        SizedBox(height: isMobile ? 20 : 28),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: shortcuts.map((s) {
            return SizedBox(
              width: isMobile ? (MediaQuery.of(context).size.width - 18 * 2 - 14) / 2 : 200,
              child: _SupportTile(label: s.$1, icon: s.$2, color: s.$3),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text('Follow us', style: TextStyle(color: NVColors.softGray, fontSize: 12.5)),
            const SizedBox(width: 14),
            _socialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 8),
            _socialIcon(Icons.play_arrow_rounded),
            const SizedBox(width: 8),
            _socialIcon(Icons.alternate_email_rounded),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Icon(icon, size: 14, color: NVColors.softGray),
    );
  }
}

class _SupportTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SupportTile({required this.label, required this.icon, required this.color});

  @override
  State<_SupportTile> createState() => _SupportTileState();
}

class _SupportTileState extends State<_SupportTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedScale(
          scale: _hover ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: NVGlassCard(
            radius: 16,
            highlight: _hover,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.label,
                      style: const TextStyle(
                          color: NVColors.ivory, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}