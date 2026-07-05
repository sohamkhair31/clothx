import 'package:flutter/material.dart';

import '../core/services/cache/cache_service.dart';
import '../models/product_model.dart';
import '../repositories/product_repo.dart';

class ProductController extends ChangeNotifier {
  final ProductRepo _productRepo = ProductRepo();
  final CacheService _cacheService = CacheService();

  List<ProductModel> products = [];

  bool isLoading = false;
  String? errorMessage;

  static const int productLimit = 100;

  // ================= LOAD CACHE =================

void loadProductsFromCache() {
  print("========== LOAD PRODUCTS FROM CACHE ==========");

  final cachedProducts =
      _cacheService.productBox.get(
    "product_list",
    defaultValue: [],
  );

  print(
    "Raw cache count: ${cachedProducts.length}",
  );

  if (cachedProducts.isNotEmpty) {
    products =
        cachedProducts.map<ProductModel>((e) {
      return ProductModel.fromMap(
        Map<String, dynamic>.from(e),
      );
    }).toList();

    print(
      "Loaded ${products.length} products from cache.",
    );

    if (products.isNotEmpty) {
      print("----- First Product -----");
      print("ID: ${products.first.id}");
      print("Name: ${products.first.name}");
      print("Price: ${products.first.price}");
      print("Category: ${products.first.category}");
      print("Gender: ${products.first.gender}");
      print("Stock: ${products.first.stock}");
      print("Colors: ${products.first.colors.length}");
      if (products.first.colors.isNotEmpty) {
        print(
          "First Image: ${products.first.colors.first.image}",
        );
      }
      print("-------------------------");
    }

    notifyListeners();
  } else {
    print("No cached products found.");
  }

  print("==============================================");
}
  // ================= FETCH PRODUCTS =================

Future<void> fetchProducts() async {
  try {
    isLoading = true;
    errorMessage = null;

    if (products.isEmpty) {
      notifyListeners();
    }

    final localMeta = _cacheService.getLastMeta();

    print("========== PRODUCT FETCH ==========");
    print("Local Meta : $localMeta");

    final serverMeta =
        await _productRepo.getProductsMeta();

    print("Server Meta: $serverMeta");

    if (localMeta == serverMeta &&
        products.isNotEmpty) {
      print(
        "Products unchanged. Using cache (${products.length})",
      );

      isLoading = false;
      notifyListeners();
      return;
    }

    products =
        await _productRepo.fetchProducts(
      limit: productLimit,
    );

    print(
      "Firestore returned ${products.length} products",
    );

    await _cacheService.saveProducts(
      products
          .map((e) => e.toMap())
          .toList(),
    );

    await _cacheService.saveLastMeta(
      serverMeta,
    );

    print("Products saved to Hive");

    isLoading = false;
    notifyListeners();
  } catch (e, s) {
    errorMessage = e.toString();

    print("PRODUCT FETCH ERROR");
    print(e);
    print(s);

    isLoading = false;
    notifyListeners();
  }
}
  // ================= FORCE REFRESH =================

  Future<void> refreshProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      products =
          await _productRepo.fetchProducts(
        limit: productLimit,
      );

      final serverMeta =
          await _productRepo.getProductsMeta();

      await _cacheService.productBox.put(
        "product_list",
        products.map((e) => e.toMap()).toList(),
      );

      await _cacheService.productBox.put(
        "products_meta",
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

  // ================= GETTERS =================

  List<ProductModel> get menProducts =>
      products
          .where((e) => e.gender == "men")
          .toList();

  List<ProductModel> get womenProducts =>
      products
          .where((e) => e.gender == "women")
          .toList();

  List<ProductModel> byCategory(
    String category,
  ) {
    return products
        .where(
          (e) =>
              e.category.toLowerCase() ==
              category.toLowerCase(),
        )
        .toList();
  }
}