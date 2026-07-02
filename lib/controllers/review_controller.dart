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

  Future<void> fetchReviews(
    String productId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Load cache first
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

      // Fetch fresh server data
      final serverReviews =
          await _repo.fetchReviews(productId);

      reviews = serverReviews;

      // Save cache
      await _cache.saveReviews(
        productId,
        reviews.map((e) => e.toMap()).toList(),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

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

      // Insert locally
      reviews.insert(0, review);

      // Update cache
      await _cache.saveReviews(
        productId,
        reviews.map((e) => e.toMap()).toList(),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }
}