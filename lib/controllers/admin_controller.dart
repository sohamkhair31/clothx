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

  // ================= CACHE LOAD =================
  void loadAdminProductsFromCache() {
    final cachedProducts =
        _cacheService.productBox.get(
      "admin_products",
      defaultValue: [],
    );

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

      final localMeta =
          _cacheService.productBox.get(
        "admin_products_meta",
      );

      final serverMeta =
          await _adminRepo.getAdminProductsMeta();

      if (localMeta == serverMeta) {
        print(
          "Admin products unchanged. Using cache.",
        );

        isLoading = false;
        notifyListeners();
        return;
      }

      adminProducts =
          await _adminRepo.getAllProducts();

      await _saveAdminCache();

      await _cacheService.productBox.put(
        "admin_products_meta",
        serverMeta,
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

      List<String> imageUrls = [];

      for (var image in imageFiles) {
        final originalBytes =
            await image.readAsBytes();

        final compressedBytes =
            await FlutterImageCompress.compressWithList(
          originalBytes,
          format: CompressFormat.webp,
          quality: 65,
          minWidth: 1200,
          minHeight: 1200,
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

      final now = DateTime.now();

      final product = ProductModel(
        id: now.millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: description.trim(),
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

      await _adminRepo.addProduct(product);

      adminProducts.insert(0, product);

      await _saveAdminCache();

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

      await _saveAdminCache();

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ================= DELETE PRODUCT =================
  Future<bool> deleteProduct(
    String productId,
  ) async {
    try {
      await _adminRepo.deleteProduct(
        productId,
      );

      adminProducts.removeWhere(
        (p) => p.id == productId,
      );

      await _saveAdminCache();

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

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

      await _saveAdminCache();

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

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

      await _saveAdminCache();

      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  // ================= CACHE SAVE =================
  Future<void> _saveAdminCache() async {
    await _cacheService.productBox.put(
      "admin_products",
      adminProducts
          .map((e) => e.toMap())
          .toList(),
    );
  }

  // ================= STOCK HELPERS =================
  List<ProductModel> getLowStockProducts() {
    return adminProducts
        .where((p) => p.stock <= 5)
        .toList();
  }

  List<ProductModel> getOutOfStockProducts() {
    return adminProducts
        .where((p) => p.stock == 0)
        .toList();
  }
}