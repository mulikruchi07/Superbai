import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superbai/firestore/maid_fields.dart';

class MaidWorkplace {
  const MaidWorkplace({
    this.buildingAddress = '',
    this.clientName = '',
    this.wingAndFlat = '',
    this.timeslotFrom = '',
    this.timeslotTo = '',
  });

  final String buildingAddress;
  final String clientName;
  final String wingAndFlat;
  final String timeslotFrom;
  final String timeslotTo;

  factory MaidWorkplace.fromMap(Map<String, dynamic> map) {
    final slot = map[MaidFields.timeslot];
    Map<String, dynamic>? timeslotMap;
    if (slot is Map) {
      timeslotMap = Map<String, dynamic>.from(slot);
    }
    return MaidWorkplace(
      buildingAddress:
          (map[MaidFields.buildingAddress] as String?)?.trim() ?? '',
      clientName: (map[MaidFields.clientName] as String?)?.trim() ?? '',
      wingAndFlat: (map[MaidFields.wingAndFlat] as String?)?.trim() ?? '',
      timeslotFrom: (timeslotMap?[MaidFields.from] as String?)?.trim() ?? '',
      timeslotTo: (timeslotMap?[MaidFields.to] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      MaidFields.buildingAddress: buildingAddress,
      MaidFields.clientName: clientName,
      MaidFields.wingAndFlat: wingAndFlat,
      MaidFields.timeslot: {
        MaidFields.from: timeslotFrom,
        MaidFields.to: timeslotTo,
      },
    };
  }
}

class MaidRecord {
  const MaidRecord({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.services,
    required this.workplaces,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final List<String> services;
  final List<MaidWorkplace> workplaces;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get primaryService =>
      services.isNotEmpty ? services.first : 'Maid';

  String get displayCode {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return id.length >= 4 ? id.substring(id.length - 4) : id;
  }

  String get displayLocation {
    if (workplaces.isEmpty) return '';
    final w = workplaces.first;
    if (w.buildingAddress.isNotEmpty) return w.buildingAddress;
    return w.clientName;
  }

  factory MaidRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final servicesRaw = data[MaidFields.services];
    final workplacesRaw = data[MaidFields.workplaces];

    return MaidRecord(
      id: doc.id,
      name: (data[MaidFields.name] as String?)?.trim() ?? '',
      phoneNumber: (data[MaidFields.phoneNumber] as String?)?.trim() ?? '',
      services: servicesRaw is List
          ? servicesRaw.map((e) => e.toString()).toList()
          : const [],
      workplaces: workplacesRaw is List
          ? workplacesRaw
                .whereType<Map>()
                .map((e) => MaidWorkplace.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      createdAt: (data[MaidFields.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[MaidFields.updatedAt] as Timestamp?)?.toDate(),
    );
  }

  /// Shape expected by [FindMaidScreen] / [MaidDetailsScreen].
  Map<String, dynamic> toUiMap() {
    return {
      'id': id,
      'name': name,
      'role': primaryService,
      'code': displayCode,
      'phoneNumber': phoneNumber,
      'services': services,
      'location': displayLocation,
      'gender': '—',
      'age': '—',
      'experience': '—',
      'isVerified': true,
      'workplaces': workplaces.map((w) => w.toMap()).toList(),
    };
  }
}
