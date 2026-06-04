import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superbai/firestore/maid_fields.dart';
import 'package:superbai/firestore/phone_utils.dart';
import 'package:superbai/models/maid_record.dart';

/// CRUD for production Firestore [MaidFields.collection].
class MaidRepository {
  MaidRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _maids =>
      _firestore.collection(MaidFields.collection);

  List<MaidRecord> _sortByRecent(List<MaidRecord> list) {
    list.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt ?? DateTime(1970);
      final bTime = b.updatedAt ?? b.createdAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  /// Real-time list of all maids.
  Stream<List<MaidRecord>> watchAll() {
    return _maids.snapshots().map((snap) {
      return _sortByRecent(snap.docs.map(MaidRecord.fromFirestore).toList());
    });
  }

  Future<List<MaidRecord>> getAll() async {
    final snap = await _maids.get();
    return _sortByRecent(snap.docs.map(MaidRecord.fromFirestore).toList());
  }

  Future<MaidRecord?> getById(String id) async {
    final snap = await _maids.doc(id).get();
    if (!snap.exists) return null;
    return MaidRecord.fromFirestore(snap);
  }

  Future<MaidRecord?> findByPhone(String phoneNumber) async {
    for (final variant in PhoneUtils.queryVariants(phoneNumber)) {
      final snap = await _maids
          .where(MaidFields.phoneNumber, isEqualTo: variant)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        return MaidRecord.fromFirestore(snap.docs.first);
      }
    }
    return null;
  }

  Future<String> create({
    required String name,
    required String phoneNumber,
    required List<String> services,
    List<MaidWorkplace> workplaces = const [],
  }) async {
    final now = FieldValue.serverTimestamp();
    final doc = await _maids.add({
      MaidFields.name: name.trim(),
      MaidFields.phoneNumber: _normalizePhone(phoneNumber),
      MaidFields.services: services,
      MaidFields.workplaces: workplaces.map((w) => w.toMap()).toList(),
      MaidFields.createdAt: now,
      MaidFields.updatedAt: now,
    });
    return doc.id;
  }

  Future<void> update({
    required String id,
    required String name,
    required String phoneNumber,
    required List<String> services,
    List<MaidWorkplace> workplaces = const [],
  }) async {
    await _maids.doc(id).update({
      MaidFields.name: name.trim(),
      MaidFields.phoneNumber: _normalizePhone(phoneNumber),
      MaidFields.services: services,
      MaidFields.workplaces: workplaces.map((w) => w.toMap()).toList(),
      MaidFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) async {
    await _maids.doc(id).delete();
  }

  String _normalizePhone(String phone) {
    final ten = PhoneUtils.toTenDigit(phone);
    return ten.isNotEmpty ? ten : phone.trim();
  }
}
