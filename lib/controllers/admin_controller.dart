import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clothx/core/services/image/cloudinary_service.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../repositories/admin_repo.dart';
import '../core/services/cache/cache_service.dart';

class AdminController extends ChangeNotifier {
  final AdminRepo _adminRepo = AdminRepo();

  final CloudinaryService _cloudinaryService =
      CloudinaryService();

  final CacheService _cacheService =
      CacheService();

  List<ProductModel> adminProducts = [];

  bool isLoading = false;
  String? errorMessage;

  // ================= COUNTS =================
  int get totalProducts =>
      adminProducts.length;

  int get activeProducts =>
      adminProducts
          .where((p) => p.isActive)
          .length;

  int get inactiveProducts =>
      adminProducts
          .where((p) => !p.isActive)
          .length;

  // ================= LOAD CACHE FIRST =================
  void loadAdminProductsFromCache() {
    final cachedProducts =
        _cacheService.getProducts();

    if (cachedProducts.isNotEmpty) {
      adminProducts =
          cachedProducts.map<ProductModel>((e) {
        return ProductModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      notifyListeners();
    }
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchAdminProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      adminProducts =
          await _adminRepo.getAllProducts();

      // Save cache
      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD PRODUCT =================
  Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required List<XFile> imageFiles,
    required List<String> sizes,
    required int stock,
    required String gender,
    required String category,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      if (name.trim().isEmpty ||
          description.trim().isEmpty ||
          price <= 0 ||
          stock < 0 ||
          imageFiles.isEmpty ||
          sizes.isEmpty) {
        throw Exception(
          "Invalid product data",
        );
      }

      List<String> imageUrls = [];

      for (var image in imageFiles) {
        final originalBytes =
            await image.readAsBytes();

        final compressedBytes =
            await FlutterImageCompress.compressWithList(
          originalBytes,
          format: CompressFormat.webp,
          quality: 75,
        );

        final uploadedUrl =
            await _cloudinaryService.uploadImage(
          imageBytes: compressedBytes,
          fileName: image.name,
          gender: gender,
          category: category,
        );

        if (uploadedUrl != null) {
          imageUrls.add(uploadedUrl);
        }
      }

      if (imageUrls.length !=
          imageFiles.length) {
        throw Exception(
          "Some images failed to upload",
        );
      }

      final now = DateTime.now();

      final product = ProductModel(
        id: now
            .millisecondsSinceEpoch
            .toString(),
        name: name.trim(),
        description:
            description.trim(),
        price: price,
        images: imageUrls,
        sizes: sizes,
        stock: stock,
        gender: gender,
        category: category,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _adminRepo.addProduct(
        product,
      );

      adminProducts.insert(0, product);

      // Update cache
      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

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

  // ================= UPDATE PRODUCT =================
  Future<bool> updateProduct(
    ProductModel product,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final updatedProduct =
          product.copyWith(
        updatedAt: DateTime.now(),
      );

      await _adminRepo.updateProduct(
        updatedProduct,
      );

      final index =
          adminProducts.indexWhere(
        (p) => p.id == product.id,
      );

      if (index != -1) {
        adminProducts[index] =
            updatedProduct;
      }

      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

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

  // ================= DELETE PRODUCT =================
  Future<bool> deleteProduct(
    String productId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminRepo.deleteProduct(
        productId,
      );

      adminProducts.removeWhere(
        (p) => p.id == productId,
      );

      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

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

  // ================= UPDATE STOCK =================
  Future<bool> updateStock({
    required String productId,
    required int newStock,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminRepo.updateStock(
        productId: productId,
        newStock: newStock,
      );

      final index =
          adminProducts.indexWhere(
        (p) => p.id == productId,
      );

      if (index != -1) {
        adminProducts[index] =
            adminProducts[index].copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
      }

      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

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

  // ================= TOGGLE STATUS =================
  Future<bool> toggleProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminRepo.toggleProductStatus(
        productId: productId,
        isActive: isActive,
      );

      final index =
          adminProducts.indexWhere(
        (p) => p.id == productId,
      );

      if (index != -1) {
        adminProducts[index] =
            adminProducts[index].copyWith(
          isActive: isActive,
          updatedAt: DateTime.now(),
        );
      }

      await _cacheService.saveProducts(
        adminProducts
            .map((e) => e.toMap())
            .toList(),
      );

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

  // ================= STOCK HELPERS =================
  List<ProductModel>
      getLowStockProducts() {
    return adminProducts.where((p) {
      return p.stock <= 5;
    }).toList();
  }

  List<ProductModel>
      getOutOfStockProducts() {
    return adminProducts.where((p) {
      return p.stock == 0;
    }).toList();
  }
}