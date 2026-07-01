import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class AdminRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Add product
  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toFirestoreMap());

    await updateProductsMeta();
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .update({
      ...product.toFirestoreMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await updateProductsMeta();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .delete();

    await updateProductsMeta();
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
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await updateProductsMeta();
  }

  // Toggle active/inactive
  Future<void> toggleProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .update({
      "isActive": isActive,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    await updateProductsMeta();
  }

  // Cache invalidation metadata
  Future<void> updateProductsMeta() async {
    await _firestore
        .collection("app_meta")
        .doc("products")
        .set({
      "lastUpdated": FieldValue.serverTimestamp(),
    });
  }

  // Get all products (admin side)
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _firestore
        .collection("products")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data());
    }).toList();
  }
}