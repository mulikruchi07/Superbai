import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:superbai/exceptions/maid_slot_unavailable_exception.dart';
import 'package:superbai/firestore/appointment_fields.dart';
import 'package:superbai/firestore/appointment_mapper.dart';
import 'package:superbai/firestore/maid_fields.dart';
import 'package:superbai/repositories/maid_repository.dart';
import 'package:superbai/repositories/services_repository.dart';
import 'package:superbai/repositories/user_repository.dart';

class AppointmentRepository {
  AppointmentRepository({
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
    ServicesRepository? servicesRepository,
    MaidRepository? maidRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userRepository = userRepository ?? UserRepository(),
       _servicesRepository = servicesRepository ?? ServicesRepository(),
       _maidRepository = maidRepository ?? MaidRepository();

  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;
  final ServicesRepository _servicesRepository;
  final MaidRepository _maidRepository;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection(AppointmentFields.collection);

  DocumentReference<Map<String, dynamic>>? _maidRef(String? maidId) {
    if (maidId == null || maidId.trim().isEmpty) return null;
    return _firestore.collection(MaidFields.collection).doc(maidId.trim());
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _activeMaidAppointments(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return docs
        .where((doc) {
          final status =
              (doc.data()[AppointmentFields.status] as String?)?.toLowerCase() ??
              '';
          return status != 'cancelled';
        })
        .toList();
  }

  void _throwIfMaidBooked({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> appointments,
    required List<Map<String, int>> shifts,
    required List<String> days,
    required DateTime startDate,
    required DateTime endDate,
    required String customerType,
  }) {
    for (final doc in appointments) {
      if (AppointmentMapper.conflictsWithExisting(
        existingData: doc.data(),
        newShifts: shifts,
        newDays: days,
        newStartDate: startDate,
        newEndDate: endDate,
        newCustomerType: customerType,
      )) {
        throw const MaidSlotUnavailableException();
      }
    }
  }

  Future<void> _createAppointment({
    required Map<String, dynamic> payload,
    required DocumentReference<Map<String, dynamic>>? maidRef,
    required List<Map<String, int>> shifts,
    required List<String> days,
    required DateTime startDate,
    required DateTime endDate,
    required String customerType,
  }) async {
    if (maidRef == null) {
      await _appointments.add(payload);
      return;
    }

    final maid = await _maidRepository.getById(maidRef.id);
    if (maid != null &&
        AppointmentMapper.requestedShiftsConflictWithWorkplaces(
          shifts,
          maid.workplaces,
        )) {
      throw const MaidSlotUnavailableException(
        'Maid is already assigned during this time slot.',
      );
    }

    final existing = await _appointments
        .where(AppointmentFields.maid, isEqualTo: maidRef)
        .get();
    final activeAppointments = _activeMaidAppointments(existing.docs);

    _throwIfMaidBooked(
      appointments: activeAppointments,
      shifts: shifts,
      days: days,
      startDate: startDate,
      endDate: endDate,
      customerType: customerType,
    );

    final activeRefs =
        activeAppointments.map((doc) => doc.reference).toList();

    await _firestore.runTransaction((transaction) async {
      for (final ref in activeRefs) {
        final fresh = await transaction.get(ref);
        if (!fresh.exists) continue;
        if (AppointmentMapper.conflictsWithExisting(
          existingData: fresh.data()!,
          newShifts: shifts,
          newDays: days,
          newStartDate: startDate,
          newEndDate: endDate,
          newCustomerType: customerType,
        )) {
          throw const MaidSlotUnavailableException();
        }
      }

      transaction.set(_appointments.doc(), {
        ...payload,
        AppointmentFields.maid: maidRef,
      });
    });
  }

  Future<DocumentReference<Map<String, dynamic>>?> _requireUserRef(
    User authUser,
  ) {
    return _userRepository.resolveUserRef(authUser);
  }

  /// Creates one [Appointments] document from the booking wizard.
  Future<void> createFromWizard({
    required User authUser,
    required String serviceTitle,
    required Set<String> allRounderTypes,
    String? areaOption,
    required Set<String> additionalServices,
    String? mealType,
    required Set<String> meals,
    required Set<String> cookingStyles,
    required int peopleCount,
    bool? hasWashingMachine,
    required Set<String> laundryAdditional,
    required Set<String> typeOfCare,
    String? hoursOfCare,
    required Set<String> specialNeeds,
    required Set<String> childAges,
    required int numChildren,
    required Set<String> activities,
    Map<String, Map<String, dynamic>>? allRounderSubServiceData,
    required double budget,
    required int numShifts,
    required Set<String> shiftTimes,
    String? wizardServiceType,
    required Set<String> selectedDays,
    String remark = '',
    String? maidId,
  }) async {
    final userRef = await _requireUserRef(authUser);
    if (userRef == null) {
      throw StateError(
        'No User profile found for this phone number. Complete registration first.',
      );
    }

    final address = await _userRepository.readAddressFields(userRef);
    final serviceType = AppointmentMapper.serviceDisplayName(
      serviceTitle: serviceTitle,
      allRounderTypes: allRounderTypes,
    );

    var details = AppointmentMapper.buildDetails(
      areaOption: areaOption,
      additionalServices: additionalServices,
      mealType: mealType,
      meals: meals,
      cookingStyles: cookingStyles,
      peopleCount: peopleCount,
      hasWashingMachine: hasWashingMachine,
      laundryAdditional: laundryAdditional,
      typeOfCare: typeOfCare,
      hoursOfCare: hoursOfCare,
      specialNeeds: specialNeeds,
      childAges: childAges,
      numChildren: numChildren,
      activities: activities,
    );

    if (serviceTitle == 'All-rounder' && allRounderSubServiceData != null) {
      for (final entry in allRounderSubServiceData.entries) {
        final sub = entry.value;
        final merged = AppointmentMapper.buildDetails(
          areaOption: sub['currentSelectedAreaOption'] as String?,
          additionalServices:
              (sub['currentSelectedAdditionalServices'] as Set<String>?) ??
              {},
          mealType: sub['currentSelectedMealType'] as String?,
          meals:
              (sub['currentSelectedMeals'] as Set<String>?) ?? {},
          cookingStyles:
              (sub['currentSelectedCookingStyles'] as Set<String>?) ?? {},
          peopleCount: sub['currentSelectedPeopleCount'] as int?,
          hasWashingMachine: sub['currentHasWashingMachine'] as bool?,
          laundryAdditional:
              (sub['currentSelectedLaundryAdditional'] as Set<String>?) ??
              {},
          typeOfCare:
              (sub['currentSelectedTypeOfCare'] as Set<String>?) ?? {},
          hoursOfCare: sub['currentSelectedHoursOfCare'] as String?,
          specialNeeds:
              (sub['currentSelectedSpecialNeeds'] as Set<String>?) ?? {},
          childAges:
              (sub['currentSelectedChildAges'] as Set<String>?) ?? {},
          numChildren: sub['currentNumChildren'] as int?,
          activities:
              (sub['currentSelectedActivities'] as Set<String>?) ?? {},
        );
        for (final key in ['additional', 'number_of_people', 'washing_machine']) {
          (details[key] as List).addAll((merged[key] as List).map((e) => '${entry.key}: $e'));
        }
      }
    }

    final shifts = AppointmentMapper.parseShiftsFromSlotStrings(shiftTimes);
    final days = wizardServiceType == 'Custom'
        ? selectedDays.toList()
        : <String>[];
    final range = AppointmentMapper.resolveDateRange(
      wizardServiceType: wizardServiceType,
      selectedDays: selectedDays,
    );
    final customerType = AppointmentMapper.customerTypeFromWizard(
      serviceType: wizardServiceType,
      selectedDays: selectedDays,
    );

    final maidRef = _maidRef(maidId);
    final payload = AppointmentMapper.buildCreatePayload(
      userRef: userRef,
      serviceType: serviceType,
      budget: budget.round(),
      numberOfShifts: numShifts,
      shifts: shifts,
      days: days,
      details: details,
      building: address['building'] ?? '',
      flatNumber: address['flatNumber'] ?? '',
      state: address['state'] ?? '',
      customerType: customerType,
      startDate: range.start,
      endDate: range.end,
      remark: remark,
      maidRef: maidRef,
    );

    await _createAppointment(
      payload: payload,
      maidRef: maidRef,
      shifts: shifts,
      days: days,
      startDate: range.start,
      endDate: range.end,
      customerType: customerType,
    );

    await _servicesRepository.recordFromBooking(
      authUser,
      serviceType: serviceType,
      allRounderSubTypes: allRounderSubServiceData?.keys ?? const [],
    );
  }

  Future<List<Map<String, dynamic>>> _mapBookingDocuments(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final viewModels = <Map<String, dynamic>>[];
    for (final doc in docs) {
      final status =
          (doc.data()[AppointmentFields.status] as String?)?.toLowerCase() ?? '';
      if (status == 'cancelled') continue;
      viewModels.add(
        await AppointmentMapper.toBookingViewModel(
          id: doc.id,
          data: doc.data(),
          firestore: _firestore,
        ),
      );
    }
    return viewModels;
  }

  /// Real-time appointments for the signed-in user (excludes cancelled).
  ///
  /// Matches all profile docs (phone, UID, legacy) and filters status in-app
  /// so a composite Firestore index is not required.
  Stream<List<Map<String, dynamic>>> watchBookingsForAuthUser(User authUser) async* {
    final userRefs = await _userRepository.collectProfileRefsForAuthUser(authUser);
    if (userRefs.isEmpty) {
      yield [];
      return;
    }

    final queryRefs =
        userRefs.length > 10 ? userRefs.take(10).toList() : userRefs;

    final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
    if (queryRefs.length == 1) {
      stream = _appointments
          .where(AppointmentFields.user, isEqualTo: queryRefs.first)
          .snapshots();
    } else {
      stream = _appointments
          .where(AppointmentFields.user, whereIn: queryRefs)
          .snapshots();
    }

    await for (final snapshot in stream) {
      yield await _mapBookingDocuments(snapshot.docs);
    }
  }

  /// Booking from toggle → maid onboarding (salary / linking flow).
  Future<void> createFromMaidOnboarding({
    required User authUser,
    required String maidId,
    required Map<String, dynamic> routeArguments,
  }) async {
    final shiftTimes =
        (routeArguments['selectedShiftTimes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toSet() ??
        <String>{};
    if (shiftTimes.isEmpty) {
      throw StateError('Select at least one time slot.');
    }

    final serviceTitle =
        routeArguments['serviceTitle'] as String? ?? 'Service';
    final allRounderTypes =
        (routeArguments['currentSelectedAllRounderTypes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        <String>{};

    await createFromWizard(
      authUser: authUser,
      serviceTitle: serviceTitle,
      allRounderTypes: allRounderTypes,
      areaOption: routeArguments['currentSelectedAreaOption'] as String?,
      additionalServices:
          (routeArguments['currentSelectedAdditionalServices'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toSet() ??
              {},
      mealType: routeArguments['currentSelectedMealType'] as String?,
      meals:
          (routeArguments['currentSelectedMeals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      cookingStyles:
          (routeArguments['currentSelectedCookingStyles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      peopleCount:
          routeArguments['currentSelectedPeopleCount'] as int? ?? 1,
      hasWashingMachine:
          routeArguments['currentHasWashingMachine'] as bool?,
      laundryAdditional:
          (routeArguments['currentSelectedLaundryAdditional'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      typeOfCare:
          (routeArguments['currentSelectedTypeOfCare'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      hoursOfCare: routeArguments['currentSelectedHoursOfCare'] as String?,
      specialNeeds:
          (routeArguments['currentSelectedSpecialNeeds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      childAges:
          (routeArguments['currentSelectedChildAges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      numChildren: routeArguments['currentNumChildren'] as int? ?? 1,
      activities:
          (routeArguments['currentSelectedActivities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      budget: (routeArguments['currentBudget'] as num?)?.toDouble() ?? 4000,
      numShifts: routeArguments['numberOfShifts'] as int? ?? shiftTimes.length,
      shiftTimes: shiftTimes,
      wizardServiceType: 'Daily',
      selectedDays:
          (routeArguments['currentSelectedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      remark: routeArguments['remark'] as String? ?? '',
      maidId: maidId,
    );
  }

  static String? maidIdFromRouteArguments(Map<String, dynamic>? args) {
    if (args == null) return null;
    final nested = args['maidData'];
    if (nested is Map) {
      final id = nested['id'];
      if (id is String && id.trim().isNotEmpty) return id.trim();
    }
    return null;
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _appointments.doc(appointmentId).update({
      AppointmentFields.status: 'cancelled',
    });
  }

  /// Backup / flexibility flow: new instant appointment + mark prior remark.
  Future<void> createBackupAppointment({
    required User authUser,
    required Map<String, dynamic> originalBooking,
    required DateTime date,
    required String timeSlotLabel,
    int backupBudget = 500,
  }) async {
    final userRef = await _requireUserRef(authUser);
    if (userRef == null) {
      throw StateError('No User profile found.');
    }

    final address = await _userRepository.readAddressFields(userRef);
    final shifts = AppointmentMapper.parseShiftsFromSlotStrings([timeSlotLabel]);
    final serviceType =
        (originalBooking['service'] as String?) ?? 'Service';

    final maidRef = originalBooking['Maid'] is DocumentReference<Map<String, dynamic>>
        ? originalBooking['Maid'] as DocumentReference<Map<String, dynamic>>
        : null;
    final days = [DateFormat('d/M/yyyy').format(date)];
    final payload = AppointmentMapper.buildCreatePayload(
      userRef: userRef,
      serviceType: serviceType,
      budget: backupBudget,
      numberOfShifts: 1,
      shifts: shifts,
      days: days,
      details: AppointmentMapper.buildDetails(),
      building: address['building'] ?? '',
      flatNumber: address['flatNumber'] ?? '',
      state: address['state'] ?? '',
      customerType: 'Instant',
      startDate: date,
      endDate: date,
      remark: 'Backup booking',
      maidRef: maidRef,
    );

    await _createAppointment(
      payload: payload,
      maidRef: maidRef,
      shifts: shifts,
      days: days,
      startDate: date,
      endDate: date,
      customerType: 'Instant',
    );

    final originalId = originalBooking['id'] as String?;
    if (originalId != null) {
      await _appointments.doc(originalId).update({
        AppointmentFields.remark: 'Backup Requested',
      });
    }
  }
}
