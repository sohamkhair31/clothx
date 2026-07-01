import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addReview(
    ReviewModel review,
  ) async {
    await _firestore
        .collection("products")
        .doc(review.productId)
        .collection("reviews")
        .doc(review.id)
        .set(review.toMap());
  }

  Future<List<ReviewModel>> fetchReviews(
    String productId,
  ) async {
    final snapshot = await _firestore
        .collection("products")
        .doc(productId)
        .collection("reviews")
        .get();

    return snapshot.docs.map((doc) {
      return ReviewModel.fromMap(doc.data());
    }).toList();
  }
}