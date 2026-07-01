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

  Future<void> fetchReviews(
    String productId,
  ) async {
    final cached = _cache.getReviews(productId);

    if (cached.isNotEmpty) {
      reviews = cached.map<ReviewModel>((e) {
        return ReviewModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      notifyListeners();
    }

    final serverReviews =
        await _repo.fetchReviews(productId);

    reviews = serverReviews;

    await _cache.saveReviews(
      productId,
      reviews.map((e) => e.toMap()).toList(),
    );

    notifyListeners();
  }

  Future<void> addReview({
    required String productId,
    required String userId,
    required String userName,
    required String comment,
    required double rating,
    required List<XFile> imageFiles,
  }) async {
    List<String> imageUrls = [];

for (var image in imageFiles) {
  // Read original bytes
  final originalBytes = await image.readAsBytes();

  // Compress to WebP directly in memory
  final compressedBytes =
      await FlutterImageCompress.compressWithList(
    originalBytes,
    format: CompressFormat.webp,
    quality: 75,
  );

  // Upload compressed review image
  final url = await _cloudinary.uploadReviewImage(
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

    reviews.insert(0, review);

    await _cache.saveReviews(
      productId,
      reviews.map((e) => e.toMap()).toList(),
    );

    notifyListeners();
  }
}