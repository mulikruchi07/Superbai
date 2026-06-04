import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superbai/firestore/user_fields.dart';

/// Customer profile stored in Firestore [UserFields.collection].
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.building,
    required this.pincode,
    required this.otpVerified,
    required this.type,
    this.state,
    this.district,
    this.region,
    this.image,
    this.aadhaar = '',
    this.services = const [],
    this.referrerName = '',
    this.referrerPhone = '',
  });

  final String id;
  final String name;
  final String phone;
  final String building;
  /// Flat / unit number (stored in Firestore [UserFields.pincode]).
  final String pincode;
  final String otpVerified;
  final String type;
  final String? state;
  final String? district;
  final String? region;
  final String? image;
  final String aadhaar;
  final List<String> services;
  final String referrerName;
  final String referrerPhone;

  /// Full onboarding (name + address + flat) required for new signups.
  bool get isComplete =>
      name.trim().isNotEmpty &&
      building.trim().isNotEmpty &&
      pincode.trim().isNotEmpty;

  /// Existing / legacy Firestore users skip "Create profile" after OTP.
  bool get shouldSkipProfileSetup {
    if (name.trim().isEmpty) return false;
    if (building.trim().isNotEmpty || pincode.trim().isNotEmpty) return true;
    final verified = otpVerified.toLowerCase();
    return verified == 'true' || verified == 'yes' || verified == '1';
  }

  /// Parses wing label from [building] when saved as `"Name, Wing X"`.
  String? get wingFromBuilding {
    final match = RegExp(r',\s*Wing\s+(.+)$').firstMatch(building);
    return match?.group(1)?.trim();
  }

  /// Building name without wing suffix.
  String get buildingNameOnly {
    final idx = building.indexOf(', Wing ');
    if (idx == -1) return building;
    return building.substring(0, idx).trim();
  }

  /// Legacy profile in [TestUser] (type `User`).
  factory UserProfile.fromTestUser(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    var building = '';
    var pincode = '';
    final addresses = data['addresses'];
    if (addresses is List && addresses.isNotEmpty) {
      final first = addresses.first;
      if (first is Map) {
        building = (first['building'] as String?)?.trim() ?? '';
        pincode =
            (first['flatNumber'] as String?)?.trim() ??
            (first['pincode'] as String?)?.trim() ??
            '';
      }
    }
    return UserProfile(
      id: doc.id,
      name: (data['name'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      building: building,
      pincode: pincode,
      otpVerified: 'true',
      type: (data['type'] as String?)?.trim() ?? 'User',
      image: data['imageURL'] as String?,
      referrerName: (data['referrerName'] as String?)?.trim() ?? '',
      referrerPhone: (data['referrerPhone'] as String?)?.trim() ?? '',
    );
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final servicesRaw = data[UserFields.services];
    return UserProfile(
      id: doc.id,
      name: (data[UserFields.name] as String?)?.trim() ?? '',
      phone: (data[UserFields.phone] as String?)?.trim() ?? '',
      building: (data[UserFields.building] as String?)?.trim() ?? '',
      pincode: (data[UserFields.pincode] as String?)?.trim() ?? '',
      otpVerified: (data[UserFields.otpVerified] as String?)?.trim() ?? '',
      type: (data[UserFields.type] as String?)?.trim() ?? 'User',
      state: data[UserFields.state] as String?,
      district: data[UserFields.district] as String?,
      region: data[UserFields.region] as String?,
      image: data[UserFields.image] as String?,
      aadhaar: (data[UserFields.aadhaar] as String?)?.trim() ?? '',
      services: servicesRaw is List
          ? servicesRaw.map((e) => e.toString()).toList()
          : const [],
      referrerName: (data[UserFields.referrerName] as String?)?.trim() ?? '',
      referrerPhone: (data[UserFields.referrerPhone] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      UserFields.name: name,
      UserFields.phone: phone,
      UserFields.building: building,
      UserFields.pincode: pincode,
      UserFields.otpVerified: otpVerified,
      UserFields.type: type,
      UserFields.aadhaar: aadhaar,
      UserFields.services: services,
      UserFields.referrerName: referrerName,
      UserFields.referrerPhone: referrerPhone,
      UserFields.state: state,
      UserFields.district: district,
      UserFields.region: region,
      UserFields.image: image,
    };
  }
}
