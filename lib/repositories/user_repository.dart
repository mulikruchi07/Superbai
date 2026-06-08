import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superbai/firestore/appointment_fields.dart';
import 'package:superbai/firestore/phone_utils.dart';
import 'package:superbai/firestore/user_fields.dart';
import 'package:superbai/firestore/user_related_fields.dart';
import 'package:superbai/data/terms_and_conditions.dart';
import 'package:superbai/models/user_profile.dart';

/// CRUD for production Firestore [UserFields.collection] documents.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _testUserCollection = 'TestUser';

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(UserFields.collection);

  static String canonicalPhone(String? e164OrLocal) =>
      PhoneUtils.toTenDigit(e164OrLocal);

  static String formatBuildingWithWing({
    required String buildingName,
    required String wing,
  }) {
    return '$buildingName, Wing $wing';
  }

  bool _docHasIdentity(Map<String, dynamic>? data) {
    if (data == null) return false;
    final name = (data[UserFields.name] as String?)?.trim() ?? '';
    if (name.isNotEmpty) return true;
    final building = (data[UserFields.building] as String?)?.trim() ?? '';
    if (building.isNotEmpty) return true;
    final pincode = (data[UserFields.pincode] as String?)?.trim() ?? '';
    if (pincode.isNotEmpty) return true;
    return false;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findUserDocByPhone(
    String? phoneNumber,
  ) async {
    final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[
      for (final phone in PhoneUtils.queryVariants(phoneNumber))
        _users.where(UserFields.phone, isEqualTo: phone).limit(1).get(),
    ];

    final phone10 = PhoneUtils.toTenDigit(phoneNumber);
    final asInt = int.tryParse(phone10);
    if (asInt != null) {
      queries.add(
        _users.where(UserFields.phone, isEqualTo: asInt).limit(1).get(),
      );
    }

    final results = await Future.wait(queries);
    for (final snap in results) {
      if (snap.docs.isNotEmpty) return snap.docs.first;
    }
    return null;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _findTestUserDocByPhone(
    String? phoneNumber,
  ) async {
    for (final phone in PhoneUtils.queryVariants(phoneNumber)) {
      final snap = await _firestore
          .collection(_testUserCollection)
          .where('phone', isEqualTo: phone)
          .where('type', isEqualTo: 'User')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) return snap.docs.first;
    }
    return null;
  }

  /// Finds the Firestore user doc for [authUser] (phone → legacy TestUser → uid).
  Future<DocumentReference<Map<String, dynamic>>?> resolveUserRef(
    User authUser,
  ) async {
    final byPhone = await _findUserDocByPhone(authUser.phoneNumber);
    if (byPhone != null) return byPhone.reference;

    final legacy = await _findTestUserDocByPhone(authUser.phoneNumber);
    if (legacy != null) return legacy.reference;

    final byUid = await _users.doc(authUser.uid).get();
    if (byUid.exists && _docHasIdentity(byUid.data())) {
      return byUid.reference;
    }
    return null;
  }

  /// Read profile for the signed-in Firebase user.
  Future<UserProfile?> getProfileForAuthUser(User authUser) async {
    final userDoc = await _findUserDocByPhone(authUser.phoneNumber);
    if (userDoc != null) {
      return UserProfile.fromFirestore(userDoc);
    }

    final testDoc = await _findTestUserDocByPhone(authUser.phoneNumber);
    if (testDoc != null) {
      return UserProfile.fromTestUser(testDoc);
    }

    final byUid = await _users.doc(authUser.uid).get();
    if (byUid.exists && _docHasIdentity(byUid.data())) {
      return UserProfile.fromFirestore(byUid);
    }
    return null;
  }

  Future<Map<String, String>> readAddressFields(
    DocumentReference<Map<String, dynamic>> userRef,
  ) async {
    final snap = await userRef.get();
    final data = snap.data();
    if (data == null) {
      return {'building': '', 'flatNumber': '', 'state': ''};
    }

    if (snap.reference.parent.id == _testUserCollection) {
      final addresses = data['addresses'];
      if (addresses is List && addresses.isNotEmpty) {
        final first = addresses.first;
        if (first is Map) {
          return {
            'building': (first['building'] as String?)?.trim() ?? '',
            'flatNumber':
                (first['flatNumber'] as String?)?.trim() ??
                (first['pincode'] as String?)?.trim() ??
                '',
            'state': '',
          };
        }
      }
    }

    return {
      'building': (data[UserFields.building] as String?)?.trim() ?? '',
      'flatNumber': (data[UserFields.pincode] as String?)?.trim() ?? '',
      'state': (data[UserFields.state] as String?)?.trim() ?? '',
    };
  }

  /// Sets [UserFields.otpVerified] after phone auth. Only creates a stub for new users.
  Future<DocumentReference<Map<String, dynamic>>> markOtpVerified(
    User authUser,
  ) async {
    final phone10 = canonicalPhone(authUser.phoneNumber);
    final existing = await resolveUserRef(authUser);

    final patch = <String, dynamic>{
      UserFields.otpVerified: 'true',
      UserFields.phone: phone10.isNotEmpty ? phone10 : authUser.phoneNumber ?? '',
      UserFields.type: 'User',
    };

    if (existing != null) {
      await existing.set(patch, SetOptions(merge: true));
      return existing;
    }

    final ref = _users.doc(authUser.uid);
    await ref.set({
      ...patch,
      UserFields.name: '',
      UserFields.building: '',
      UserFields.pincode: '',
      UserFields.aadhaar: '',
      UserFields.services: <String>[],
      UserFields.referrerName: '',
      UserFields.referrerPhone: '',
      UserFields.state: null,
      UserFields.district: null,
      UserFields.region: null,
      UserFields.image: null,
    }, SetOptions(merge: true));
    return ref;
  }

  /// Create or update profile from onboarding / edit profile.
  Future<DocumentReference<Map<String, dynamic>>> saveProfile({
    required User authUser,
    required String name,
    required String buildingName,
    required String wing,
    required String flatNumber,
    String? state,
  }) async {
    final phone10 = canonicalPhone(authUser.phoneNumber);
    final building = formatBuildingWithWing(
      buildingName: buildingName,
      wing: wing,
    );

    final data = <String, dynamic>{
      UserFields.name: name.trim(),
      UserFields.phone: phone10.isNotEmpty ? phone10 : authUser.phoneNumber ?? '',
      UserFields.building: building,
      UserFields.pincode: flatNumber.trim(),
      UserFields.otpVerified: 'true',
      UserFields.type: 'User',
      UserFields.aadhaar: '',
      UserFields.services: <String>[],
      UserFields.referrerName: '',
      UserFields.referrerPhone: '',
      if (state != null && state.isNotEmpty) UserFields.state: state,
    };

    final existing = await resolveUserRef(authUser);
    if (existing != null && existing.parent.id == _testUserCollection) {
      await _migrateTestUserToUser(
        testUserRef: existing,
        authUser: authUser,
        data: data,
      );
      return _users.doc(authUser.uid);
    }

    if (existing != null) {
      await existing.set(data, SetOptions(merge: true));
      return existing;
    }

    final ref = _users.doc(authUser.uid);
    await ref.set({
      ...data,
      UserFields.district: null,
      UserFields.region: null,
      UserFields.image: null,
    }, SetOptions(merge: true));
    return ref;
  }

  /// Records customer acceptance or decline of Terms & Conditions.
  Future<void> saveTermsResponse({
    required User authUser,
    required bool accepted,
  }) async {
    final ref = await resolveUserRef(authUser);
    if (ref == null) {
      throw StateError('User profile not found.');
    }

    if (accepted) {
      await ref.set({
        UserFields.termsAccepted: true,
        UserFields.termsAcceptedAt: FieldValue.serverTimestamp(),
        UserFields.termsDeclinedAt: FieldValue.delete(),
        UserFields.termsVersion: TermsAndConditions.version,
      }, SetOptions(merge: true));
      return;
    }

    await ref.set({
      UserFields.termsAccepted: false,
      UserFields.termsDeclinedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _migrateTestUserToUser({
    required DocumentReference<Map<String, dynamic>> testUserRef,
    required User authUser,
    required Map<String, dynamic> data,
  }) async {
    final ref = _users.doc(authUser.uid);
    await ref.set(data, SetOptions(merge: true));
    await testUserRef.set({'OTPverified': 'true'}, SetOptions(merge: true));
  }

  /// Update display name (account → edit profile).
  Future<void> updateName(User authUser, String name) async {
    final ref = await resolveUserRef(authUser);
    if (ref == null) {
      throw StateError('User profile not found.');
    }
    if (ref.parent.id == _testUserCollection) {
      await ref.update({'name': name.trim()});
      return;
    }
    await ref.update({UserFields.name: name.trim()});
  }

  /// Updates [UserFields.services] for the signed-in user.
  Future<void> updateServices(User authUser, List<String> services) async {
    final ref = await resolveUserRef(authUser);
    if (ref == null) {
      throw StateError('User profile not found.');
    }
    if (ref.parent.id == _testUserCollection) {
      throw StateError('Migrate legacy profile to User collection first.');
    }
    await ref.update({UserFields.services: services});
  }

  /// All Firestore profile documents tied to [authUser] (phone, uid stub, legacy TestUser).
  Future<List<DocumentReference<Map<String, dynamic>>>>
  collectProfileRefsForAuthUser(User authUser) async {
    final byPath = <String, DocumentReference<Map<String, dynamic>>>{};

    void add(DocumentReference<Map<String, dynamic>> ref) {
      byPath[ref.path] = ref;
    }

    final byPhone = await _findUserDocByPhone(authUser.phoneNumber);
    if (byPhone != null) add(byPhone.reference);

    final testDoc = await _findTestUserDocByPhone(authUser.phoneNumber);
    if (testDoc != null) add(testDoc.reference);

    final uidSnap = await _users.doc(authUser.uid).get();
    if (uidSnap.exists) add(uidSnap.reference);

    final resolved = await resolveUserRef(authUser);
    if (resolved != null) add(resolved);

    return byPath.values.toList();
  }

  /// Deletes all Firestore data tied to [authUser]: profiles, bookings,
  /// payments, complaints, reviews, OTPs, and legacy star-schema rows.
  Future<void> deleteAllUserDataForAuthUser(User authUser) async {
    final profileRefs = await collectProfileRefsForAuthUser(authUser);
    final userRefs = <DocumentReference<Map<String, dynamic>>>[
      ...profileRefs,
    ];
    final uidRef = _users.doc(authUser.uid);
    if (!userRefs.any((r) => r.path == uidRef.path)) {
      userRefs.add(uidRef);
    }

    final appointmentDocs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final userRef in userRefs) {
      final snap = await _firestore
          .collection(AppointmentFields.collection)
          .where(AppointmentFields.user, isEqualTo: userRef)
          .get();
      for (final doc in snap.docs) {
        appointmentDocs[doc.id] = doc;
      }
    }

    final transactionRefs =
        <String, DocumentReference<Map<String, dynamic>>>{};
    for (final doc in appointmentDocs.values) {
      final tx = doc.data()[AppointmentFields.transaction];
      if (tx is DocumentReference<Map<String, dynamic>>) {
        transactionRefs[tx.path] = tx;
      }
    }

    for (final userRef in userRefs) {
      await _deleteWhereReferenceEquals(
        UserRelatedFields.complaintCollection,
        UserRelatedFields.user,
        userRef,
      );
      await _deleteWhereReferenceEquals(
        UserRelatedFields.reviewCollection,
        UserRelatedFields.user,
        userRef,
      );
    }

    await _deleteReferences(transactionRefs.values);
    await _deleteDocumentSnapshots(appointmentDocs.values);
    await _deleteOtpsForPhone(authUser.phoneNumber);
    await _deleteLegacyStarSchemaForAuthUser(authUser);
    await _deleteReferences(profileRefs);
  }

  /// @deprecated Prefer [deleteAllUserDataForAuthUser].
  Future<void> deleteProfileForAuthUser(User authUser) =>
      deleteAllUserDataForAuthUser(authUser);

  Future<void> _deleteWhereReferenceEquals(
    String collection,
    String field,
    DocumentReference<Map<String, dynamic>> value,
  ) async {
    final snap = await _firestore
        .collection(collection)
        .where(field, isEqualTo: value)
        .get();
    await _deleteDocumentSnapshots(snap.docs);
  }

  Future<void> _deleteOtpsForPhone(String? phoneNumber) async {
    for (final variant in PhoneUtils.queryVariants(phoneNumber)) {
      final snap = await _firestore
          .collection(UserRelatedFields.otpsCollection)
          .where(UserRelatedFields.phoneNumber, isEqualTo: variant)
          .get();
      await _deleteDocumentSnapshots(snap.docs);
    }
    final asInt = int.tryParse(PhoneUtils.toTenDigit(phoneNumber));
    if (asInt != null) {
      final snap = await _firestore
          .collection(UserRelatedFields.otpsCollection)
          .where(UserRelatedFields.phoneNumber, isEqualTo: asInt)
          .get();
      await _deleteDocumentSnapshots(snap.docs);
    }
  }

  Future<void> _deleteLegacyStarSchemaForAuthUser(User authUser) async {
    final factSnap = await _firestore
        .collection(UserRelatedFields.legacyFactBookings)
        .where(UserRelatedFields.legacyUserId, isEqualTo: authUser.uid)
        .get();

    for (final doc in factSnap.docs) {
      final data = doc.data();
      final dimDeletes = <Future<void>>[
        _deleteLegacyDimDoc(
          UserRelatedFields.legacyDimServices,
          data[UserRelatedFields.legacyServiceId] as String?,
        ),
        _deleteLegacyDimDoc(
          UserRelatedFields.legacyDimTimeSlots,
          data[UserRelatedFields.legacyTimeSlotId] as String?,
        ),
        _deleteLegacyDimDoc(
          UserRelatedFields.legacyDimSalary,
          data[UserRelatedFields.legacySalaryId] as String?,
        ),
      ];
      await Future.wait(dimDeletes);
      await doc.reference.delete();
    }

    final dimUserRef =
        _firestore.collection(UserRelatedFields.legacyDimUsers).doc(authUser.uid);
    final dimUserSnap = await dimUserRef.get();
    if (dimUserSnap.exists) {
      await dimUserRef.delete();
    }
  }

  Future<void> _deleteLegacyDimDoc(String collection, String? id) async {
    if (id == null || id.isEmpty) return;
    await _firestore.collection(collection).doc(id).delete();
  }

  Future<void> _deleteReferences(
    Iterable<DocumentReference<Map<String, dynamic>>> refs,
  ) async {
    await _commitBatchedDeletes(refs);
  }

  Future<void> _deleteDocumentSnapshots(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    await _commitBatchedDeletes(docs.map((d) => d.reference));
  }

  Future<void> _commitBatchedDeletes(
    Iterable<DocumentReference<Map<String, dynamic>>> refs,
  ) async {
    var batch = _firestore.batch();
    var count = 0;
    for (final ref in refs) {
      batch.delete(ref);
      count++;
      if (count >= 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }
}
