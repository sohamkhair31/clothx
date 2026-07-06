import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistModel {
  final String productId;
  final DateTime addedAt;

  WishlistModel({
    required this.productId,
    required this.addedAt,
  });

  // Hive cache map
  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "addedAt": addedAt.toIso8601String(),
    };
  }

  // Firestore map
  Map<String, dynamic> toFirestoreMap() {
    return {
      "productId": productId,
      "addedAt": Timestamp.fromDate(addedAt),
    };
  }

  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      productId: map["productId"] ?? "",
      addedAt: map["addedAt"] is Timestamp
          ? (map["addedAt"] as Timestamp).toDate()
          : DateTime.parse(map["addedAt"]),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory WishlistModel.fromJson(String source) =>
      WishlistModel.fromMap(jsonDecode(source));
}