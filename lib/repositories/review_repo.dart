import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= ADD REVIEW =================
  Future<void> addReview(
    ReviewModel review,
  ) async {
    await _firestore
        .collection("products")
        .doc(review.productId)
        .collection("reviews")
        .doc(review.id)
        .set(review.toMap());

    // Update review meta
    await _firestore
        .collection("app_meta")
        .doc("reviews_${review.productId}")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= FETCH REVIEWS =================
  Future<List<ReviewModel>> fetchReviews(
    String productId, {
    int limit = 10,
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

    return snapshot.docs.map((doc) {
      return ReviewModel.fromMap(
        doc.data(),
      );
    }).toList();
  }

  // ================= GET REVIEW META =================
  Future<String> getReviewMeta(
    String productId,
  ) async {
    final doc = await _firestore
        .collection("app_meta")
        .doc("reviews_$productId")
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
}