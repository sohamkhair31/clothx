import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../core/services/cache/cache_service.dart';

class AdminController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService = CacheService();

  bool isLoading = false;
  String? errorMessage;

  // Add Product
  Future<bool> addProduct(ProductModel product) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore
          .collection("products")
          .doc(product.id)
          .set(product.toMap());

      // Update local cache
      List<ProductModel> cachedProducts = _getCachedProducts();
      cachedProducts.add(product);

      await _saveProductsToCache(cachedProducts);

      await _updateMeta();

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      isLoading = true;
      notifyListeners();

      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        images: product.images,
        sizes: product.sizes,
        stock: product.stock,
        gender: product.gender,
        category: product.category,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection("products")
          .doc(product.id)
          .update(updatedProduct.toMap());

      // Update local cache
      List<ProductModel> cachedProducts = _getCachedProducts();

      final index =
          cachedProducts.indexWhere((p) => p.id == product.id);

      if (index != -1) {
        cachedProducts[index] = updatedProduct;
      }

      await _saveProductsToCache(cachedProducts);

      await _updateMeta();

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete Product
  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore
          .collection("products")
          .doc(productId)
          .delete();

      // Remove from local cache
      List<ProductModel> cachedProducts = _getCachedProducts();
      cachedProducts.removeWhere((p) => p.id == productId);

      await _saveProductsToCache(cachedProducts);

      await _updateMeta();

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Stock
  Future<bool> updateStock({
    required String productId,
    required int newStock,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore
          .collection("products")
          .doc(productId)
          .update({
        "stock": newStock,
        "updatedAt": DateTime.now().toIso8601String(),
      });

      List<ProductModel> cachedProducts = _getCachedProducts();

      final index =
          cachedProducts.indexWhere((p) => p.id == productId);

      if (index != -1) {
        final product = cachedProducts[index];

        cachedProducts[index] = ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          images: product.images,
          sizes: product.sizes,
          stock: newStock,
          gender: product.gender,
          category: product.category,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      await _saveProductsToCache(cachedProducts);

      await _updateMeta();

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helpers

  List<ProductModel> _getCachedProducts() {
    final cached = _cacheService.getProducts();

    return cached.map<ProductModel>((e) {
      return ProductModel.fromMap(
        Map<String, dynamic>.from(e),
      );
    }).toList();
  }

  Future<void> _saveProductsToCache(
    List<ProductModel> products,
  ) async {
    await _cacheService.saveProducts(
      products.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> _updateMeta() async {
    await _firestore.collection("app_meta").doc("products").set({
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }
}