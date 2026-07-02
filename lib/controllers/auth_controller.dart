import 'package:clothx/models/user_model.dart';
import 'package:clothx/repositories/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();

  bool isLoading = false;
  String? errorMessage;

  User? currentUser =
      FirebaseAuth.instance.currentUser;

  UserModel? currentUserData;

  // Listen auth changes
  AuthController() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) async {
      currentUser = user;

      if (user != null) {
        currentUserData =
            await _authRepo.getUserData(
          user.uid,
        );
      } else {
        currentUserData = null;
      }

      notifyListeners();
    });
  }

  // ================= SIGNUP =================
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

      await _authRepo.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      currentUser =
          FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        currentUserData =
            await _authRepo.getUserData(
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

  // ================= LOGIN =================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

final credential =
    await _authRepo.login(
  email: email,
  password: password,
);

currentUser = credential.user;

      if (currentUser != null) {
        currentUserData =
            await _authRepo.getUserData(
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

  // ================= GET USER DATA =================
  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;

    try {
      isLoading = true;
      notifyListeners();

      currentUserData =
          await _authRepo.getUserData(
        currentUser!.uid,
      );

      isLoading = false;
      notifyListeners();

      return currentUserData;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ================= CHECK ADMIN =================
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;

    return await _authRepo.isAdmin(
      currentUser!.uid,
    );
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _authRepo.logout();

    currentUser = null;
    currentUserData = null;

    notifyListeners();
  }
  Future<bool> updateProfile({
  required String name,
  required String phone,
  required String address,
}) async {
  try {

    if (currentUser == null) return false;
if (currentUserData != null &&
    currentUserData!.name == name &&
    currentUserData!.phone == phone &&
    currentUserData!.address == address) {
isLoading = false;
notifyListeners();
return true;
}
    isLoading = true;
    notifyListeners();

    await _authRepo.updateUser(
      uid: currentUser!.uid,
      name: name,
      phone: phone,
      address: address,
    );

    currentUserData =
        currentUserData?.copyWith(
      name: name,
      phone: phone,
      address: address,
    );

    isLoading = false;
    notifyListeners();

    return true;
  } catch (e) {
    errorMessage = e.toString();

    isLoading = false;
    notifyListeners();

    return false;
  }
}
}