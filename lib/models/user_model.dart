import 'dart:convert';
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "role": role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      address: map["address"] ?? "",
      role: map["role"] ?? ""
    );
  }
  UserModel copyWith({
  String? name,
  String? phone,
  String? address,
}) {
  return UserModel(
    uid: uid,
    name: name ?? this.name,
    email: email,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    role: role,
  );
}

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));
}