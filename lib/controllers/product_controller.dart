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

  Future<void> fetchProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      // Load local cache first
      final cachedProducts = _cacheService.getProducts();

      if (cachedProducts.isNotEmpty) {
        products = cachedProducts
            .map<ProductModel>(
              (e) => ProductModel.fromMap(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();

        notifyListeners();
      }

      // Get local latest update time
      DateTime localLatest = DateTime(2000);

      if (products.isNotEmpty) {
        localLatest = products
            .map((e) => e.updatedAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
      }

      // Read metadata doc
      final metaDoc = await _firestore
          .collection("app_meta")
          .doc("products")
          .get();

      final serverLastUpdated =
          DateTime.parse(metaDoc["lastUpdated"]);

      // If server has newer data
      if (serverLastUpdated.isAfter(localLatest)) {
        QuerySnapshot snapshot;

        if (products.isEmpty) {
          // First time → fetch all
          snapshot = await _firestore.collection("products").get();
        } else {
          // Fetch only updated/new products
          snapshot = await _firestore
              .collection("products")
              .where(
                "updatedAt",
                isGreaterThan: localLatest.toIso8601String(),
              )
              .get();
        }

        final newProducts = snapshot.docs.map((doc) {
          return ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
          );
        }).toList();

        // Merge into local list
        for (var newProduct in newProducts) {
          final index =
              products.indexWhere((p) => p.id == newProduct.id);

          if (index != -1) {
            products[index] = newProduct;
          } else {
            products.add(newProduct);
          }
        }

        // Save updated cache
        await _cacheService.saveProducts(
          products.map((e) => e.toMap()).toList(),
        );
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}