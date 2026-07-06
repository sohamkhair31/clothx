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

Future<List<ProductModel>> searchProducts(
  String query, {
  String? gender,
}) async {
  print("========== REPO SEARCH ==========");

  Query<Map<String, dynamic>> firestoreQuery = _firestore
      .collection("products")
      .where("isActive", isEqualTo: true);

  if (gender != null) {
    firestoreQuery = firestoreQuery.where(
      "gender",
      isEqualTo: gender,
    );
  }

  final snapshot = await firestoreQuery.get();

  print("Firestore docs : ${snapshot.docs.length}");

  final products = snapshot.docs
      .map((e) => ProductModel.fromMap(e.data()))
      .toList();

  for (final p in products) {
    print(
      "Product: ${p.name} | gender=${p.gender} | category=${p.category}",
    );
  }

  final q = query
      .toLowerCase()
      .replaceAll("-", "")
      .replaceAll(" ", "");

  final result = products.where((product) {
    final name = product.name
        .toLowerCase()
        .replaceAll("-", "")
        .replaceAll(" ", "");

    return name.contains(q);
  }).toList();

  print("Matched : ${result.length}");
  print("===============================");

  return result;
}
}