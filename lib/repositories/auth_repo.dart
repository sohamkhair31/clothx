import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Signup
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      phone: phone,
      address: address,
    );

    await _firestore.collection("users").doc(user.uid).set(user.toMap());

    return user;
  }

  // Login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  // Get User Data
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection("users").doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }

    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}