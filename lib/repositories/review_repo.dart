import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int reviewLimit = 25;

  // ================= ADD REVIEW =================

  Future<void> addReview(
    ReviewModel review,
  ) async {
    final reviewRef = _firestore
        .collection("products")
        .doc(review.productId)
        .collection("reviews")
        .doc(review.id);

    final metaRef = _firestore
        .collection("app_meta")
        .doc("reviews_${review.productId}");

    await _firestore.runTransaction(
      (transaction) async {
        transaction.set(
          reviewRef,
          review.toFirestoreMap(),
        );

        transaction.set(metaRef, {
          "lastUpdated":
              FieldValue.serverTimestamp(),
        });
      },
    );
  }

  // ================= FETCH REVIEWS =================

  Future<List<ReviewModel>> fetchReviews(
    String productId, {
    int limit = reviewLimit,
  }) async {
    final snapshot = await _firestore
        .collection("products")
        .doc(productId)
        .collection("reviews")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              ReviewModel.fromMap(doc.data()),
        )
        .toList();
  }

  // ================= REVIEW META =================

  Future<String> getReviewMeta(
    String productId,
  ) async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("reviews_$productId")
        .get();

    if (!doc.exists) return "";

    final timestamp =
        doc["lastUpdated"] as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }
}