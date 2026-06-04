import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:superbai/firestore/appointment_fields.dart';
import 'package:superbai/models/maid_record.dart';

/// Maps between booking UI state and production [AppointmentFields.collection] docs.
class AppointmentMapper {
  AppointmentMapper._();

  static String serviceDisplayName({
    required String serviceTitle,
    required Set<String> allRounderTypes,
  }) {
    if (serviceTitle == 'All-rounder' && allRounderTypes.isNotEmpty) {
      return 'All-rounder (${allRounderTypes.join(', ')})';
    }
    return serviceTitle;
  }

  static String customerTypeFromWizard({
    String? serviceType,
    required Set<String> selectedDays,
    bool instant = false,
  }) {
    if (instant || serviceType == 'Instant') return 'Instant';
    if (serviceType == 'Custom' || selectedDays.isNotEmpty) return 'Custom';
    return 'Daily';
  }

  static Map<String, dynamic> buildDetails({
    String? areaOption,
    Set<String> additionalServices = const {},
    String? mealType,
    Set<String> meals = const {},
    Set<String> cookingStyles = const {},
    int? peopleCount,
    bool? hasWashingMachine,
    Set<String> laundryAdditional = const {},
    Set<String> typeOfCare = const {},
    String? hoursOfCare,
    Set<String> specialNeeds = const {},
    Set<String> childAges = const {},
    int? numChildren,
    Set<String> activities = const {},
  }) {
    final additional = <String>[
      ...additionalServices,
      if (areaOption != null && areaOption.isNotEmpty) 'Area: $areaOption',
      if (mealType != null && mealType.isNotEmpty) 'MealType: $mealType',
      ...meals.map((m) => 'Meal: $m'),
      ...cookingStyles.map((s) => 'Style: $s'),
      ...typeOfCare.map((c) => 'Care: $c'),
      if (hoursOfCare != null && hoursOfCare.isNotEmpty)
        'HoursOfCare: $hoursOfCare',
      ...specialNeeds.map((n) => 'Need: $n'),
      ...childAges.map((a) => 'ChildAge: $a'),
      ...activities.map((a) => 'Activity: $a'),
      ...laundryAdditional,
      if (numChildren != null && numChildren > 0) 'Children: $numChildren',
    ];

    final numberOfPeople = <String>[
      if (peopleCount != null && peopleCount > 0) peopleCount.toString(),
    ];

    final washingMachine = <String>[
      if (hasWashingMachine == true) 'Yes',
      if (hasWashingMachine == false) 'No',
    ];

    return {
      'additional': additional,
      'number_of_people': numberOfPeople,
      'washing_machine': washingMachine,
    };
  }

  static List<Map<String, int>> parseShiftsFromSlotStrings(
    Iterable<String> slotStrings,
  ) {
    final shifts = <Map<String, int>>[];
    for (final slot in slotStrings) {
      final trimmed = slot.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(' - ');
      if (parts.length >= 2) {
        shifts.add({
          'start_time': _timeStringToMinutes(parts[0].trim()),
          'end_time': _timeStringToMinutes(parts[1].trim()),
        });
      } else {
        final start = _timeStringToMinutes(trimmed);
        shifts.add({'start_time': start, 'end_time': start + 60});
      }
    }
    return shifts;
  }

  static String formatTimingFromShifts(List<dynamic>? rawShifts) {
    if (rawShifts == null || rawShifts.isEmpty) return 'N/A';

    final parts = <String>[];
    for (final entry in rawShifts) {
      if (entry is Map) {
        final start = entry['start_time'];
        final end = entry['end_time'];
        if (start is num && end is num) {
          parts.add(
            '${_minutesToDisplay(start.toInt())} - ${_minutesToDisplay(end.toInt())}',
          );
        }
      }
    }
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  static ({DateTime start, DateTime end}) resolveDateRange({
    required String? wizardServiceType,
    required Set<String> selectedDays,
  }) {
    DateTime start;
    DateTime end;

    if (wizardServiceType == 'Custom' && selectedDays.isNotEmpty) {
      try {
        start = DateFormat('d/M/yyyy').parse(selectedDays.first);
      } catch (_) {
        start = DateTime.now();
      }
      end = start;
      if (selectedDays.length > 1) {
        try {
          end = DateFormat('d/M/yyyy').parse(selectedDays.last);
        } catch (_) {}
      }
    } else {
      start = DateTime.now();
      final now = DateTime.now();
      end = DateTime(now.year, now.month + 1, 0);
    }
    return (start: start, end: end);
  }

  static List<Map<String, int>> shiftsFromAppointmentData(
    Map<String, dynamic> data,
  ) {
    final raw = data[AppointmentFields.shifts];
    if (raw is! List) return const [];

    final shifts = <Map<String, int>>[];
    for (final entry in raw) {
      if (entry is Map) {
        final start = entry['start_time'];
        final end = entry['end_time'];
        if (start is num && end is num) {
          shifts.add({
            'start_time': start.toInt(),
            'end_time': end.toInt(),
          });
        }
      }
    }
    return shifts;
  }

  static Set<DateTime> expandBookingDates({
    required String customerType,
    required List<String> days,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final normalized = <DateTime>{};

    void addDay(DateTime value) {
      normalized.add(DateTime(value.year, value.month, value.day));
    }

    if (customerType == 'Custom' && days.isNotEmpty) {
      for (final day in days) {
        try {
          addDay(DateFormat('d/M/yyyy').parse(day));
        } catch (_) {}
      }
      return normalized;
    }

    if (customerType == 'Instant') {
      addDay(startDate);
      return normalized;
    }

    var cursor = DateTime(startDate.year, startDate.month, startDate.day);
    final last = DateTime(endDate.year, endDate.month, endDate.day);
    while (!cursor.isAfter(last)) {
      addDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return normalized;
  }

  /// Recurring busy windows from [maids.workplaces] timeslots.
  static List<Map<String, int>> shiftsFromWorkplaces(
    List<MaidWorkplace> workplaces,
  ) {
    final shifts = <Map<String, int>>[];
    for (final workplace in workplaces) {
      if (workplace.timeslotFrom.isEmpty || workplace.timeslotTo.isEmpty) {
        continue;
      }
      shifts.addAll(
        parseShiftsFromSlotStrings([
          '${workplace.timeslotFrom} - ${workplace.timeslotTo}',
        ]),
      );
    }
    return shifts;
  }

  /// True when requested shifts overlap any workplace duty window (daily recurrence).
  static bool requestedShiftsConflictWithWorkplaces(
    List<Map<String, int>> requestedShifts,
    List<MaidWorkplace> workplaces,
  ) {
    final busy = shiftsFromWorkplaces(workplaces);
    if (busy.isEmpty) return false;
    return shiftsOverlap(requestedShifts, busy);
  }

  static bool shiftsOverlap(
    List<Map<String, int>> a,
    List<Map<String, int>> b,
  ) {
    for (final left in a) {
      for (final right in b) {
        final aStart = left['start_time'] ?? 0;
        final aEnd = left['end_time'] ?? 0;
        final bStart = right['start_time'] ?? 0;
        final bEnd = right['end_time'] ?? 0;
        if (aStart < bEnd && bStart < aEnd) {
          return true;
        }
      }
    }
    return false;
  }

  static bool datesOverlap(Set<DateTime> a, Set<DateTime> b) {
    for (final left in a) {
      for (final right in b) {
        if (left.year == right.year &&
            left.month == right.month &&
            left.day == right.day) {
          return true;
        }
      }
    }
    return false;
  }

  /// True when an existing appointment blocks the proposed booking.
  static bool conflictsWithExisting({
    required Map<String, dynamic> existingData,
    required List<Map<String, int>> newShifts,
    required List<String> newDays,
    required DateTime newStartDate,
    required DateTime newEndDate,
    required String newCustomerType,
  }) {
    final status =
        (existingData[AppointmentFields.status] as String?)?.toLowerCase() ?? '';
    if (status == 'cancelled') return false;

    final existingType =
        (existingData[AppointmentFields.customerType] as String?) ?? 'Daily';
    final existingDays =
        (existingData[AppointmentFields.days] as List<dynamic>?)
            ?.map((d) => d.toString())
            .toList() ??
        <String>[];

    final existingStart =
        (existingData[AppointmentFields.startDate] as Timestamp?)?.toDate() ??
        DateTime.now();
    final existingEnd =
        (existingData[AppointmentFields.endDate] as Timestamp?)?.toDate() ??
        existingStart;

    final existingDates = expandBookingDates(
      customerType: existingType,
      days: existingDays,
      startDate: existingStart,
      endDate: existingEnd,
    );
    final newDates = expandBookingDates(
      customerType: newCustomerType,
      days: newDays,
      startDate: newStartDate,
      endDate: newEndDate,
    );

    if (!datesOverlap(existingDates, newDates)) return false;

    return shiftsOverlap(
      shiftsFromAppointmentData(existingData),
      newShifts,
    );
  }

  /// Builds a Firestore payload for a new appointment.
  static Map<String, dynamic> buildCreatePayload({
    required DocumentReference<Map<String, dynamic>> userRef,
    required String serviceType,
    required int budget,
    required int numberOfShifts,
    required List<Map<String, int>> shifts,
    required List<String> days,
    required Map<String, dynamic> details,
    required String building,
    required String flatNumber,
    required String state,
    required String customerType,
    required DateTime startDate,
    required DateTime endDate,
    String remark = '',
    DocumentReference<Map<String, dynamic>>? maidRef,
  }) {
    return {
      AppointmentFields.budget: budget,
      AppointmentFields.building: building,
      AppointmentFields.flatNumber: flatNumber,
      AppointmentFields.state: state,
      AppointmentFields.customerType: customerType,
      AppointmentFields.serviceType: serviceType,
      AppointmentFields.numberOfShifts: numberOfShifts,
      AppointmentFields.days: days,
      AppointmentFields.shifts: shifts,
      AppointmentFields.details: details,
      AppointmentFields.startDate: Timestamp.fromDate(startDate),
      AppointmentFields.endDate: Timestamp.fromDate(endDate),
      AppointmentFields.status: 'processing',
      AppointmentFields.maid: maidRef,
      AppointmentFields.user: userRef,
      AppointmentFields.transaction: null,
      AppointmentFields.remark: remark,
      AppointmentFields.completed: <dynamic>[],
    };
  }

  /// Normalizes a production appointment doc for [BookingScreen] UI.
  static Future<Map<String, dynamic>> toBookingViewModel({
    required String id,
    required Map<String, dynamic> data,
    required FirebaseFirestore firestore,
  }) async {
    final rawStatus = (data[AppointmentFields.status] as String?) ?? '';
    final remark = (data[AppointmentFields.remark] as String?) ?? '';
    final customerType =
        (data[AppointmentFields.customerType] as String?) ?? 'Daily';
    final shifts = data[AppointmentFields.shifts] as List<dynamic>?;
    final days = (data[AppointmentFields.days] as List<dynamic>?)
        ?.map((d) => d.toString())
        .toList();

    final timing = formatTimingFromShifts(shifts);
    final startTs =
        data[AppointmentFields.startDate] as Timestamp? ??
        data['Start Date'] as Timestamp?;
    final endTs =
        data[AppointmentFields.endDate] as Timestamp? ??
        data['End Date'] as Timestamp?;

    var maidName = 'Maid Name';
    var maidContact = '';
    var maidId = 'N/A';
    double rating = 4.0;

    final maidRef = data[AppointmentFields.maid];
    if (maidRef is DocumentReference) {
      try {
        final maidSnap = await maidRef.get();
        if (maidSnap.exists) {
          final maidData = maidSnap.data() as Map<String, dynamic>?;
          if (maidData != null) {
            maidName =
                (maidData['name'] as String?) ??
                (maidData['FullName'] as String?) ??
                maidName;
            maidContact =
                (maidData['phoneNumber'] as String?) ??
                (maidData['phone'] as String?) ??
                maidContact;
          }
          maidId = maidRef.id;
        }
      } catch (_) {}
    }

    final budget = data[AppointmentFields.budget];
    final salaryLabel = budget is num
        ? 'Rs. ${budget.toInt()}'
        : 'Rs. 0';

    final bookingType = customerType == 'Instant' ? 'Instant' : 'Daily';
    final timeType = customerType == 'Custom' ? 'Custom' : customerType;

    return {
      'id': id,
      'service':
          (data[AppointmentFields.serviceType] as String?) ?? 'N/A',
      'timing': timing,
      'salary': salaryLabel,
      'timeSlotData': {
        'TimeSlots': timing,
        'SelectedDays': days ?? <String>[],
      },
      'BookingDate': startTs,
      'contractEndDate': endTs,
      'Status': remark.contains('Backup Requested')
          ? 'Backup Requested'
          : _uiStatusFromFirestore(rawStatus),
      'firestoreStatus': rawStatus,
      'remark': remark,
      'BookingType': bookingType,
      'TimeType': timeType,
      'name': maidName,
      'contact': maidContact.isEmpty ? '—' : maidContact,
      'rating': rating,
      'maidId': maidId,
      'Maid': maidRef,
    };
  }

  static String _uiStatusFromFirestore(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'accepted':
        return 'Soon';
      case 'processing':
      default:
        return 'Soon';
    }
  }

  static int _timeStringToMinutes(String timeStr) {
    final trimmed = timeStr.trim();
    if (trimmed.isEmpty) return 0;

    try {
      final upper = trimmed.toUpperCase();
      final isPm = upper.contains('PM');
      final isAm = upper.contains('AM');
      final cleaned = trimmed
          .replaceAll(RegExp(r'[AP]M', caseSensitive: false), '')
          .trim();
      final segments = cleaned.split(':');
      var hour = int.parse(segments[0]);
      final minute = segments.length > 1 ? int.parse(segments[1]) : 0;

      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  static String _minutesToDisplay(int minutes) {
    final hour24 = minutes ~/ 60;
    final minute = minutes % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}
