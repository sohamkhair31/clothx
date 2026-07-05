import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class ProductRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int productLimit = 100;

  // ================= FETCH PRODUCTS =================

  Future<List<ProductModel>> fetchProducts({
    int limit = productLimit,
  }) async {
    final snapshot = await _firestore
        .collection("products")
        .where("isActive", isEqualTo: true)
        .orderBy(
          "createdAt",
          descending: true,
        )
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  }

  // ================= PRODUCTS META =================

  Future<String> getProductsMeta() async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("products")
        .get();

    if (!doc.exists) return "";

    final timestamp =
        doc["lastUpdated"] as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }
}