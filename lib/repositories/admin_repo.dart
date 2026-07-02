import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class AdminRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= ADD PRODUCT =================
  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection("products")
        .doc(product.id)
        .set(product.toFirestoreMap());

    await updateProductsMeta();
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

    await updateProductsMeta();
  }

  // ================= DELETE PRODUCT =================
  Future<void> deleteProduct(
    String productId,
  ) async {
    await _firestore
        .collection("products")
        .doc(productId)
        .delete();

    await updateProductsMeta();
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

    await updateProductsMeta();
  }

  // ================= TOGGLE STATUS =================
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

    await updateProductsMeta();
  }

  // ================= META UPDATE =================
  Future<void> updateProductsMeta() async {
    await _firestore
        .collection("app_meta")
        .doc("products")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= FETCH ADMIN PRODUCTS =================
  Future<List<ProductModel>>
      getAllProducts() async {
    final snapshot =
        await _firestore
            .collection("products")
            .get();

    final products =
        snapshot.docs.map((doc) {
      return ProductModel.fromMap(
        doc.data(),
      );
    }).toList();

    // Sort manually (safer than Firestore orderBy)
    products.sort(
      (a, b) =>
          b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    return products;
  }
}