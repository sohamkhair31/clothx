import 'package:flutter/material.dart';
import '../core/services/cache/cache_service.dart';
import '../models/wishlist_model.dart';
import '../repositories/wishlist_repo.dart';

class WishlistController extends ChangeNotifier {
  final WishlistRepo _wishlistRepo = WishlistRepo();
  final CacheService _cacheService = CacheService();

  List<WishlistModel> _items = [];
  List<WishlistModel> get items => _items;

  bool isLoading = false;
  bool isSyncing = false;
  String? errorMessage;

  Set<String> get wishlistIds => _items.map((e) => e.productId).toSet();

  bool isWishlisted(String productId) => wishlistIds.contains(productId);

  // ================= LOAD FROM CACHE =================
  void loadFromCache(String userId) {
    final cached = _cacheService.getWishlist(userId);

    if (cached.isNotEmpty) {
      _items = cached
          .map<WishlistModel>(
            (e) => WishlistModel.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
      notifyListeners();
    }
  }

  // ================= SYNC WITH FIREBASE =================
  Future<void> syncWishlist(String userId) async {
    try {
      isSyncing = true;
      if (_items.isEmpty) isLoading = true;
      notifyListeners();

      final localMeta = _cacheService.getWishlistMeta(userId);
      final serverMeta = await _wishlistRepo.getWishlistMeta(userId);

      if (localMeta == serverMeta && _items.isNotEmpty) {
        isLoading = false;
        isSyncing = false;
        notifyListeners();
        return;
      }

      final freshItems = await _wishlistRepo.fetchWishlist(userId);
      _items = freshItems;

      await _cacheService.saveWishlist(
        userId,
        _items.map((e) => e.toMap()).toList(),
      );
      await _cacheService.saveWishlistMeta(userId, serverMeta);

      isLoading = false;
      isSyncing = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      isSyncing = false;
      notifyListeners();
    }
  }

  // ================= TOGGLE =================
  Future<bool> toggleWishlist(String userId, String productId) async {
    final alreadyIn = isWishlisted(productId);
    final previous = List<WishlistModel>.from(_items);

    // Optimistic update so the heart responds instantly.
    if (alreadyIn) {
      _items.removeWhere((e) => e.productId == productId);
    } else {
      _items.insert(
        0,
        WishlistModel(productId: productId, addedAt: DateTime.now()),
      );
    }
    notifyListeners();

    try {
      if (alreadyIn) {
        await _wishlistRepo.removeFromWishlist(userId, productId);
      } else {
        await _wishlistRepo.addToWishlist(userId, productId);
      }

      final serverMeta = await _wishlistRepo.getWishlistMeta(userId);
      await _cacheService.saveWishlist(
        userId,
        _items.map((e) => e.toMap()).toList(),
      );
      await _cacheService.saveWishlistMeta(userId, serverMeta);

      return true;
    } catch (e) {
      // Revert the optimistic change if the write failed.
      _items = previous;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ================= CLEAR (e.g. on logout) =================
  void clear() {
    _items = [];
    notifyListeners();
  }
}