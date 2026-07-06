import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "createdAt":
          createdAt.toIso8601String(),
      "updatedAt":
          updatedAt.toIso8601String(),
    };
  }

  // ================= FROM MAP =================
  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      role: map["role"] ?? "user",

      createdAt:
          map["createdAt"] != null
              ? DateTime.parse(
                  map["createdAt"],
                )
              : DateTime.now(),

      updatedAt:
          map["updatedAt"] != null
              ? DateTime.parse(
                  map["updatedAt"],
                )
              : DateTime.now(),
    );
  }

  // ================= COPY WITH =================
  UserModel copyWith({
    String? name,
    String? phone,
    String? address,
    String? role,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // ================= JSON =================
  String toJson() =>
      jsonEncode(toMap());

  factory UserModel.fromJson(
    String source,
  ) {
    return UserModel.fromMap(
      jsonDecode(source),
    );
  }
}