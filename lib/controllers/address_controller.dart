import 'package:flutter/material.dart';

import '../core/services/cache/cache_service.dart';
import '../models/address_model.dart';
import '../repositories/address_repo.dart';

class AddressController extends ChangeNotifier {
  final AddressRepo _addressRepo = AddressRepo();
  final CacheService _cacheService = CacheService();

  List<AddressModel> addresses = [];

  bool isLoading = false;
  String? errorMessage;

  static const int addressLimit = 10;

  // ================= LOAD CACHE =================

  void loadAddressesFromCache(
    String userId,
  ) {
    final cached =
        _cacheService.addressBox.get(
      "addresses_$userId",
      defaultValue: [],
    );

    if (cached.isNotEmpty) {
      addresses =
          cached.map<AddressModel>((e) {
        return AddressModel.fromMap(
          Map<String, dynamic>.from(e),
        );
      }).toList();

      notifyListeners();
    }
  }

  // ================= FETCH =================

  Future<void> fetchAddresses(
    String userId,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;

      if (addresses.isEmpty) {
        notifyListeners();
      }

      final localMeta =
          _cacheService.addressBox.get(
        "addresses_meta_$userId",
      );

      final serverMeta =
          await _addressRepo.getAddressMeta(
        userId,
      );

      if (localMeta == serverMeta &&
          addresses.isNotEmpty) {
        isLoading = false;
        notifyListeners();
        return;
      }

      addresses =
          await _addressRepo.fetchAddresses(
        userId: userId,
        limit: addressLimit,
      );

      await _cacheService.addressBox.put(
        "addresses_$userId",
        addresses
            .map((e) => e.toMap())
            .toList(),
      );

      await _cacheService.addressBox.put(
        "addresses_meta_$userId",
        serverMeta,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= ADD =================

  Future<bool> addAddress({
    required String userId,
    required AddressModel address,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _addressRepo.addAddress(
        userId: userId,
        address: address,
      );

      await fetchAddresses(userId);

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= UPDATE =================

  Future<bool> updateAddress({
    required String userId,
    required AddressModel address,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _addressRepo.updateAddress(
        userId: userId,
        address: address,
      );

      await fetchAddresses(userId);

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= DELETE =================

  Future<bool> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _addressRepo.deleteAddress(
        userId: userId,
        addressId: addressId,
      );

      await fetchAddresses(userId);

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= DEFAULT =================

  Future<bool> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _addressRepo.setDefaultAddress(
        userId: userId,
        addressId: addressId,
      );

      await fetchAddresses(userId);

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= GET DEFAULT =================

  AddressModel? get defaultAddress {
    try {
      return addresses.firstWhere(
        (e) => e.isDefault,
      );
    } catch (_) {
      return null;
    }
  }

  // ================= CLEAR =================

  Future<void> clearCache(
    String userId,
  ) async {
    await _cacheService.addressBox.delete(
      "addresses_$userId",
    );

    await _cacheService.addressBox.delete(
      "addresses_meta_$userId",
    );

    addresses.clear();

    notifyListeners();
  }
}