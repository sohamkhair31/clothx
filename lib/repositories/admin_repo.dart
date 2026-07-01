import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add product
  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toMap());

    await _updateMeta();
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .update(product.toMap());

    await _updateMeta();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .delete();

    await _updateMeta();
  }

  // Update stock
  Future<void> updateStock({
    required String productId,
    required int newStock,
  }) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .update({
      "stock": newStock,
      "updatedAt": DateTime.now().toIso8601String(),
    });

    await _updateMeta();
  }

  // Update metadata for user sync
  Future<void> _updateMeta() async {
    await _firestore
        .collection("app_meta")
        .doc("products")
        .set({
      "lastUpdated": DateTime.now().toIso8601String(),
    });
  }
  // Get all products
Future<List<ProductModel>> getAllProducts() async {
  final snapshot =
      await _firestore.collection("products").get();

  return snapshot.docs.map((doc) {
    return ProductModel.fromMap(
      doc.data(),
    );
  }).toList();
}

// Toggle active
Future<void> toggleProductStatus({
  required String productId,
  required bool isActive,
}) async {
  await _firestore
      .collection("products")
      .doc(productId)
      .update({
    "isActive": isActive,
    "updatedAt": DateTime.now().toIso8601String(),
  });

  await _updateMeta();
}
}