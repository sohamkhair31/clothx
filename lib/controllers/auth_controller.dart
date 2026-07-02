import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../repositories/auth_repo.dart';

class AuthController extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();

  bool isLoading = false;
  String? errorMessage;

  User? currentUser = FirebaseAuth.instance.currentUser;

  UserModel? userData;

  UserModel? get currentUserData => userData;

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = await _authRepo.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      currentUser = FirebaseAuth.instance.currentUser;

      // fetch fresh user data
      userData = await _authRepo.getUserData(user.uid);

      isLoading = false;
      notifyListeners();

      return user.uid.isNotEmpty;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      currentUser = await _authRepo.login(
        email: email,
        password: password,
      );

      if (currentUser != null) {
        userData = await _authRepo.getUserData(
          currentUser!.uid,
        );
      }

      isLoading = false;
      notifyListeners();

      return currentUser != null;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;

    userData = await _authRepo.getUserData(
      currentUser!.uid,
    );

    notifyListeners();

    return userData;
  }

  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    return await _authRepo.isAdmin(currentUser!.uid);
  }

  Future<void> logout() async {
    await _authRepo.logout();

    currentUser = null;
    userData = null;

    notifyListeners();
  }
}