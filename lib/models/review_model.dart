import 'dart:convert';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final List<String> images;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.images,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "productId": productId,
      "userId": userId,
      "userName": userName,
      "comment": comment,
      "rating": rating,
      "images": images,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReviewModel(
      id: map["id"],
      productId: map["productId"],
      userId: map["userId"],
      userName: map["userName"],
      comment: map["comment"],
      rating: (map["rating"]).toDouble(),
      images: List<String>.from(map["images"]),
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ReviewModel.fromJson(String source) =>
      ReviewModel.fromMap(jsonDecode(source));
}