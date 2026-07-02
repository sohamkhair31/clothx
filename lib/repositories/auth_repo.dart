import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthRepo {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ================= SIGNUP =================
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final credential =
        await _auth
            .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      address: address,
      role: "user",
    );

    await _firestore
        .collection("users")
        .doc(user.uid)
        .set(user.toMap());
  }

  // ================= LOGIN =================
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= USER DATA =================
  Future<UserModel?> getUserData(
    String uid,
  ) async {
    final doc =
        await _firestore
            .collection("users")
            .doc(uid)
            .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(
      doc.data()!,
    );
  }

  // ================= ADMIN CHECK =================
  Future<bool> isAdmin(
    String uid,
  ) async {
    final user =
        await getUserData(uid);

    if (user == null) {
      return false;
    }

    return user.role == "admin";
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateUser({
  required String uid,
  required String name,
  required String phone,
  required String address,
}) async {
  await _firestore
      .collection("users")
      .doc(uid)
      .update({
    "name": name,
    "phone": phone,
    "address": address,
  });
}
}