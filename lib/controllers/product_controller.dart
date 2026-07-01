import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../core/services/cache/cache_service.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

      // STEP 1: Load cache
      final cachedProducts = _cacheService.getProducts();

      if (cachedProducts.isNotEmpty) {
        products = cachedProducts.map<ProductModel>((e) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        loadedFromCache = true;
        lastCacheLoad = DateTime.now();

        print("Loaded from cache: ${products.length}");
      }

      // STEP 2: Load saved meta
      final localMeta = _cacheService.getLastMeta();

      print("Local meta: $localMeta");

      // STEP 3: Fetch server meta
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

      final serverMeta = metaDoc["lastUpdated"].toString();

      print("Server meta: $serverMeta");

      // STEP 4: Compare meta
      if (localMeta == null || localMeta != serverMeta) {
        QuerySnapshot snapshot;

        if (products.isEmpty) {
          snapshot = await _firestore
              .collection("products")
              .where("isActive", isEqualTo: true)
              .get();

          print("First fetch: loading all products");
        } else {
          snapshot = await _firestore
              .collection("products")
              .where("updatedAt", isGreaterThan: localMeta ?? "")
              .where("isActive", isEqualTo: true)
              .get();

          print("Incremental fetch: loading updates only");
        }

        final newProducts = snapshot.docs.map((doc) {
          return ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
        }).toList();

        loadedFromServer = true;
        lastServerFetch = DateTime.now();

        print("Fetched from server: ${newProducts.length}");

        // Merge products
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

        // Save products
        await _cacheService.saveProducts(
          products.map((e) => e.toMap()).toList(),
        );

        // Save latest meta
        await _cacheService.saveLastMeta(serverMeta);

        print("Cache updated.");
      } else {
        print("No changes. Using cache only.");
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print("ProductController Error: $e");

      isLoading = false;
      notifyListeners();
    }
  }

  void loadFromCacheOnly() {
    final cachedProducts = _cacheService.getProducts();

    if (cachedProducts.isNotEmpty) {
      products = cachedProducts.map<ProductModel>((e) {
        return ProductModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      loadedFromCache = true;
      lastCacheLoad = DateTime.now();

      print("Loaded only from cache: ${products.length}");
    }

    notifyListeners();
  }

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