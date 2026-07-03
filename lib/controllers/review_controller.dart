import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../models/review_model.dart';
import '../repositories/review_repo.dart';
import '../core/services/cache/cache_service.dart';
import '../core/services/image/cloudinary_service.dart';

class ReviewController extends ChangeNotifier {
  final ReviewRepo _repo = ReviewRepo();
  final CacheService _cache = CacheService();
  final CloudinaryService _cloudinary =
      CloudinaryService();

  List<ReviewModel> reviews = [];

  bool isLoading = false;
  String? errorMessage;

  static const int reviewLimit = 10;

  // ================= FETCH REVIEWS =================
  Future<void> fetchReviews(
    String productId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // STEP 1: LOAD CACHE FIRST
      final cached =
          _cache.getReviews(productId);

      if (cached.isNotEmpty) {
        reviews =
            cached.map<ReviewModel>((e) {
          return ReviewModel.fromMap(
            Map<String, dynamic>.from(e),
          );
        }).toList();

        notifyListeners();
      }

      // STEP 2: CHECK LOCAL META
      final localMeta =
          _cache.getReviewMeta(productId);

      // STEP 3: SERVER META
      final serverMeta =
          await _repo.getReviewMeta(
        productId,
      );

      // STEP 4: IF SAME SKIP FETCH
      if (localMeta == serverMeta) {
        print(
          "Reviews unchanged. Using cache.",
        );

        isLoading = false;
        notifyListeners();
        return;
      }

      // STEP 5: FETCH LIMITED REVIEWS
      final serverReviews =
          await _repo.fetchReviews(
        productId,
        limit: reviewLimit,
      );

      reviews = serverReviews;

      // STEP 6: UPDATE CACHE
      await _cache.saveReviews(
        productId,
        reviews.map((e) => e.toMap()).toList(),
      );

      await _cache.saveReviewMeta(
        productId,
        serverMeta,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print("Review fetch error: $e");

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD REVIEW =================
  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
    required List<XFile> imageFiles,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      List<String> imageUrls = [];

      for (var image in imageFiles) {
        final originalBytes =
            await image.readAsBytes();

        final compressedBytes =
            await FlutterImageCompress
                .compressWithList(
          originalBytes,
          format: CompressFormat.webp,
          quality: 75,
        );

        final url =
            await _cloudinary
                .uploadReviewImage(
          imageBytes: compressedBytes,
          fileName: image.name,
          productId: productId,
        );

        if (url != null) {
          imageUrls.add(url);
        }
      }

      final review = ReviewModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        productId: productId,
        userId: userId,
        userName: userName,
        comment: comment,
        rating: rating,
        images: imageUrls,
        createdAt: DateTime.now(),
      );

      await _repo.addReview(review);

      // Add local instantly
      reviews.insert(0, review);

      // Update cache
      await _cache.saveReviews(
        productId,
        reviews.map((e) => e.toMap()).toList(),
      );

      // Update review meta
      await _cache.saveReviewMeta(
        productId,
        DateTime.now().toIso8601String(),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      print("Add review error: $e");

      isLoading = false;
      notifyListeners();
    }
  }
}