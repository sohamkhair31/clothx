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

    final now = DateTime.now();

    final user = UserModel(
      uid: credential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      address: address.trim(),
      role: "user",
      createdAt: now,
      updatedAt: now,
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
      email: email.trim(),
      password: password,
    );
  }

  // ================= GET USER DATA =================
  Future<UserModel?> getUserData(
    String uid,
  ) async {
    final doc =
        await _firestore
            .collection("users")
            .doc(uid)
            .get(
              const GetOptions(
                source: Source.serverAndCache,
              ),
            );

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromMap(
      doc.data()!,
    );
  }

  // ================= CHECK ADMIN =================
  Future<bool> isAdmin(
    String uid,
  ) async {
    final doc =
        await _firestore
            .collection("users")
            .doc(uid)
            .get(
              const GetOptions(
                source: Source.serverAndCache,
              ),
            );

    if (!doc.exists) {
      return false;
    }

    final role =
        doc.data()?["role"] ?? "user";

    return role == "admin";
  }

  // ================= UPDATE USER =================
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
      "name": name.trim(),
      "phone": phone.trim(),
      "address": address.trim(),
      "updatedAt":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }
}