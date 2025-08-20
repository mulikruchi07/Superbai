import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/complaint_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/account_screen.dart';
import 'dart:async';
import 'dart:ui'; // Required for BackdropFilter
import 'package:superbai/maid_linking_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavbarIndex = 1;
  bool _isLoading = true; // Master loading state for initial fetch
  String _loadingMessage = '';

  // --- State Management for Bookings ---
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _instantBookings = [];
  List<Map<String, dynamic>> _previousBookings = []; // For completed bookings
  StreamSubscription? _bookingSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _fetchBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookingSubscription?.cancel();
    super.dispose();
  }

  // Fetches and processes bookings efficiently.
  void _fetchBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // NOTE: This query requires a composite index in Firestore.
    // Please create an index on 'UserID' (ascending) and 'Status' (ascending)
    // for the 'FACT_BOOKINGS' collection.
    final query = FirebaseFirestore.instance
        .collection('FACT_BOOKINGS')
        .where('UserID', isEqualTo: user.uid)
        .where('Status', isNotEqualTo: 'Cancelled');

    _bookingSubscription = query.snapshots().listen(
      (snapshot) async {
        if (!mounted) return;
        if (snapshot.docs.isEmpty) {
          _processAndSetBookings([]);
          if (mounted) setState(() => _isLoading = false);
          return;
        }

        List<Map<String, dynamic>> bookingsData = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        // **FIX**: Filter out null IDs to prevent crashes during batch fetching.
        final serviceIds = bookingsData
            .map((b) => b['ServiceID'] as String?)
            .where((id) => id != null)
            .toSet()
            .toList();
        final timeSlotIds = bookingsData
            .map((b) => b['TimeSlotID'] as String?)
            .where((id) => id != null)
            .toSet()
            .toList();
        final salaryIds = bookingsData
            .map((b) => b['SalaryID'] as String?)
            .where((id) => id != null)
            .toSet()
            .toList();

        // Fetch related documents in parallel using 'whereIn'
        final serviceDocsFuture = serviceIds.isNotEmpty
            ? FirebaseFirestore.instance
                  .collection('DIM_SERVICES')
                  .where(FieldPath.documentId, whereIn: serviceIds)
                  .get()
            : Future.value(null);
        final timeSlotDocsFuture = timeSlotIds.isNotEmpty
            ? FirebaseFirestore.instance
                  .collection('DIM_TIME_SLOTS')
                  .where(FieldPath.documentId, whereIn: timeSlotIds)
                  .get()
            : Future.value(null);
        final salaryDocsFuture = salaryIds.isNotEmpty
            ? FirebaseFirestore.instance
                  .collection('DIM_SALARY')
                  .where(FieldPath.documentId, whereIn: salaryIds)
                  .get()
            : Future.value(null);

        final results = await Future.wait([
          serviceDocsFuture,
          timeSlotDocsFuture,
          salaryDocsFuture,
        ]);

        final serviceDocs = results[0] as QuerySnapshot<Map<String, dynamic>>?;
        final timeSlotDocs = results[1] as QuerySnapshot<Map<String, dynamic>>?;
        final salaryDocs = results[2] as QuerySnapshot<Map<String, dynamic>>?;

        // Create maps for efficient O(1) lookup
        final serviceMap = {
          for (var doc in serviceDocs?.docs ?? []) doc.id: doc.data(),
        };
        final timeSlotMap = {
          for (var doc in timeSlotDocs?.docs ?? []) doc.id: doc.data(),
        };
        final salaryMap = {
          for (var doc in salaryDocs?.docs ?? []) doc.id: doc.data(),
        };

        // Combine booking data with the fetched related data
        List<Map<String, dynamic>> allBookings = [];
        for (var bookingData in bookingsData) {
          // **FIX**: Skip incomplete booking records to prevent errors.
          if (bookingData['ServiceID'] == null ||
              bookingData['TimeSlotID'] == null ||
              bookingData['SalaryID'] == null) {
            continue;
          }

          final service = serviceMap[bookingData['ServiceID']];
          final timeSlot = timeSlotMap[bookingData['TimeSlotID']];
          final salary = salaryMap[bookingData['SalaryID']];

          allBookings.add({
            ...bookingData,
            'service': service?['ServiceName'] ?? 'N/A',
            'timing': timeSlot?['TimeSlots'] ?? 'N/A',
            'salary': 'Rs. ${salary?['Amount']?.toInt() ?? 0}',
            'timeSlotData': timeSlot,
            'name': 'Maid Name', // Placeholder
            'contact': '9876543210', // Placeholder
            'rating': 4.0, // Placeholder
            'maidId': bookingData['MaidID'] ?? 'N/A',
          });
        }

        _processAndSetBookings(allBookings);
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      onError: (error) {
        debugPrint("Error fetching bookings: $error");
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  DateTime _getBookingDateTime(
    Map<String, dynamic> booking, {
    bool getEndTime = false,
  }) {
    final timeSlotData = booking['timeSlotData'] as Map<String, dynamic>?;
    final bookingTimestamp = booking['BookingDate'] as Timestamp?;

    // **FIX**: Handle null booking date gracefully.
    if (timeSlotData == null || bookingTimestamp == null) return DateTime(1970);

    final timeSlots = (timeSlotData['TimeSlots'] as String? ?? '').split(', ');
    if (timeSlots.isEmpty || timeSlots.first.isEmpty) {
      return bookingTimestamp.toDate();
    }

    DateTime datePart;
    if ((timeSlotData['SelectedDays'] as List?)?.isNotEmpty ?? false) {
      try {
        datePart = DateFormat(
          'd/M/yyyy',
        ).parse((timeSlotData['SelectedDays'] as List).first);
      } catch (e) {
        datePart = bookingTimestamp.toDate();
      }
    } else {
      datePart = bookingTimestamp.toDate();
    }

    try {
      final timeStr = getEndTime
          ? timeSlots.last.split(' - ')[1]
          : timeSlots.first.split(' - ')[0];
      int hour = int.parse(timeStr.split(':')[0]);
      final minute = int.parse(timeStr.split(':')[1].split(' ')[0]);
      if (timeStr.contains('PM') && hour != 12) {
        hour += 12;
      }
      if (timeStr.contains('AM') && hour == 12) {
        hour = 0; // Midnight case
      }
      return DateTime(
        datePart.year,
        datePart.month,
        datePart.day,
        hour,
        minute,
      );
    } catch (e) {
      return datePart;
    }
  }

  void _processAndSetBookings(List<Map<String, dynamic>> allBookings) {
    allBookings.sort(
      (a, b) => _getBookingDateTime(b).compareTo(_getBookingDateTime(a)),
    );

    List<Map<String, dynamic>> active = [];
    List<Map<String, dynamic>> instant = [];
    List<Map<String, dynamic>> previous = [];
    bool ongoingFound = false;
    bool upNextFound = false;

    for (final booking in allBookings) {
      String status = booking['Status'];

      if (status != 'Cancelled' && status != 'Backup Requested') {
        final startTime = _getBookingDateTime(booking);
        final endTime = _getBookingDateTime(booking, getEndTime: true);
        final now = DateTime.now();

        if (now.isAfter(endTime)) {
          status = 'Completed';
        } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
          status = 'Ongoing';
          ongoingFound = true;
        } else if (ongoingFound && !upNextFound) {
          status = 'Up next';
          upNextFound = true;
        } else {
          status = 'Soon';
        }
      }
      booking['Status'] = status;

      if (status == 'Completed') {
        previous.add(booking);
      } else if (status != 'Cancelled' && status != 'Backup Requested') {
        if (booking['BookingType'] == 'Instant') {
          instant.add(booking);
        } else {
          active.add(booking);
        }
      }
    }

    if (!ongoingFound) {
      final nextActiveIndex = active.indexWhere((b) => b['Status'] == 'Soon');
      if (nextActiveIndex != -1) {
        active[nextActiveIndex]['Status'] = 'Up next';
      }
      final nextInstantIndex = instant.indexWhere((b) => b['Status'] == 'Soon');
      if (nextInstantIndex != -1) {
        instant[nextInstantIndex]['Status'] = 'Up next';
      }
    }

    if (mounted) {
      setState(() {
        _activeBookings = active;
        _instantBookings = instant;
        _previousBookings = previous;
      });
    }
  }

  void _showLoading(String message) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
      _loadingMessage = '';
    });
  }

  void _showCancelSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                'Successfully Cancelled!',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(String bookingId) {
    TextEditingController reasonController = TextEditingController();
    bool showReasonField = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.neutralWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Confirm Cancellation',
                style: GoogleFonts.poppins(
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              content: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showReasonField)
                      Text(
                        'Are you sure you want to cancel the booking?',
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralDarkGray,
                          fontSize: 14,
                        ),
                      ),
                    if (showReasonField)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reason to cancel (optional)',
                            style: GoogleFonts.poppins(
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter your reason here...',
                              filled: true,
                              fillColor: AppColors.neutralWhite,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.neutralMediumGray,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                if (!showReasonField) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'No',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        showReasonField = true;
                      });
                    },
                    child: Text(
                      'Yes',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
                if (showReasonField)
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      await FirebaseFirestore.instance
                          .collection('FACT_BOOKINGS')
                          .doc(bookingId)
                          .update({'Status': 'Cancelled'});
                      _showCancelSuccessDialog();
                    },
                    child: Text(
                      'OK',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRescheduleDialog(String bookingId, String timeSlotId) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _RescheduleDialog();
      },
    );

    if (result != null && mounted) {
      _showLoading('Rescheduling booking...');
      try {
        final newTimeSlots =
            '${(result['fromTime'] as TimeOfDay).format(context)} - ${(result['toTime'] as TimeOfDay).format(context)}';
        final newDate = result['date'] as DateTime;
        final newDateString = DateFormat('d/M/yyyy').format(newDate);

        final newTimeSlotDoc = await FirebaseFirestore.instance
            .collection('DIM_TIME_SLOTS')
            .add({
              'TimeSlots': newTimeSlots,
              'SelectedDays': [newDateString],
              'NumberOfShifts': 1,
            });

        await FirebaseFirestore.instance
            .collection('FACT_BOOKINGS')
            .doc(bookingId)
            .update({
              'BookingDate': Timestamp.fromDate(newDate),
              'TimeSlotID': newTimeSlotDoc.id,
            });

        if (mounted) {
          setState(() {
            int index = _activeBookings.indexWhere((b) => b['id'] == bookingId);
            if (index != -1) {
              final updatedBooking = Map<String, dynamic>.from(
                _activeBookings[index],
              );

              updatedBooking['timing'] = newTimeSlots;
              updatedBooking['BookingDate'] = Timestamp.fromDate(newDate);
              updatedBooking['TimeSlotID'] = newTimeSlotDoc.id;

              final updatedTimeSlotData = Map<String, dynamic>.from(
                updatedBooking['timeSlotData'] ?? {},
              );
              updatedTimeSlotData['TimeSlots'] = newTimeSlots;
              updatedTimeSlotData['SelectedDays'] = [newDateString];
              updatedBooking['timeSlotData'] = updatedTimeSlotData;

              _activeBookings[index] = updatedBooking;
            }
          });
        }
      } catch (e) {
        debugPrint("Error rescheduling booking: $e");
      } finally {
        if (mounted) {
          _hideLoading();
        }
      }
    }
  }

  void _showReplaceDialog() {
    String? selectedReason;
    final reasons = ['Time issue', 'Price issue', 'Service issue', 'Other'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Reason to Replace',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: AppColors.neutralBlack,
            ),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedReason,
            hint: Text(
              'Select a reason',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            onChanged: (value) {
              selectedReason = value;
            },
            items: reasons.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedReason != null) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(
                'Next',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
        );
      },
    ).then((success) {
      if (success == true) {
        _showLoading('Assigning new maid...');
        Future.delayed(const Duration(seconds: 2), () {
          _hideLoading();
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MaidLinkingScreen(),
              ),
            );
          }
        });
      }
    });
  }

  void _showBackupMaidDialog(Map<String, dynamic> originalBooking) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Confirm Leave',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: AppColors.neutralBlack,
            ),
          ),
          content: Text(
            'Are you sure your maid is on leave?',
            style: GoogleFonts.poppins(
              color: AppColors.neutralDarkGray,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'No',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Yes',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _showRescheduleDialogForBackup(originalBooking);
      }
    });
  }

  void _showRescheduleDialogForBackup(
    Map<String, dynamic> originalBooking,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _RescheduleDialog();
      },
    );

    if (result != null && mounted) {
      _showLoading('Searching for backup maid...');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final newTimeSlotDoc = await FirebaseFirestore.instance
            .collection('DIM_TIME_SLOTS')
            .add({
              'NumberOfShifts': 1,
              'TimeSlots':
                  '${(result['fromTime'] as TimeOfDay).format(context)} - ${(result['toTime'] as TimeOfDay).format(context)}',
              'SelectedDays': [DateFormat('d/M/yyyy').format(result['date'])],
            });

        final newSalaryDoc = await FirebaseFirestore.instance
            .collection('DIM_SALARY')
            .add({
              'Amount': 500.0,
              'PaymentDate': Timestamp.fromDate(result['date']),
            });

        await FirebaseFirestore.instance.collection('FACT_BOOKINGS').add({
          'UserID': user.uid,
          'MaidID': null,
          'ServiceID': originalBooking['ServiceID'],
          'TimeSlotID': newTimeSlotDoc.id,
          'SalaryID': newSalaryDoc.id,
          'BookingDate': Timestamp.fromDate(result['date']),
          'TimeType': 'Custom',
          'Status': 'Up next',
          'BookingType': 'Instant',
        });

        await FirebaseFirestore.instance
            .collection('FACT_BOOKINGS')
            .doc(originalBooking['id'])
            .update({'Status': 'Backup Requested'});

        if (mounted) {
          _hideLoading();
          _tabController.animateTo(1);
        }
      } catch (e) {
        if (mounted) _hideLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          'My Booking',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 0.0,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.neutralWhite,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _tabController.index = 0),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Daily',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: _tabController.index == 0
                                        ? AppColors.primaryPurple
                                        : AppColors.neutralDarkGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 25,
                            color: AppColors.neutralMediumGray,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _tabController.index = 1),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'Instant',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: _tabController.index == 1
                                        ? AppColors.primaryPurple
                                        : AppColors.neutralDarkGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      color: AppColors.neutralMediumGray,
                      margin: const EdgeInsets.only(top: 0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyBookingTab(),
                    _buildInstantBookingTab(),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDarkGray,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavbarIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Bill'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        onTap: (index) {
          setState(() => _selectedNavbarIndex = index);
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BillScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDailyBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Booking',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading && _activeBookings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _activeBookings.isEmpty
              ? const Center(child: Text('No active bookings.'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeBookings.length,
                  itemBuilder: (context, index) {
                    return _buildActiveBookingCard(_activeBookings[index]);
                  },
                ),
          const SizedBox(height: 25),
          Text(
            'Previous Bookings',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          _isLoading && _previousBookings.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _previousBookings.isEmpty
              ? const Center(child: Text('No previous bookings.'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _previousBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _previousBookings[index];
                    return _buildPreviousBookingCard(booking);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildInstantBookingTab() {
    return _isLoading && _instantBookings.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _buildBookingList(_instantBookings);
  }

  Widget _buildBookingList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Text('No bookings found.', style: GoogleFonts.poppins()),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return _buildActiveBookingCard(bookings[index]);
      },
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking) {
    bool isInstant = booking['BookingType'] == 'Instant';
    final bookingDateTime = _getBookingDateTime(booking);
    final dateString = DateFormat('dd MMM yyyy').format(bookingDateTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralMediumGray.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.neutralWhite,
                          backgroundImage: NetworkImage(
                            'https://placehold.co/100x100/FFFFFF/5D4EFF?text=${(booking['name'] as String).isNotEmpty ? (booking['name'] as String)[0] : ''}',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star_rate_rounded,
                              color: starIndex < (booking['rating'] as double)
                                  ? AppColors.emotionYellow
                                  : AppColors.neutralWhite.withOpacity(0.5),
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: ${booking['maidId']}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRowAligned('Name', booking['name']),
                          _buildDetailRowAligned(
                            'Service',
                            booking['service'],
                            isMultiLine: booking['service'].startsWith(
                              'All-rounder',
                            ),
                          ),
                          _buildDetailRowAligned('Contact', booking['contact']),
                          _buildDetailRowAligned('Salary', booking['salary']),
                          _buildDetailRowAligned('Date', dateString),
                          _buildDetailRowAligned(
                            'Timing',
                            booking['timing'],
                            isMultiLine: true,
                          ),
                          _buildDetailRowAligned(
                            'Status',
                            booking['Status'] ?? 'Loading...',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isInstant) ...[
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildOutlineButton(
                        'Cancel',
                        Icons.close,
                        () => _showCancelDialog(booking['id']),
                      ),
                      _buildOutlineButton(
                        'Reschedule',
                        Icons.calendar_today_outlined,
                        () => _showRescheduleDialog(
                          booking['id'],
                          booking['TimeSlotID'],
                        ),
                      ),
                      _buildOutlineButton(
                        'Replace',
                        Icons.loop,
                        _showReplaceDialog,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!isInstant) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComplaintScreen(),
                  ),
                ),
                icon: Icon(
                  Icons.edit_note_outlined,
                  color: AppColors.neutralBlack,
                  size: 18,
                ),
                label: Text(
                  'File a Complaint',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.neutralBlack,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showBackupMaidDialog(booking),
                icon: Icon(
                  Icons.group,
                  color: AppColors.neutralWhite,
                  size: 24,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get a Backup Maid',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralWhite,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.neutralWhite,
                      size: 14,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.neutralWhite,
                      size: 14,
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviousBookingCard(Map<String, dynamic> booking) {
    final serviceDate = _getBookingDateTime(booking);
    final dateString = DateFormat('dd MMM yy').format(serviceDate);
    final duration = booking['TimeType'] == 'Custom' ? 'One day' : 'One month';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.secondaryPastelPurple,
          backgroundImage: NetworkImage(
            'https://placehold.co/80x80/${ColorHex(AppColors.secondaryPastelPurple).toHex().substring(3)}/${ColorHex(AppColors.primaryPurple).toHex().substring(3)}?text=${(booking['name'] as String).isNotEmpty ? (booking['name'] as String)[0] : ''}',
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['name']!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (starIndex) {
                return Icon(
                  Icons.star_rate_rounded,
                  color: starIndex < (booking['rating'] as double)
                      ? AppColors.emotionYellow
                      : AppColors.neutralMediumGray,
                  size: 12,
                );
              }),
            ),
            Text(
              booking['service']!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.neutralDarkGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateString,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.neutralDarkGray,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              duration,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.neutralDarkGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowAligned(
    String label,
    String value, {
    bool isMultiLine = false,
  }) {
    Widget valueWidget;

    if (isMultiLine) {
      List<String> items;
      if (label == 'Service' && value.startsWith('All-rounder')) {
        items = value
            .replaceAll('All-rounder (', '')
            .replaceAll(')', '')
            .split(', ');
      } else {
        items = value.split(', ').where((s) => s.isNotEmpty).toList();
      }

      valueWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Text(
                item.trim(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.neutralWhite,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
            .toList(),
      );
    } else {
      valueWidget = Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.neutralWhite,
          fontWeight: FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.neutralWhite,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.neutralWhite,
              fontWeight: FontWeight.normal,
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.neutralWhite,
        side: BorderSide(color: AppColors.primaryPurple, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, color: AppColors.neutralBlack, size: 18),
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: AppColors.neutralBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

extension ColorHex on Color {
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class _RescheduleDialog extends StatefulWidget {
  const _RescheduleDialog();

  @override
  __RescheduleDialogState createState() => __RescheduleDialogState();
}

class __RescheduleDialogState extends State<_RescheduleDialog> {
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  bool dateError = false;
  bool fromTimeError = false;
  bool toTimeError = false;
  String? timeValidationError;

  void _validateAndSubmit() {
    setState(() {
      dateError = selectedDate == null;
      fromTimeError = fromTime == null;
      toTimeError = toTime == null;
      timeValidationError = null;

      if (!dateError && !fromTimeError && !toTimeError) {
        final selectedDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          fromTime!.hour,
          fromTime!.minute,
        );
        if (selectedDateTime.isBefore(
          DateTime.now().add(const Duration(hours: 12)),
        )) {
          timeValidationError = 'Cannot be selected within next 12 hrs.';
        } else {
          Navigator.pop(context, {
            'date': selectedDate,
            'fromTime': fromTime,
            'toTime': toTime,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Reschedule Booking',
        style: GoogleFonts.poppins(fontWeight: FontWeight.normal, fontSize: 16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateTimePicker(
            label: selectedDate == null
                ? 'Select Date'
                : DateFormat('dd/MM/yyyy').format(selectedDate!),
            icon: Icons.calendar_today,
            hasError: dateError,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: GoogleFonts.poppinsTextTheme(
                        Theme.of(context).textTheme,
                      ).apply(bodyColor: Colors.black),
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryPurple,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
          ),
          if (dateError) _buildErrorText('Please select a date'),
          const SizedBox(height: 10),
          _buildDateTimePicker(
            label: fromTime == null ? 'From Time' : fromTime!.format(context),
            icon: Icons.access_time,
            hasError: fromTimeError,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: GoogleFonts.poppinsTextTheme(
                        Theme.of(context).textTheme,
                      ),
                      timePickerTheme: TimePickerThemeData(
                        hourMinuteTextStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                        dayPeriodTextStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => fromTime = picked);
              }
            },
          ),
          if (fromTimeError) _buildErrorText('Please select a from time'),
          const SizedBox(height: 10),
          _buildDateTimePicker(
            label: toTime == null ? 'To Time' : toTime!.format(context),
            icon: Icons.access_time,
            hasError: toTimeError,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: GoogleFonts.poppinsTextTheme(
                        Theme.of(context).textTheme,
                      ),
                      timePickerTheme: TimePickerThemeData(
                        hourMinuteTextStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                        dayPeriodTextStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => toTime = picked);
              }
            },
          ),
          if (toTimeError) _buildErrorText('Please select a to time'),
          if (timeValidationError != null)
            _buildErrorText(timeValidationError!),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _validateAndSubmit, child: const Text('Next')),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool hasError = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.neutralMediumGray,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: hasError ? Colors.red : AppColors.primaryPurple,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            Icon(icon, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }
}
