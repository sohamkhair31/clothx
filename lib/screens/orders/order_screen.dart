<<<<<<< HEAD
import 'dart:async';
import 'dart:ui';

=======
import 'package:cached_network_image/cached_network_image.dart';
>>>>>>> b0ced26b39c53e966cea1a49ca07b5396d35de3e
import 'package:clothx/controllers/auth_controller.dart';
import 'package:clothx/controllers/order_controller.dart';
// Reusing the exact same design system (colors + breakpoints) defined on
// the Home Page so this screen feels like one consistent luxury brand.
// If your Home Page file lives at a different path, update this import.
import 'package:clothx/screens/home/home_screen.dart' show NVColors, NVBreak;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // ------------------------------------------------------------------
  // The following are PURELY local, presentation-only UI state — they
  // only decide how the already-fetched `order.orders` list is
  // filtered/searched/sorted on screen. They never touch the
  // controller, the model, or Firebase in any way.
  // ------------------------------------------------------------------
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _newestFirst = true;

  // Tracks which order is mid-cancel so only that card's button shows a
  // spinner. Local UI state only — the cancel call itself is unchanged.
  String? _cancellingOrderId;

  @override
  void initState() {
    super.initState();

    // ---- business logic untouched ----
    Future.microtask(() async {
      final auth = context.read<AuthController>();

      final orderController = context.read<OrderController>();

      final user = auth.currentUser;

      if (user == null) return;

<<<<<<< HEAD
      // Load cache first
      orderController.loadOrdersFromCache(user.uid);

      // Then fetch latest from server
      await orderController.fetchOrders(user.uid);
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---- unchanged business logic: identical switch/cases as before ----
  // Only the returned Color values were refined to the Home Page's
  // premium muted palette. The mapping of status -> outcome is untouched.
=======
      orderController.loadOrdersFromCache(
        user.uid,
      );

      await orderController.fetchOrders(
        user.uid,
      );
    });
  }

  String optimizeImage(String url) {
    return url.replaceFirst(
      "/upload/",
      "/upload/f_auto,q_auto,w_150/",
    );
  }

>>>>>>> b0ced26b39c53e966cea1a49ca07b5396d35de3e
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return const Color(0xFFC8A86B); // warm gold
      case "confirmed":
        return const Color(0xFF6E7F70); // muted sage
      case "shipped":
        return const Color(0xFF5B6E8C); // muted slate blue
      case "delivered":
        return const Color(0xFF4C7A5D); // muted forest green
      case "cancelled":
        return const Color(0xFFA24C42); // muted brick red
      default:
        return NVColors.warmGray;
    }
  }

  // ---- presentation-only helper (additive) — does not alter any
  // existing logic, purely decides which icon a status chip shows.
  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.hourglass_top_rounded;
      case "confirmed":
        return Icons.verified_rounded;
      case "packed":
        return Icons.inventory_2_rounded;
      case "shipped":
        return Icons.local_shipping_rounded;
      case "out for delivery":
        return Icons.delivery_dining_rounded;
      case "delivered":
        return Icons.task_alt_rounded;
      case "cancelled":
        return Icons.cancel_rounded;
      case "returned":
        return Icons.assignment_return_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  // ---- presentation-only client-side view of the already-fetched list.
  // No controller/API/Firebase call is made here.
  List _visibleOrders(List source) {
    var list = source.where((o) {
      final status = (o.orderStatus as String).toLowerCase();

      final matchesFilter = switch (_selectedFilter) {
        'Active' => status != 'delivered' && status != 'cancelled',
        'Delivered' => status == 'delivered',
        'Cancelled' => status == 'cancelled',
        _ => true,
      };
      if (!matchesFilter) return false;

      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final matchesId = (o.orderId as String).toLowerCase().contains(q);
      final matchesProduct = (o.items as List)
          .any((it) => (it.name as String).toLowerCase().contains(q));
      return matchesId || matchesProduct;
    }).toList();

    if (!_newestFirst) list = list.reversed.toList();
    return list;
  }

  Future<void> _handleCancel(dynamic item) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CancelConfirmSheet(orderId: item.orderId as String),
    );
    if (confirmed != true) return;

    setState(() => _cancellingOrderId = item.orderId as String);

    // ---- exact same controller call as the original implementation ----
    await context.read<OrderController>().cancelOrder(item.orderId);

    if (mounted) setState(() => _cancellingOrderId = null);
  }

  void _openTrackOrder(dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TrackOrderSheet(
        orderId: item.orderId as String,
        status: item.orderStatus as String,
        statusColor: getStatusColor(item.orderStatus as String),
      ),
    );
  }

  void _openViewDetails(dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OrderDetailsSheet(
        item: item,
        statusColor: getStatusColor(item.orderStatus as String),
        statusIcon: _statusIcon(item.orderStatus as String),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderController>();
    final width = MediaQuery.of(context).size.width;
    final desktop = NVBreak.isDesktop(width);

    final visible = _visibleOrders(order.orders);

    return Scaffold(
      backgroundColor: NVColors.ivoryWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _OrdersHeader(
              width: width,
              totalOrders: order.orders.length,
              searchController: _searchController,
              selectedFilter: _selectedFilter,
              newestFirst: _newestFirst,
              onBack: () => Navigator.maybePop(context),
              onFilterChanged: (f) => setState(() => _selectedFilter = f),
              onSortToggle: () => setState(() => _newestFirst = !_newestFirst),
            ),
            Expanded(
              child: order.isLoading && order.orders.isEmpty
                  ? _OrdersShimmerList(width: width)
                  : order.orders.isEmpty
                      ? _EmptyOrdersState(
                          onContinueShopping: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        )
                      : visible.isEmpty
                          ? _NoResultsState(query: _searchQuery)
                          : RefreshIndicator(
                              color: NVColors.champagneGold,
                              backgroundColor: NVColors.cardWhite,
                              onRefresh: () async {
                                final auth = context.read<AuthController>();
                                final user = auth.currentUser;
                                if (user == null) return;
                                await context
                                    .read<OrderController>()
                                    .fetchOrders(user.uid);
                              },
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: desktop ? 880 : double.infinity,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.fromLTRB(
                                      NVBreak.hPad(width),
                                      20,
                                      NVBreak.hPad(width),
                                      40,
                                    ),
                                    itemCount: visible.length,
                                    itemBuilder: (context, index) {
                                      final item = visible[index];
                                      return _FadeSlideIn(
                                        key: ValueKey(item.orderId),
                                        delay: Duration(
                                          milliseconds:
                                              60 * index.clamp(0, 8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 18),
                                          child: _LuxuryOrderCard(
                                            item: item,
                                            desktop: desktop,
                                            statusColor: getStatusColor(
                                                item.orderStatus as String),
                                            statusIcon: _statusIcon(
                                                item.orderStatus as String),
                                            isCancelling: _cancellingOrderId ==
                                                item.orderId,
                                            onCancel: (item.orderStatus
                                                        as String)
                                                    .toLowerCase() ==
                                                'pending'
                                                ? () => _handleCancel(item)
                                                : null,
                                            onTrack: () =>
                                                _openTrackOrder(item),
                                            onViewDetails: () =>
                                                _openViewDetails(item),
                                          ),
                                        ),
                                      );
                                    },
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

/// ============================================================
/// HEADER — rich-black hero header with title, count, glass search
/// bar, filter chips and a sort toggle. Mirrors the Home Page navbar
/// language (rich black, champagne gold, serif wordmark accents).
/// ============================================================
class _OrdersHeader extends StatelessWidget {
  final double width;
  final int totalOrders;
  final TextEditingController searchController;
  final String selectedFilter;
  final bool newestFirst;
  final VoidCallback onBack;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onSortToggle;

  const _OrdersHeader({
    required this.width,
    required this.totalOrders,
    required this.searchController,
    required this.selectedFilter,
    required this.newestFirst,
    required this.onBack,
    required this.onFilterChanged,
    required this.onSortToggle,
  });

  static const _filters = ['All', 'Active', 'Delivered', 'Cancelled'];

<<<<<<< HEAD
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
                        "MY ORDERS",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: NVColors.ivoryWhite,
                          fontSize: desktop ? 26 : 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$totalOrders ${totalOrders == 1 ? 'Order' : 'Orders'} placed with you",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
=======
                      return Card(
                        margin:
                            const EdgeInsets.all(
                          12,
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Order ID",
                                style:
                                    AppTheme.subHeading,
                              ),

                              Text(
                                item.orderId,
                              ),

                              const SizedBox(
                                  height: 10),

                              Text(
                                "Total: ₹${item.totalAmount}",
                                style:
                                    AppTheme.body,
                              ),

                              const SizedBox(
                                  height: 10),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      getStatusColor(
                                    item.orderStatus,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  item.orderStatus
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  height: 15),

                              Text(
                                "Products",
                                style:
                                    AppTheme.subHeading,
                              ),

                              const SizedBox(
                                  height: 10),

                              ...item.items.map(
                                (cartItem) {
                                  return ListTile(
                                    contentPadding:
                                        EdgeInsets.zero,
                                    leading:
                                        CachedNetworkImage(
                                      imageUrl:
                                          optimizeImage(
                                        cartItem.image,
                                      ),
                                      width: 50,
                                      height: 50,
                                      fit:
                                          BoxFit.cover,
                                      placeholder:
                                          (
                                            context,
                                            url,
                                          ) =>
                                              const SizedBox(
                                        width: 50,
                                        height: 50,
                                        child:
                                            Center(
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                          ),
                                        ),
                                      ),
                                      errorWidget:
                                          (
                                            context,
                                            url,
                                            error,
                                          ) =>
                                              const Icon(
                                        Icons
                                            .broken_image,
                                      ),
                                    ),
                                    title: Text(
                                      cartItem.name,
                                    ),
                                    subtitle:
                                        Text(
                                      "Size: ${cartItem.size} | Qty: ${cartItem.quantity}",
                                    ),
                                    trailing:
                                        Text(
                                      "₹${cartItem.price}",
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(
                                  height: 10),

                              if (item.orderStatus
                                      .toLowerCase() ==
                                  "pending")
                                SizedBox(
                                  width:
                                      double.infinity,
                                  child:
                                      ElevatedButton(
                                    onPressed:
                                        () async {
                                      await context
                                          .read<
                                              OrderController>()
                                          .cancelOrder(
                                            item.orderId,
                                          );
                                    },
                                    child:
                                        const Text(
                                      "Cancel Order",
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
>>>>>>> b0ced26b39c53e966cea1a49ca07b5396d35de3e
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ---- glass search field ----
            ClipRRect(
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
                    style: const TextStyle(color: NVColors.ivoryWhite, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Search by order ID or product",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13.5),
                      prefixIcon: Icon(Icons.search, color: NVColors.champagneGold, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---- filter chips + sort ----
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final f = _filters[i];
                        final active = f == selectedFilter;
                        return _FilterChip(
                          label: f,
                          active: active,
                          onTap: () => onFilterChanged(f),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onSortToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: NVColors.champagneGold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          size: 14,
                          color: NVColors.champagneGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          newestFirst ? "Newest" : "Oldest",
                          style: const TextStyle(
                            color: NVColors.champagneGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? NVColors.champagneGold : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? NVColors.champagneGold : Colors.white24,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? NVColors.richBlack : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
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
/// ORDER CARD
/// ============================================================
class _LuxuryOrderCard extends StatelessWidget {
  final dynamic item;
  final bool desktop;
  final Color statusColor;
  final IconData statusIcon;
  final bool isCancelling;
  final VoidCallback? onCancel;
  final VoidCallback onTrack;
  final VoidCallback onViewDetails;

  const _LuxuryOrderCard({
    required this.item,
    required this.desktop,
    required this.statusColor,
    required this.statusIcon,
    required this.isCancelling,
    required this.onCancel,
    required this.onTrack,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final List cartItems = item.items as List;
    final firstItem = cartItems.isNotEmpty ? cartItems.first : null;
    final status = (item.orderStatus as String);

    return Container(
      decoration: BoxDecoration(
        color: NVColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NVColors.cardBorderBeige, width: 1),
        boxShadow: [
          BoxShadow(
            color: NVColors.richBlack.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- order id + status chip ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ORDER ID",
                      style: TextStyle(
                        color: NVColors.warmGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.orderId as String,
                      style: const TextStyle(
                        color: NVColors.richBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(label: status, color: statusColor, icon: statusIcon),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: NVColors.dividerPlatinum),
          const SizedBox(height: 16),

          // ---- product preview ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: firstItem != null
                    ? Image.network(
                        firstItem.image as String,
                        width: desktop ? 84 : 70,
                        height: desktop ? 84 : 70,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: desktop ? 84 : 70,
                        height: desktop ? 84 : 70,
                        color: NVColors.sectionBeige,
                        child: const Icon(Icons.image_outlined, color: NVColors.graphite),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstItem != null ? (firstItem.name as String) : "Order items",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NVColors.richBlack,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (firstItem != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MiniPill(text: "Size ${firstItem.size}"),
                          _MiniPill(text: "Qty ${firstItem.quantity}"),
                        ],
                      ),
                    if (cartItems.length > 1) ...[
                      const SizedBox(height: 6),
                      Text(
                        "+ ${cartItems.length - 1} more item${cartItems.length - 1 > 1 ? 's' : ''}",
                        style: const TextStyle(
                          color: NVColors.warmGray,
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: NVColors.dividerPlatinum),
          const SizedBox(height: 14),

          // ---- total ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ORDER TOTAL",
                style: TextStyle(
                  color: NVColors.warmGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                "₹${item.totalAmount}",
                style: const TextStyle(
                  color: NVColors.richBlack,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ---- actions ----
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _OutlineActionButton(
                label: "Track Order",
                icon: Icons.route_outlined,
                onTap: onTrack,
              ),
              _OutlineActionButton(
                label: "View Details",
                icon: Icons.receipt_long_outlined,
                onTap: onViewDetails,
              ),
              if (onCancel != null)
                _DangerActionButton(
                  label: "Cancel Order",
                  loading: isCancelling,
                  onTap: isCancelling ? null : onCancel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String text;
  const _MiniPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: NVColors.sectionBeige,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: NVColors.graphite,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineActionButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_OutlineActionButton> createState() => _OutlineActionButtonState();
}

class _OutlineActionButtonState extends State<_OutlineActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? NVColors.richBlack.withOpacity(0.04) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: NVColors.champagneGold, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: NVColors.warmGold),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: NVColors.richBlack,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _DangerActionButton({required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFA24C42).withOpacity(loading ? 0.55 : 1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.close_rounded, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              loading ? "Cancelling..." : label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// STATUS CHIP — premium pill with icon + soft pulse for
/// in-progress states. Color/logic comes from getStatusColor.
/// ============================================================
class _StatusChip extends StatefulWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusChip({required this.label, required this.color, required this.icon});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isActive {
    final s = widget.label.toLowerCase();
    return s != 'delivered' && s != 'cancelled' && s != 'returned';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
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
        final glow = _isActive ? 0.15 + _controller.value * 0.2 : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.5)),
            boxShadow: _isActive
                ? [BoxShadow(color: widget.color.withOpacity(glow), blurRadius: 10)]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 13, color: widget.color),
              const SizedBox(width: 5),
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: widget.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ============================================================
/// CANCEL CONFIRM SHEET
/// ============================================================
class _CancelConfirmSheet extends StatelessWidget {
  final String orderId;
  const _CancelConfirmSheet({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFA24C42).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Color(0xFFA24C42), size: 26),
          ),
          const SizedBox(height: 16),
          const Text(
            "Cancel this order?",
            style: TextStyle(
              fontFamily: 'Georgia',
              color: NVColors.richBlack,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Order $orderId will be cancelled. This action cannot be undone.",
            style: const TextStyle(color: NVColors.warmGray, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SheetGhostButton(
                  label: "Keep Order",
                  onTap: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetFilledButton(
                  label: "Yes, Cancel",
                  color: const Color(0xFFA24C42),
                  onTap: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// TRACK ORDER SHEET — derived entirely from the existing
/// orderStatus string, no new data or API calls involved.
/// ============================================================
class _TrackOrderSheet extends StatelessWidget {
  final String orderId;
  final String status;
  final Color statusColor;
  const _TrackOrderSheet({required this.orderId, required this.status, required this.statusColor});

  static const _steps = ['pending', 'confirmed', 'shipped', 'delivered'];

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final cancelled = normalized == 'cancelled';
    final currentIndex = _steps.indexOf(normalized);

    return _SheetShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Order $orderId",
            style: const TextStyle(color: NVColors.warmGray, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track Your Order",
            style: TextStyle(
              fontFamily: 'Georgia',
              color: NVColors.richBlack,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          if (cancelled)
            Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Color(0xFFA24C42)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "This order was cancelled and is no longer being processed.",
                    style: TextStyle(color: NVColors.graphite, fontSize: 13.5, height: 1.5),
                  ),
                ),
              ],
            )
          else
            Column(
              children: List.generate(_steps.length, (i) {
                final done = currentIndex >= 0 && i <= currentIndex;
                final isLast = i == _steps.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? statusColor : NVColors.sectionBeige,
                              border: Border.all(
                                color: done ? statusColor : NVColors.dividerPlatinum,
                              ),
                            ),
                            child: done
                                ? const Icon(Icons.check, size: 13, color: Colors.white)
                                : null,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: done ? statusColor : NVColors.dividerPlatinum,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Text(
                          _steps[i][0].toUpperCase() + _steps[i].substring(1),
                          style: TextStyle(
                            color: done ? NVColors.richBlack : NVColors.warmGray,
                            fontSize: 14,
                            fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

/// ============================================================
/// VIEW DETAILS SHEET — full breakdown of the same order/item
/// data already available on the card; nothing new is fetched.
/// ============================================================
class _OrderDetailsSheet extends StatelessWidget {
  final dynamic item;
  final Color statusColor;
  final IconData statusIcon;
  const _OrderDetailsSheet({required this.item, required this.statusColor, required this.statusIcon});

  @override
  Widget build(BuildContext context) {
    final List cartItems = item.items as List;

    return _SheetShell(
      maxHeightFactor: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Order ${item.orderId}",
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: NVColors.richBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(
                label: item.orderStatus as String,
                color: statusColor,
                icon: statusIcon,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 26, color: NVColors.dividerPlatinum),
              itemBuilder: (context, i) {
                final it = cartItems[i];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        it.image as String,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.name as String,
                            style: const TextStyle(
                              color: NVColors.richBlack,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _MiniPill(text: "Size ${it.size}"),
                              _MiniPill(text: "Qty ${it.quantity}"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${it.price}",
                      style: const TextStyle(
                        color: NVColors.richBlack,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: NVColors.dividerPlatinum),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ORDER TOTAL",
                style: TextStyle(
                  color: NVColors.warmGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                "₹${item.totalAmount}",
                style: const TextStyle(
                  color: NVColors.richBlack,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared rounded-top bottom-sheet shell used by all sheets above.
class _SheetShell extends StatelessWidget {
  final Widget child;
  final double maxHeightFactor;
  const _SheetShell({required this.child, this.maxHeightFactor = 0.7});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * maxHeightFactor),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          decoration: const BoxDecoration(
            color: NVColors.cardWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: NVColors.dividerPlatinum,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SheetGhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: NVColors.inputBorderGray),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: NVColors.graphite,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SheetFilledButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetFilledButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// EMPTY STATES
/// ============================================================
class _EmptyOrdersState extends StatelessWidget {
  final VoidCallback onContinueShopping;
  const _EmptyOrdersState({required this.onContinueShopping});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NVColors.sectionBeige,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 44,
                  color: NVColors.warmGold,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                "No Orders Yet",
                style: TextStyle(
                  fontFamily: 'Georgia',
                  color: NVColors.richBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your future favourites are waiting. Start building\na wardrobe that feels like you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: NVColors.warmGray, fontSize: 13.5, height: 1.6),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onContinueShopping,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: NVColors.cardBorderBeige,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: NVColors.cardBorderBeige, width: 1.4),
                  ),
                  child: const Text(
                    "CONTINUE SHOPPING",
                    style: TextStyle(
                      color: NVColors.richBlack,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      letterSpacing: 1.2,
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

class _NoResultsState extends StatelessWidget {
  final String query;
  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: NVColors.warmGray),
            const SizedBox(height: 14),
            Text(
              query.trim().isEmpty
                  ? "No orders match this filter"
                  : "No orders match \"$query\"",
              textAlign: TextAlign.center,
              style: const TextStyle(color: NVColors.graphite, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// SHIMMER LOADING STATE
/// ============================================================
class _OrdersShimmerList extends StatelessWidget {
  final double width;
  const _OrdersShimmerList({required this.width});

  @override
  Widget build(BuildContext context) {
    final hPad = NVBreak.hPad(width);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
      itemCount: 4,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NVColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NVColors.dividerPlatinum),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBlock(width: 90, height: 12),
              const Spacer(),
              _shimmerBlock(width: 70, height: 22, radius: 12),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBlock(width: 70, height: 70, radius: 16),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBlock(width: double.infinity, height: 14),
                    const SizedBox(height: 10),
                    _shimmerBlock(width: 120, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _shimmerBlock(width: double.infinity, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _shimmerBlock(width: 100, height: 26, radius: 20),
              const SizedBox(width: 10),
              _shimmerBlock(width: 100, height: 26, radius: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerBlock({required double width, required double height, double radius = 6}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
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

/// Fade + slide entrance with an optional stagger delay, used across
/// this screen the same way the Home Page reveals its sections.
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
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(_fade);
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