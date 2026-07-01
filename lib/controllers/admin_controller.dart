import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../repositories/admin_repo.dart';

class AdminController extends ChangeNotifier {
  final AdminRepo _adminRepo = AdminRepo();
List<ProductModel> adminProducts = [];
  bool isLoading = false;
  String? errorMessage;
Future<void> fetchAdminProducts() async {
  try {
    isLoading = true;
    notifyListeners();

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
Future<bool> toggleProductStatus({
  required String productId,
  required bool isActive,
}) async {
  try {
    isLoading = true;
    notifyListeners();

    await _adminRepo.toggleProductStatus(
      productId: productId,
      isActive: isActive,
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
List<ProductModel> getLowStockProducts() {
  return adminProducts.where((p) {
    return p.stock <= 5;
  }).toList();
}
List<ProductModel> getOutOfStockProducts() {
  return adminProducts.where((p) {
    return p.stock == 0;
  }).toList();
}
  // Add Product
  Future<bool> addProduct(ProductModel product) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _adminRepo.addProduct(product);

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
      errorMessage = null;
      notifyListeners();

      await _adminRepo.deleteProduct(productId);

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
      errorMessage = null;
      notifyListeners();

      await _adminRepo.updateStock(
        productId: productId,
        newStock: newStock,
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
}