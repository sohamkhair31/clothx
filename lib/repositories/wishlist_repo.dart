import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_model.dart';

class WishlistRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _wishlistCol(String userId) =>
      _firestore.collection("users").doc(userId).collection("wishlist");

  DocumentReference<Map<String, dynamic>> _metaDoc(String userId) => _firestore
      .collection("users")
      .doc(userId)
      .collection("meta")
      .doc("wishlist");

  // ================= FETCH WISHLIST =================
  Future<List<WishlistModel>> fetchWishlist(String userId) async {
    final snapshot = await _wishlistCol(userId)
        .orderBy("addedAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WishlistModel.fromMap(doc.data()))
        .toList();
  }

  // ================= WISHLIST META =================
  Future<String> getWishlistMeta(String userId) async {
    final doc = await _metaDoc(userId).get();

    if (!doc.exists || doc.data()?["lastUpdated"] == null) return "";

    final timestamp = doc["lastUpdated"] as Timestamp;
    return timestamp.toDate().toIso8601String();
  }

  // ================= ADD =================
  Future<void> addToWishlist(String userId, String productId) async {
    final now = Timestamp.now();
    final batch = _firestore.batch();

    batch.set(_wishlistCol(userId).doc(productId), {
      "productId": productId,
      "addedAt": now,
    });

    batch.set(
      _metaDoc(userId),
      {"lastUpdated": now},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // ================= REMOVE =================
  Future<void> removeFromWishlist(String userId, String productId) async {
    final now = Timestamp.now();
    final batch = _firestore.batch();

    batch.delete(_wishlistCol(userId).doc(productId));

    batch.set(
      _metaDoc(userId),
      {"lastUpdated": now},
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}