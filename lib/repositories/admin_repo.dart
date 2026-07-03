import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class AdminRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int adminLimit = 50;

  // ================= ADD PRODUCT =================
  Future<void> addProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toFirestoreMap());

    await _updateProductsMeta();
  }

  // ================= UPDATE PRODUCT =================
  Future<void> updateProduct(
    ProductModel product,
  ) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .update({
      ...product.toFirestoreMap(),
      "updatedAt":
          FieldValue.serverTimestamp(),
    });

    await _updateProductsMeta();
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(
    String productId,
  ) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .delete();

    await _updateProductsMeta();
  }

  // ================= UPDATE STOCK =================
  Future<void> updateStock({
    required String productId,
    required int newStock,
  }) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .update({
      "stock": newStock,
      "updatedAt":
          FieldValue.serverTimestamp(),
    });

    await _updateProductsMeta();
  }

  // ================= TOGGLE PRODUCT =================
  Future<void> toggleProductStatus({
    required String productId,
    required bool isActive,
  }) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .update({
      "isActive": isActive,
      "updatedAt":
          FieldValue.serverTimestamp(),
    });

    await _updateProductsMeta();
  }

  // ================= PRODUCT META =================
  Future<void> _updateProductsMeta() async {
    await _firestore
        .collection("app_meta")
        .doc("products")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });

    // admin specific meta
    await _firestore
        .collection("app_meta")
        .doc("admin_products")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= GET ADMIN META =================
  Future<String> getAdminProductsMeta() async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("admin_products")
        .get();

    if (!doc.exists) {
      return "";
    }

    final timestamp =
        doc["lastUpdated"] as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }

  // ================= FETCH PRODUCTS =================
  Future<List<ProductModel>>
      getAllProducts({
    int limit = adminLimit,
  }) async {
    final snapshot =
        await _firestore
            .collection("products")
            .orderBy(
              "createdAt",
              descending: true,
            )
            .limit(limit)
            .get();

    return snapshot.docs.map((doc) {
      return ProductModel.fromMap(
        doc.data(),
      );
    }).toList();
  }
}