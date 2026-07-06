import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

class AddressRepo {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int addressLimit = 10;

  // ================= ADD ADDRESS =================

  Future<void> addAddress({
    required String userId,
    required AddressModel address,
  }) async {
    await _firestore.runTransaction(
      (transaction) async {
        final addressesRef = _firestore
            .collection("users")
            .doc(userId)
            .collection("addresses");

        // If this address is default,
        // remove default from others.
        if (address.isDefault) {
          final snapshot =
              await addressesRef.get();

          for (final doc in snapshot.docs) {
            transaction.update(
              doc.reference,
              {
                "isDefault": false,
              },
            );
          }
        }

        transaction.set(
          addressesRef.doc(address.id),
          address.toFirestoreMap(),
        );

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("addresses_$userId"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ================= UPDATE ADDRESS =================

  Future<void> updateAddress({
    required String userId,
    required AddressModel address,
  }) async {
    await _firestore.runTransaction(
      (transaction) async {
        final addressesRef = _firestore
            .collection("users")
            .doc(userId)
            .collection("addresses");

        if (address.isDefault) {
          final snapshot =
              await addressesRef.get();

          for (final doc in snapshot.docs) {
            transaction.update(
              doc.reference,
              {
                "isDefault": false,
              },
            );
          }
        }

        transaction.update(
          addressesRef.doc(address.id),
          address.toFirestoreMap(),
        );

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("addresses_$userId"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ================= DELETE =================

  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("addresses")
        .doc(addressId)
        .delete();

    await _firestore
        .collection("app_meta")
        .doc("addresses_$userId")
        .set({
      "lastUpdated":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= SET DEFAULT =================

  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    await _firestore.runTransaction(
      (transaction) async {
        final addressesRef = _firestore
            .collection("users")
            .doc(userId)
            .collection("addresses");

        final snapshot =
            await addressesRef.get();

        for (final doc in snapshot.docs) {
          transaction.update(
            doc.reference,
            {
              "isDefault":
                  doc.id == addressId,
            },
          );
        }

        transaction.set(
          _firestore
              .collection("app_meta")
              .doc("addresses_$userId"),
          {
            "lastUpdated":
                FieldValue.serverTimestamp(),
          },
        );
      },
    );
  }

  // ================= FETCH =================

  Future<List<AddressModel>>
      fetchAddresses({
    required String userId,
    int limit = addressLimit,
  }) async {
    final snapshot =
        await _firestore
            .collection("users")
            .doc(userId)
            .collection("addresses")
            .orderBy("isDefault", descending: true)
.orderBy("createdAt", descending: true)
            .limit(limit)
            .get();

    return snapshot.docs
        .map(
          (doc) => AddressModel.fromMap(
            doc.data(),
          ),
        )
        .toList();
  }

  // ================= META =================

  Future<String> getAddressMeta(
    String userId,
  ) async {
    final doc =
        await _firestore
            .collection("app_meta")
            .doc(
              "addresses_$userId",
            )
            .get();

    if (!doc.exists) {
      return "";
    }

    final timestamp =
        doc["lastUpdated"]
            as Timestamp;

    return timestamp
        .toDate()
        .toIso8601String();
  }

  Future<AddressModel?> getDefaultAddress(
  String userId,
) async {
  final snapshot = await _firestore
      .collection("users")
      .doc(userId)
      .collection("addresses")
      .where(
        "isDefault",
        isEqualTo: true,
      )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return null;
  }

  return AddressModel.fromMap(
    snapshot.docs.first.data(),
  );
}
}