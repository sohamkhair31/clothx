
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clothx/core/services/image/cloudinary_service.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../repositories/admin_repo.dart';

class AdminController extends ChangeNotifier {
  final AdminRepo _adminRepo = AdminRepo();
  final CloudinaryService _cloudinaryService =
      CloudinaryService();
int get totalProducts => adminProducts.length;

int get activeProducts =>
    adminProducts.where((p) => p.isActive).length;

int get inactiveProducts =>
    adminProducts.where((p) => !p.isActive).length;
  List<ProductModel> adminProducts = [];

  bool isLoading = false;
  String? errorMessage;

  // Fetch all admin products
  Future<void> fetchAdminProducts() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

adminProducts.clear();

adminProducts =
    await _adminRepo.getAllProducts();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

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

    // Validate inputs first
    if (name.trim().isEmpty ||
        description.trim().isEmpty ||
        price <= 0 ||
        stock < 0 ||
        imageFiles.isEmpty ||
        sizes.isEmpty) {
      throw Exception("Invalid product data");
    }

    List<String> imageUrls = [];

    // Upload images one by one
    for (var image in imageFiles) {
      final originalBytes = await image.readAsBytes();

      print("Uploading: ${image.name}");
      print("Original size: ${originalBytes.length}");

      // Compress image
      final compressedBytes =
          await FlutterImageCompress.compressWithList(
        originalBytes,
        format: CompressFormat.webp,
        quality: 75,
      );

      print("Compressed size: ${compressedBytes.length}");

      // Upload to Cloudinary
      final uploadedUrl =
          await _cloudinaryService.uploadImage(
        imageBytes: compressedBytes,
        fileName: image.name,
        gender: gender,
        category: category,
      );

      if (uploadedUrl != null) {
        imageUrls.add(uploadedUrl);
        print("Uploaded: $uploadedUrl");
      }
    }

    // Check upload success
    if (imageUrls.length != imageFiles.length) {
      throw Exception("Some images failed to upload");
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

    // Save product (repo already updates app_meta)
    await _adminRepo.addProduct(product);

    // Update local state
    adminProducts.add(product);

    isLoading = false;
    notifyListeners();

    return true;
  } catch (e) {
    errorMessage = e.toString();

    print("Add Product Error: $e");

    isLoading = false;
    notifyListeners();

    return false;
  }
}
  // Update product
  Future<bool> updateProduct(ProductModel product) async {
    try {
      isLoading = true;
      errorMessage = null;
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
        isActive: product.isActive,
      );

      await _adminRepo.updateProduct(updatedProduct);

      final index = adminProducts.indexWhere(
        (p) => p.id == product.id,
      );

      if (index != -1) {
        adminProducts[index] = updatedProduct;
      }

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

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminRepo.deleteProduct(productId);

      adminProducts.removeWhere(
        (p) => p.id == productId,
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

  // Update stock
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

      final index = adminProducts.indexWhere(
        (p) => p.id == productId,
      );

      if (index != -1) {
        final product = adminProducts[index];

        adminProducts[index] = ProductModel(
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
          isActive: product.isActive,
        );
      }

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

  // Toggle product active/inactive
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

      final index = adminProducts.indexWhere(
        (p) => p.id == productId,
      );

      if (index != -1) {
        final product = adminProducts[index];

        adminProducts[index] = ProductModel(
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
          isActive: isActive,
        );
      }

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

  // Low stock products
  List<ProductModel> getLowStockProducts() {
    return adminProducts.where((p) {
      return p.stock <= 5;
    }).toList();
  }

  // Out of stock products
  List<ProductModel> getOutOfStockProducts() {
    return adminProducts.where((p) {
      return p.stock == 0;
    }).toList();
  }
}