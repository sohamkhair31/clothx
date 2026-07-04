import 'dart:ui';

import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/core/theme/app_theme.dart';
import 'package:clothx/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ============================================================
/// NEW VISION'S — PREMIUM LUXURY PROFILE PAGE (UI-ONLY REDESIGN)
/// ============================================================
/// IMPORTANT:
/// - No business logic was changed. `AuthController` calls
///   (getUserData, updateProfile, logout) and the edit-dialog
///   save flow are untouched from the original implementation.
/// - Sections like "Quick Access", "Stats", and "Preferences"
///   are presented as premium UI shells only. Your original code
///   didn't expose orders/wishlist/points data, so instead of
///   fabricating numbers, those cards are wired to safe TODO
///   callbacks (a SnackBar) — swap them for real navigation /
///   providers whenever that data exists.
/// - Only built-in Flutter widgets are used. No external packages
///   or fonts.
/// - FIX: `_Palette.card` was referenced but never defined in the
///   previous version (compile error). It's now defined, and every
///   card surface uses a layered soft-peach gradient (#EFCDBA base)
///   for a more premium, luxury feel, with a warmer gradient + glow
///   on hover.
/// ============================================================

class _Palette {
  static const background = Color(0xFFFAF8F5);
  static const navFooter = Color(0xFF0A0A0A);

  static const primaryBtn = Color(0xFFEFCDBA);
  static const primaryBtnHover = Color(0xFFF8E2D8);
  static const secondaryBtn = Color(0xFFD6C08D);

  static const textPrimary = Color(0xFF0A0A0A);
  static const textSecondary = Color(0xFF2B2B2B);

  static const border = Color(0xFFB9BDC4);
  static const highlight = Color(0xFFEFCDBA);

  /// Solid fallback peach — used wherever a plain Color (not a
  /// gradient) is required, e.g. `.withOpacity()` calls.
  static const card = Color(0xFFFFF7F2);

  /// Premium Peach Gradient — used for large surfaces (dialog, glass
  /// panels).
  static const LinearGradient peachGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF4EF),
      Color(0xFFF4D9CB),
      Color(0xFFEFCDBA),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Layered soft-peach gradient used for every card surface
  /// (stat cards, quick-access cards, info cards, avatar disc).
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF3EC),
      Color(0xFFF7DFCF),
      Color(0xFFEFCDBA),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  /// Slightly warmer/richer variant used when a card is hovered, to
  /// give a subtle "glowing" premium lift.
  static const LinearGradient cardHoverGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFE9DF),
      Color(0xFFF6D2BC),
      Color(0xFFEFCDBA),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    // ---------- ORIGINAL LOGIC (UNCHANGED) ----------
    Future.microtask(() async {
      final auth = context.read<AuthController>();

      if (auth.currentUser != null && auth.currentUserData == null) {
        await auth.getUserData();
      }
    });
    // -------------------------------------------------

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // ---------- ORIGINAL LOGIC (UNCHANGED) ----------
  void showEditDialog(BuildContext context, AuthController auth) {
    final user = auth.currentUserData;

    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    final addressController = TextEditingController(text: user.address);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: _Palette.peachGradient,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _Palette.highlight.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: _Palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your personal details',
                        style: TextStyle(
                          fontSize: 13,
                          color: _Palette.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _LuxuryTextField(
                        label: 'Full Name',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      _LuxuryTextField(
                        label: 'Phone',
                        controller: phoneController,
                      ),
                      const SizedBox(height: 16),
                      _LuxuryTextField(
                        label: 'Address',
                        controller: addressController,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: _Palette.border.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: _Palette.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: _HoverScaleButton(
                              onTap: () async {
                                final newName = nameController.text.trim();
                                final newPhone = phoneController.text.trim();
                                final newAddress =
                                    addressController.text.trim();

                                // Prevent unnecessary writes
                                if (newName == user.name &&
                                    newPhone == user.phone &&
                                    newAddress == user.address) {
                                  Navigator.pop(context);
                                  return;
                                }

                                final success = await auth.updateProfile(
                                  name: newName,
                                  phone: newPhone,
                                  address: newAddress,
                                );

                                if (!mounted) return;

                                if (success) {
                                  Navigator.pop(context);
                                }
                              },
                              builder: (hovering) => Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: hovering
                                      ? _Palette.primaryBtnHover
                                      : _Palette.primaryBtn,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _Palette.primaryBtn
                                          .withOpacity(0.5),
                                      blurRadius: hovering ? 18 : 8,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: _Palette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  // -------------------------------------------------

  void _todo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _Palette.navFooter,
        content: Text(
          '$feature — connect this to your existing provider/route.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ---------- ORIGINAL LOGIC (UNCHANGED) ----------
    final auth = context.watch<AuthController>();
    final user = auth.currentUserData;
    // -------------------------------------------------

    return Scaffold(
      backgroundColor: _Palette.background,
      body: auth.isLoading
          ? const _LoadingState()
          : user == null
              ? Center(
                  child: Text(
                    'No user data',
                    style: AppTheme.subHeading,
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isDesktop = width >= 1100;
                    final isTablet = width >= 700 && width < 1100;
                    final horizontalPadding =
                        isDesktop ? 64.0 : (isTablet ? 40.0 : 20.0);
                    final maxContentWidth = isDesktop ? 1200.0 : width;

                    return Stack(
                      children: [
                        _FloatingShapes(controller: _entranceController),
                        CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: _TopNav(
                                horizontalPadding: horizontalPadding,
                                onNotifications: () =>
                                    _todo(context, 'Notifications'),
                                onWishlist: () => _todo(context, 'Wishlist'),
                                onSettings: () => _todo(context, 'Settings'),
                                onLogout: () async {
                                  // ---------- ORIGINAL LOGIC (UNCHANGED) ----------
                                  await auth.logout();

                                  if (!mounted) return;

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AuthScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  // -------------------------------------------------
                                },
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: maxContentWidth,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 24),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.0,
                                            0.5,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _ProfileHeader(
                                            name: user.name,
                                            email: user.email,
                                            isDesktop: isDesktop,
                                            onEdit: () =>
                                                showEditDialog(context, auth),
                                            onMembership: () => _todo(
                                              context,
                                              'View Membership',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 36),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.1,
                                            0.6,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _StatsSection(
                                            hasAddress:
                                                user.address.isNotEmpty,
                                            hasPhone: user.phone.isNotEmpty,
                                            isDesktop: isDesktop,
                                            isTablet: isTablet,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.15,
                                            0.65,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _SectionTitle(
                                            title: 'Quick Access',
                                            subtitle:
                                                'Everything you need, one tap away',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.2,
                                            0.7,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _QuickAccessGrid(
                                            isDesktop: isDesktop,
                                            isTablet: isTablet,
                                            onTap: (label) =>
                                                _todo(context, label),
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.25,
                                            0.75,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: const _SectionTitle(
                                            title: 'Account Information',
                                            subtitle:
                                                'Your personal details, always up to date',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.3,
                                            0.8,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _AccountInfoGrid(
                                            isDesktop: isDesktop,
                                            isTablet: isTablet,
                                            name: user.name,
                                            email: user.email,
                                            phone: user.phone,
                                            address: user.address,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.35,
                                            0.85,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: const _SectionTitle(
                                            title: 'Account Preferences',
                                            subtitle:
                                                'Fine-tune your experience',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.4,
                                            0.9,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _PreferencesSection(
                                            isDesktop: isDesktop,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        _FadeSlideIn(
                                          controller: _entranceController,
                                          interval: const Interval(
                                            0.45,
                                            0.95,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: _PromoBanner(
                                            isDesktop: isDesktop,
                                            onTap: () => _todo(
                                              context,
                                              'Explore Collection',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 48),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: _Footer(isDesktop: isDesktop),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

/// ---------------- LOADING STATE ----------------
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: _Palette.highlight,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Curating your profile…',
            style: TextStyle(
              color: _Palette.textSecondary,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- ENTRANCE ANIMATION WRAPPER ----------------
class _FadeSlideIn extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;

  const _FadeSlideIn({
    required this.controller,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: interval);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}

/// ---------------- FLOATING DECORATIVE SHAPES ----------------
class _FloatingShapes extends StatelessWidget {
  final AnimationController controller;
  const _FloatingShapes({required this.controller});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;
          return Stack(
            children: [
              Positioned(
                top: -60 + (t * 10),
                right: -60,
                child: _blob(220, _Palette.secondaryBtn.withOpacity(0.18)),
              ),
              Positioned(
                top: 320 - (t * 14),
                left: -80,
                child: _blob(260, _Palette.primaryBtn.withOpacity(0.22)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}

/// ---------------- TOP NAV ----------------
class _TopNav extends StatelessWidget {
  final double horizontalPadding;
  final VoidCallback onNotifications;
  final VoidCallback onWishlist;
  final VoidCallback onSettings;
  final Future<void> Function() onLogout;

  const _TopNav({
    required this.horizontalPadding,
    required this.onNotifications,
    required this.onWishlist,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Palette.navFooter,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'NEW ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 3,
                  ),
                ),
                TextSpan(
                  text: "VISION'S",
                  style: TextStyle(
                    color: _Palette.highlight,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _NavIcon(icon: Icons.notifications_none, onTap: onNotifications),
              const SizedBox(width: 8),
              _NavIcon(icon: Icons.favorite_border, onTap: onWishlist),
              const SizedBox(width: 8),
              _NavIcon(icon: Icons.settings_outlined, onTap: onSettings),
              const SizedBox(width: 8),
              _NavIcon(
                icon: Icons.logout,
                onTap: () async => onLogout(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavIcon({required this.icon, required this.onTap});

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovering
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(_hovering ? 0.3 : 0.12),
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 19,
          ),
        ),
      ),
    );
  }
}

/// ---------------- HOVER SCALE BUTTON ----------------
class _HoverScaleButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool hovering) builder;

  const _HoverScaleButton({required this.onTap, required this.builder});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hovering ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          child: widget.builder(_hovering),
        ),
      ),
    );
  }
}

/// ---------------- PROFILE HEADER ----------------
class _ProfileHeader extends StatefulWidget {
  final String name;
  final String email;
  final bool isDesktop;
  final VoidCallback onEdit;
  final VoidCallback onMembership;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.isDesktop,
    required this.onEdit,
    required this.onMembership,
  });

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _avatarHover = false;

  @override
  Widget build(BuildContext context) {
    final initial = widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?';

    final avatar = MouseRegion(
      onEnter: (_) => setState(() => _avatarHover = true),
      onExit: (_) => setState(() => _avatarHover = false),
      child: AnimatedScale(
        scale: _avatarHover ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _Palette.highlight,
                _Palette.primaryBtn,
                _Palette.secondaryBtn,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.highlight.withOpacity(_avatarHover ? 0.55 : 0.35),
                blurRadius: _avatarHover ? 36 : 24,
                spreadRadius: _avatarHover ? 2 : 0,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: _Palette.background,
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: _Palette.cardGradient,
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: _Palette.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final nameAndMeta = Column(
      crossAxisAlignment: widget.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          widget.name,
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            color: _Palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.email,
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: _Palette.textSecondary.withOpacity(0.75),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment:
              widget.isDesktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _Badge(
              icon: Icons.workspace_premium_outlined,
              label: 'Premium Member',
            ),
            _Badge(icon: Icons.star_outline, label: 'Loyalty Gold'),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment:
              widget.isDesktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 14,
          runSpacing: 12,
          children: [
            _HoverScaleButton(
              onTap: widget.onEdit,
              builder: (hovering) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                decoration: BoxDecoration(
                  color: hovering
                      ? _Palette.primaryBtnHover
                      : _Palette.primaryBtn,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.primaryBtn.withOpacity(0.45),
                      blurRadius: hovering ? 20 : 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, size: 17, color: _Palette.textPrimary),
                    SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _Palette.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _HoverScaleButton(
              onTap: widget.onMembership,
              builder: (hovering) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hovering
                        ? _Palette.secondaryBtn
                        : _Palette.border.withOpacity(0.7),
                    width: 1.3,
                  ),
                ),
                child: const Text(
                  'View Membership',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _Palette.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return _GlassCard(
      padding: EdgeInsets.all(widget.isDesktop ? 40 : 26),
      child: widget.isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(width: 36),
                Expanded(child: nameAndMeta),
              ],
            )
          : Column(
              children: [
                avatar,
                const SizedBox(height: 22),
                nameAndMeta,
              ],
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _Palette.highlight.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _Palette.highlight.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _Palette.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- GLASS CARD ----------------
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.55),
                _Palette.highlight.withOpacity(0.22),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _Palette.highlight.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ---------------- STATS SECTION ----------------
class _StatsSection extends StatelessWidget {
  final bool hasAddress;
  final bool hasPhone;
  final bool isDesktop;
  final bool isTablet;

  const _StatsSection({
    required this.hasAddress,
    required this.hasPhone,
    required this.isDesktop,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(icon: Icons.checklist_rtl, label: 'Profile Complete',
          value: hasAddress && hasPhone ? '100%' : '75%'),
      _StatItem(icon: Icons.home_outlined, label: 'Saved Addresses',
          value: hasAddress ? '1' : '0'),
      _StatItem(icon: Icons.phone_outlined, label: 'Contact Verified',
          value: hasPhone ? 'Yes' : 'Pending'),
      _StatItem(icon: Icons.shield_moon_outlined, label: 'Account Status',
          value: 'Active'),
    ];

    final crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: isDesktop ? 1.5 : 1.3,
      ),
      itemBuilder: (context, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;

  _StatItem({required this.icon, required this.label, required this.value});
}

class _StatCard extends StatefulWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _hovering ? _Palette.cardHoverGradient : _Palette.cardGradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovering
                ? _Palette.secondaryBtn
                : _Palette.highlight.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.highlight.withOpacity(_hovering ? 0.35 : 0.15),
              blurRadius: _hovering ? 24 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(widget.item.icon, color: _Palette.textPrimary, size: 22),
            const Spacer(),
            Text(
              widget.item.value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _Palette.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.item.label,
              style: TextStyle(
                fontSize: 12,
                color: _Palette.textSecondary.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SECTION TITLE ----------------
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _Palette.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: _Palette.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// ---------------- QUICK ACCESS GRID ----------------
class _QuickAccessGrid extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final void Function(String label) onTap;

  const _QuickAccessGrid({
    required this.isDesktop,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <(IconData, String)>[
      (Icons.local_mall_outlined, 'My Orders'),
      (Icons.favorite_border, 'Wishlist'),
      (Icons.shopping_bag_outlined, 'Cart'),
      (Icons.location_on_outlined, 'Saved Addresses'),
      (Icons.credit_card_outlined, 'Payment Methods'),
      (Icons.history, 'Recently Viewed'),
      (Icons.local_offer_outlined, 'Coupons'),
      (Icons.notifications_none, 'Notifications'),
      (Icons.settings_outlined, 'Settings'),
      (Icons.support_agent_outlined, 'Customer Support'),
      (Icons.help_outline, 'Help Center'),
    ];

    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, i) {
        final (icon, label) = entries[i];
        return _QuickAccessCard(
          icon: icon,
          label: label,
          onTap: () => onTap(label),
        );
      },
    );
  }
}

class _QuickAccessCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient:
                  _hovering ? _Palette.cardHoverGradient : _Palette.cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hovering
                    ? _Palette.secondaryBtn
                    : _Palette.highlight.withOpacity(0.45),
              ),
              boxShadow: [
                BoxShadow(
                  color: _Palette.highlight.withOpacity(_hovering ? 0.3 : 0.12),
                  blurRadius: _hovering ? 20 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(widget.icon, color: _Palette.textPrimary, size: 24),
                const SizedBox(height: 14),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: _Palette.textPrimary,
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

/// ---------------- ACCOUNT INFO GRID ----------------
class _AccountInfoGrid extends StatelessWidget {
  final bool isDesktop;
  final bool isTablet;
  final String name;
  final String email;
  final String phone;
  final String address;

  const _AccountInfoGrid({
    required this.isDesktop,
    required this.isTablet,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      (Icons.person_outline, 'Full Name', name),
      (Icons.email_outlined, 'Email', email),
      (Icons.phone_outlined, 'Phone Number', phone.isEmpty ? '—' : phone),
      (Icons.home_outlined, 'Address', address.isEmpty ? '—' : address),
    ];

    final crossAxisCount = isDesktop ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: isDesktop ? 4.4 : 4.0,
      ),
      itemBuilder: (context, i) {
        final (icon, label, value) = fields[i];
        return _InfoCard(icon: icon, label: label, value: value);
      },
    );
  }
}

class _InfoCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: _hovering ? _Palette.cardHoverGradient : _Palette.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovering
                ? _Palette.secondaryBtn
                : _Palette.highlight.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _Palette.highlight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, size: 18, color: _Palette.textPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _Palette.textSecondary.withOpacity(0.7),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _Palette.textPrimary,
                    ),
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

/// ---------------- PREFERENCES SECTION ----------------
class _PreferencesSection extends StatefulWidget {
  final bool isDesktop;
  const _PreferencesSection({required this.isDesktop});

  @override
  State<_PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<_PreferencesSection> {
  // NOTE: purely local UI state for the toggle visuals — not wired to any
  // backend/provider. Hook these into your real settings logic as needed.
  bool _darkMode = false;
  bool _notifications = true;
  bool _privacy = true;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PrefItem('Dark Mode', Icons.dark_mode_outlined, _darkMode,
          (v) => setState(() => _darkMode = v)),
      _PrefItem('Notifications', Icons.notifications_active_outlined,
          _notifications, (v) => setState(() => _notifications = v)),
      _PrefItem('Privacy', Icons.lock_outline, _privacy,
          (v) => setState(() => _privacy = v)),
    ];

    return _GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _PreferenceRow(item: items[i]),
            if (i != items.length - 1)
              Divider(color: _Palette.border.withOpacity(0.3), height: 28),
          ],
        ],
      ),
    );
  }
}

class _PrefItem {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  _PrefItem(this.label, this.icon, this.value, this.onChanged);
}

class _PreferenceRow extends StatelessWidget {
  final _PrefItem item;
  const _PreferenceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(item.icon, size: 20, color: _Palette.textPrimary),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _Palette.textPrimary,
            ),
          ),
        ),
        Switch(
          value: item.value,
          onChanged: item.onChanged,
          activeColor: _Palette.textPrimary,
          activeTrackColor: _Palette.highlight,
        ),
      ],
    );
  }
}

/// ---------------- PROMO BANNER ----------------
class _PromoBanner extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onTap;

  const _PromoBanner({required this.isDesktop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_Palette.navFooter, Color(0xFF1D1B17)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment:
            isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exclusive Collections',
                  style: TextStyle(
                    color: _Palette.highlight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Curated for you, before anyone else.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover new arrivals crafted for the New Vision\'s inner circle.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 22),
          _HoverScaleButton(
            onTap: onTap,
            builder: (hovering) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
              decoration: BoxDecoration(
                color: hovering ? _Palette.primaryBtnHover : _Palette.primaryBtn,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Explore Collection',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _Palette.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- FOOTER ----------------
class _Footer extends StatelessWidget {
  final bool isDesktop;
  const _Footer({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _Palette.navFooter,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NV'S",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: const [
              _FooterLink('Customer Support'),
              _FooterLink('Privacy Policy'),
              _FooterLink('Terms & Conditions'),
              _FooterLink('Contact Us'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              _SocialIcon(Icons.camera_alt_outlined),
              SizedBox(width: 12),
              _SocialIcon(Icons.facebook_outlined),
              SizedBox(width: 12),
              _SocialIcon(Icons.alternate_email),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text(
            '© ${DateTime.now().year} New Vision\'s. All rights reserved.',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  const _SocialIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(icon, size: 15, color: Colors.white70),
    );
  }
}

/// ---------------- LUXURY TEXT FIELD (dialog) ----------------
class _LuxuryTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _LuxuryTextField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _Palette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _Palette.textSecondary.withOpacity(0.7)),
        filled: true,
        fillColor: _Palette.card.withOpacity(0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _Palette.border.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _Palette.border.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Palette.highlight, width: 1.6),
        ),
      ),
    );
  }
}