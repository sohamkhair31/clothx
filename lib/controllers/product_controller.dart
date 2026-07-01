import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../core/services/cache/cache_service.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final CacheService _cacheService = CacheService();

  bool loadedFromCache = false;
  bool loadedFromServer = false;

  DateTime? lastCacheLoad;
  DateTime? lastServerFetch;

  List<ProductModel> products = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      errorMessage = null;

      loadedFromCache = false;
      loadedFromServer = false;

      notifyListeners();

      // =========================
      // STEP 1: LOAD CACHE
      // =========================
      final cachedProducts =
          _cacheService.getProducts();

      if (cachedProducts.isNotEmpty) {
        products = cachedProducts.map<ProductModel>((e) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        loadedFromCache = true;
        lastCacheLoad = DateTime.now();

        print(
          "Loaded from cache: ${products.length}",
        );
      }

      // =========================
      // STEP 2: LOAD LOCAL META
      // =========================
      final localMetaString =
          _cacheService.getLastMeta();

      Timestamp? localMeta;

      if (localMetaString != null) {
        localMeta = Timestamp.fromDate(
          DateTime.parse(localMetaString),
        );
      }

      print("Local meta: $localMeta");

      // =========================
      // STEP 3: SERVER META
      // =========================
      final metaDoc = await _firestore
          .collection("app_meta")
          .doc("products")
          .get();

      if (!metaDoc.exists) {
        print("No server metadata found.");

        isLoading = false;
        notifyListeners();
        return;
      }

      final rawServerMeta =
          metaDoc["lastUpdated"];

      Timestamp serverMeta;

      if (rawServerMeta is Timestamp) {
        serverMeta = rawServerMeta;
      } else if (rawServerMeta is String) {
        serverMeta = Timestamp.fromDate(
          DateTime.parse(rawServerMeta),
        );
      } else {
        throw Exception(
          "Invalid lastUpdated format",
        );
      }

      print("Server meta: $serverMeta");

      // =========================
      // STEP 4: ONLY FETCH IF SERVER NEWER
      // =========================
      if (localMeta == null ||
          serverMeta.compareTo(localMeta) > 0) {
        QuerySnapshot snapshot;

        // FIRST FETCH
        if (products.isEmpty) {
          snapshot = await _firestore
              .collection("products")
              .where(
                "isActive",
                isEqualTo: true,
              )
              .get();

          print(
            "First fetch: loading all products",
          );
        }

        // INCREMENTAL FETCH
        else {
          final latestProductTime = products
              .map((e) => e.updatedAt)
              .reduce(
                (a, b) =>
                    a.isAfter(b) ? a : b,
              );

          snapshot = await _firestore
              .collection("products")
              .where(
                "updatedAt",
                isGreaterThan:
                    Timestamp.fromDate(
                  latestProductTime,
                ),
              )
              .where(
                "isActive",
                isEqualTo: true,
              )
              .get();

          print(
            "Incremental fetch: loading updated products only",
          );
        }

        final newProducts = snapshot.docs.map((doc) {
          return ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
        }).toList();

        loadedFromServer = true;
        lastServerFetch = DateTime.now();

        print(
          "Fetched from server: ${newProducts.length}",
        );

        // MERGE PRODUCTS
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

        // SAVE PRODUCTS CACHE
        await _cacheService.saveProducts(
          products.map((e) => e.toMap()).toList(),
        );

        // SAVE META CACHE
        await _cacheService.saveLastMeta(
          serverMeta.toDate().toIso8601String(),
        );

        print("Cache updated.");
      } else {
        print(
          "No changes. Using cache only.",
        );
      }

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

  // CACHE ONLY
  void loadFromCacheOnly() {
    final cachedProducts =
        _cacheService.getProducts();

    if (cachedProducts.isNotEmpty) {
      products = cachedProducts.map<ProductModel>((e) {
        return ProductModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      loadedFromCache = true;
      lastCacheLoad = DateTime.now();

      print(
        "Loaded only from cache: ${products.length}",
      );
    }

    notifyListeners();
  }

  // CLEAR CACHE
  Future<void> clearLocalCache() async {
    await _cacheService.clearProducts();

    products.clear();

    loadedFromCache = false;
    loadedFromServer = false;

    lastCacheLoad = null;
    lastServerFetch = null;

    print("Product cache cleared.");

    notifyListeners();
  }
}