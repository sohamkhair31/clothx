import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../core/services/cache/cache_service.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CacheService _cacheService =
      CacheService();

  List<ProductModel> products = [];

  bool isLoading = false;
  String? errorMessage;

  bool loadedFromCache = false;
  bool loadedFromServer = false;

  DateTime? lastCacheLoad;
  DateTime? lastServerFetch;

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // STEP 1: LOAD CACHE FIRST
      final cachedProducts =
          _cacheService.getProducts();

      if (cachedProducts.isNotEmpty) {
        products =
            cachedProducts.map<ProductModel>((e) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        loadedFromCache = true;
        lastCacheLoad = DateTime.now();

        notifyListeners();
      }

      // STEP 2: LOCAL META
      final localMeta =
          _cacheService.getLastMeta();

      // STEP 3: SERVER META
      final metaDoc = await _firestore
          .collection("app_meta")
          .doc("products")
          .get();

      if (!metaDoc.exists) {
        isLoading = false;
        notifyListeners();
        return;
      }

      final serverMeta =
          (metaDoc["lastUpdated"] as Timestamp)
              .toDate()
              .toIso8601String();

      // STEP 4: SKIP IF SAME
      if (localMeta == serverMeta) {
        print(
          "No changes. Using cache only.",
        );

        loadedFromServer = false;

        isLoading = false;
        notifyListeners();
        return;
      }

      QuerySnapshot<Map<String, dynamic>>
          snapshot;

      // STEP 5A: FIRST FETCH
      if (products.isEmpty) {
        snapshot = await _firestore
            .collection("products")
            .where(
              "isActive",
              isEqualTo: true,
            )
            .orderBy("updatedAt")
            .get();
      }

      // STEP 5B: INCREMENTAL FETCH
      else {
        final latestProductTime =
            products
                .map((e) => e.updatedAt)
                .reduce(
                  (a, b) =>
                      a.isAfter(b)
                          ? a
                          : b,
                );

        snapshot = await _firestore
            .collection("products")
            .where(
              "isActive",
              isEqualTo: true,
            )
            .where(
              "updatedAt",
              isGreaterThan:
                  Timestamp.fromDate(
                latestProductTime,
              ),
            )
            .orderBy("updatedAt")
            .get();
      }

      final newProducts =
          snapshot.docs.map((doc) {
        return ProductModel.fromMap(
          doc.data(),
        );
      }).toList();

      // STEP 6: MERGE
      for (var newProduct in newProducts) {
        final index = products.indexWhere(
          (p) => p.id == newProduct.id,
        );

        if (index != -1) {
          products[index] = newProduct;
        } else {
          products.add(newProduct);
        }
      }

      loadedFromServer = true;
      lastServerFetch = DateTime.now();

      // STEP 7: SAVE CACHE
      await _cacheService.saveProducts(
        products.map((e) => e.toMap()).toList(),
      );

      await _cacheService.saveLastMeta(
        serverMeta,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print(
        "ProductController Error: $e",
      );

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= CACHE ONLY =================
  void loadFromCacheOnly() {
    final cachedProducts =
        _cacheService.getProducts();

    if (cachedProducts.isNotEmpty) {
      products =
          cachedProducts.map<ProductModel>((e) {
        return ProductModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      loadedFromCache = true;
      lastCacheLoad = DateTime.now();

      notifyListeners();
    }
  }

  // ================= CLEAR CACHE =================
  Future<void> clearLocalCache() async {
    await _cacheService.clearProducts();

    products.clear();

    loadedFromCache = false;
    loadedFromServer = false;

    lastCacheLoad = null;
    lastServerFetch = null;

    notifyListeners();
  }
}