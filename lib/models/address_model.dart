import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;

  final String fullName;

  final String phone;

  final String house;

  final String area;

  final String city;

  final String state;

  final String pincode;

  final String country;

  final bool isDefault;

  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.house,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
  });

  // Hive

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "house": house,
      "area": area,
      "city": city,
      "state": state,
      "pincode": pincode,
      "country": country,
      "isDefault": isDefault,
      "createdAt":
          createdAt.toIso8601String(),
    };
  }

  // Firestore

  Map<String, dynamic> toFirestoreMap() {
    return {
      "id": id,
      "fullName": fullName,
      "phone": phone,
      "house": house,
      "area": area,
      "city": city,
      "state": state,
      "pincode": pincode,
      "country": country,
      "isDefault": isDefault,
      "createdAt":
          Timestamp.fromDate(createdAt),
    };
  }

  factory AddressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AddressModel(
      id: map["id"] ?? "",
      fullName: map["fullName"] ?? "",
      phone: map["phone"] ?? "",
      house: map["house"] ?? "",
      area: map["area"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      pincode: map["pincode"] ?? "",
      country: map["country"] ?? "",
      isDefault:
          map["isDefault"] ?? false,
      createdAt:
          map["createdAt"] is Timestamp
              ? (map["createdAt"]
                      as Timestamp)
                  .toDate()
              : DateTime.parse(
                  map["createdAt"],
                ),
    );
  }

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? house,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName:
          fullName ?? this.fullName,
      phone: phone ?? this.phone,
      house: house ?? this.house,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode:
          pincode ?? this.pincode,
      country:
          country ?? this.country,
      isDefault:
          isDefault ?? this.isDefault,
      createdAt:
          createdAt ?? this.createdAt,
    );
  }

  String toJson() =>
      jsonEncode(toMap());

  factory AddressModel.fromJson(
    String source,
  ) =>
      AddressModel.fromMap(
        jsonDecode(source),
      );
}