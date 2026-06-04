import 'package:firebase_auth/firebase_auth.dart';
import 'package:superbai/data/service_catalog.dart';
import 'package:superbai/repositories/user_repository.dart';

/// CRUD for the [UserFields.services] array on production [User] documents.
class ServicesRepository {
  ServicesRepository({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  /// Read saved service names for [authUser].
  Future<List<String>> getUserServices(User authUser) async {
    final profile = await _userRepository.getProfileForAuthUser(authUser);
    return profile?.services ?? [];
  }

  /// Replace the full services list.
  Future<void> setUserServices(
    User authUser,
    List<String> services,
  ) async {
    final normalized = _normalizeList(services);
    await _userRepository.updateServices(authUser, normalized);
  }

  /// Add one service if not already present.
  Future<void> addService(User authUser, String serviceName) async {
    final current = await getUserServices(authUser);
    final next = List<String>.from(current);
    final trimmed = serviceName.trim();
    if (trimmed.isEmpty) return;
    if (!next.contains(trimmed)) {
      next.add(trimmed);
      await setUserServices(authUser, next);
    }
  }

  /// Add multiple services (e.g. after booking).
  Future<void> addServices(User authUser, Iterable<String> serviceNames) async {
    final current = await getUserServices(authUser);
    final next = List<String>.from(current);
    for (final name in serviceNames) {
      final trimmed = name.trim();
      if (trimmed.isNotEmpty && !next.contains(trimmed)) {
        next.add(trimmed);
      }
    }
    await setUserServices(authUser, next);
  }

  /// Remove a service by name.
  Future<void> removeService(User authUser, String serviceName) async {
    final current = await getUserServices(authUser);
    final next = current.where((s) => s != serviceName.trim()).toList();
    await setUserServices(authUser, next);
  }

  /// Clears all saved services.
  Future<void> clearServices(User authUser) async {
    await setUserServices(authUser, []);
  }

  /// Records services used in a booking ([Appointments.serviceType] value).
  Future<void> recordFromBooking(
    User authUser, {
    required String serviceType,
    Iterable<String> allRounderSubTypes = const [],
  }) async {
    final toSave = <String>{serviceType.trim()};

    if (serviceType.startsWith('${ServiceCatalog.allRounder} (')) {
      toSave.add(ServiceCatalog.allRounder);
      toSave.addAll(allRounderSubTypes.map((s) => s.trim()).where((s) => s.isNotEmpty));
    }

    for (final sub in allRounderSubTypes) {
      if (sub.trim().isNotEmpty) toSave.add(sub.trim());
    }

    await addServices(authUser, toSave);
  }

  List<String> _normalizeList(List<String> services) {
    final seen = <String>{};
    final result = <String>[];
    for (final s in services) {
      final trimmed = s.trim();
      if (trimmed.isNotEmpty && seen.add(trimmed)) {
        result.add(trimmed);
      }
    }
    return result;
  }
}
