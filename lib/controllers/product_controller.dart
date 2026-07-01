import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../core/services/cache/cache_service.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService = CacheService();

  List<ProductModel> products = [];
  bool isLoading = false;
  String? errorMessage;

  // Main fetch logic
  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Step 1: Load cache first
      final cachedProducts = _cacheService.getProducts();

      if (cachedProducts.isNotEmpty) {
        products = cachedProducts.map<ProductModel>((e) {
          return ProductModel.fromMap(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        print("Loaded from cache: ${products.length}");

        notifyListeners();
      }

      // Step 2: Find latest local update
      DateTime localLatest = DateTime(2000);

      if (products.isNotEmpty) {
        localLatest = products
            .map((e) => e.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      print("Local latest: $localLatest");

      // Step 3: Check server metadata
      final metaDoc = await _firestore
          .collection("app_meta")
          .doc("products")
          .get();

      if (!metaDoc.exists) {
        print("No metadata found.");
        isLoading = false;
        notifyListeners();
        return;
      }

      final serverLastUpdated =
          DateTime.parse(metaDoc["lastUpdated"]);

      print("Server latest: $serverLastUpdated");

      // Step 4: Fetch only if server has updates
      if (serverLastUpdated.isAfter(localLatest)) {
        QuerySnapshot snapshot;

        if (products.isEmpty) {
          // First time fetch all
          snapshot = await _firestore
              .collection("products")
              .get();

          print("Fetching all products...");
        } else {
          // Fetch only updated products
          snapshot = await _firestore
              .collection("products")
              .where(
                "updatedAt",
                isGreaterThan: localLatest.toIso8601String(),
              )
              .get();

          print("Fetching updated products only...");
        }

        final newProducts = snapshot.docs.map((doc) {
          return ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
        }).toList();

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

        // Save to cache
        await _cacheService.saveProducts(
          products.map((e) => e.toMap()).toList(),
        );

        print("Cache updated.");
      } else {
        print("No new updates. Using cache.");
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

  // Load only from Hive
  void loadFromCacheOnly() {
    final cachedProducts = _cacheService.getProducts();

    products = cachedProducts.map<ProductModel>((e) {
      return ProductModel.fromMap(
        Map<String, dynamic>.from(e),
      );
    }).toList();

    print("Loaded only from cache: ${products.length}");

    notifyListeners();
  }

  // Clear product cache
  Future<void> clearLocalCache() async {
    await _cacheService.clearProducts();

    products.clear();

    print("Product cache cleared.");

    notifyListeners();
  }
}