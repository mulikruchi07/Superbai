import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/account_screen.dart';
import 'package:superbai/select_service_screen.dart';
import 'dart:async';
import 'dart:ui'; // Required for BackdropFilter
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superbai/data/service_catalog.dart';
import 'package:superbai/exceptions/maid_slot_unavailable_exception.dart';
import 'package:superbai/repositories/appointment_repository.dart';
import 'package:superbai/widgets/preferred_time_picker.dart';
import 'package:superbai/data/whatsapp_messages.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  static const String _supportWhatsAppNumber = '919819293826';

  late TabController _tabController;
  int _selectedNavbarIndex = 1;
  bool _isLoading = true; // Master loading state for initial fetch
  List<Map<String, String>> get services =>
      ServiceCatalog.all.map((s) => s.toGridItem()).toList();

  List<Map<String, String>> get instantServices =>
      ServiceCatalog.instantBookable.map((s) => s.toGridItem()).toList();
  // --- State Management for Bookings ---
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _previousBookings = []; // For completed bookings
  StreamSubscription? _bookingSubscription;
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

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

  // Loads [Appointments] for the signed-in [User] profile (by phone / UID).
  void _fetchBookings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _bookingSubscription = _appointmentRepository
        .watchBookingsForAuthUser(user)
        .listen(
          (allBookings) {
            if (!mounted) return;
            _processAndSetBookings(allBookings);
            setState(() => _isLoading = false);
          },
          onError: (error) {
            if (kDebugMode) {
              debugPrint('Error fetching appointments: $error');
            }
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
    List<Map<String, dynamic>> previous = [];
    bool ongoingFound = false;
    bool upNextFound = false;

    for (final booking in allBookings) {
      String status = booking['Status'] as String? ?? 'Soon';
      final firestoreStatus =
          (booking['firestoreStatus'] as String?)?.toLowerCase() ?? '';

      if (firestoreStatus == 'completed') {
        booking['Status'] = 'Completed';
        previous.add(booking);
        continue;
      }

      if (status != 'Cancelled' && status != 'Backup Requested') {
        final startTime = _getBookingDateTime(booking);
        final endTime = _getBookingDateTime(booking, getEndTime: true);
        final now = DateTime.now();
        final bookingType = booking['BookingType'] as String? ?? 'Daily';
        final contractEndTs = booking['contractEndDate'] as Timestamp?;
        final contractEnded = contractEndTs != null &&
            now.isAfter(
              DateTime(
                contractEndTs.toDate().year,
                contractEndTs.toDate().month,
                contractEndTs.toDate().day,
              ).add(const Duration(days: 1)),
            );

        // Daily / maid-linked jobs stay active until the contract end date,
        // not when today's shift window has passed.
        final isOngoingContract =
            bookingType == 'Daily' &&
            firestoreStatus != 'completed' &&
            !contractEnded;

        if (contractEnded) {
          status = 'Completed';
        } else if (isOngoingContract) {
          if (now.isAfter(startTime) && now.isBefore(endTime)) {
            status = 'Ongoing';
            ongoingFound = true;
          } else if (ongoingFound && !upNextFound) {
            status = 'Up next';
            upNextFound = true;
          } else {
            status = 'Soon';
          }
        } else if (now.isAfter(endTime)) {
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
        // Daily + Instant bookings both show under Active (Daily tab).
        active.add(booking);
      }
    }

    if (!ongoingFound) {
      final nextActiveIndex = active.indexWhere((b) => b['Status'] == 'Soon');
      if (nextActiveIndex != -1) {
        active[nextActiveIndex]['Status'] = 'Up next';
      }
    }

    if (mounted) {
      setState(() {
        _activeBookings = active;
        _previousBookings = previous;
      });
    }
  }

  void _showLoading(String message) {
    setState(() => _isLoading = true);
  }

  void _hideLoading() {
    setState(() => _isLoading = false);
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
                      await _appointmentRepository.cancelAppointment(
                        bookingId,
                      );
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

  Future<void> _openSupportWhatsApp(String messageText) async {
    final message = Uri.encodeComponent(messageText);
    final appUri = Uri.parse(
      'whatsapp://send?phone=$_supportWhatsAppNumber&text=$message',
    );
    final webUri = Uri.parse(
      'https://wa.me/$_supportWhatsAppNumber?text=$message',
    );

    try {
      final openedApp = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) return;

      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        _showMessage('Could not open WhatsApp.');
      }
    } catch (_) {
      if (!mounted) return;
      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        _showMessage('Could not open WhatsApp.');
      }
    }
  }

  Future<void> _launchFlexibilityWhatsApp(Map<String, dynamic> booking) async {
    final bookingDateTime = _getBookingDateTime(booking);
    final serviceDate = DateFormat('dd MMM yyyy').format(bookingDateTime);
    final currentServiceTime = booking['timing'] as String?;

    await _openSupportWhatsApp(
      WhatsAppMessages.flexibility(
        serviceDate: serviceDate,
        currentServiceTime: currentServiceTime,
      ),
    );
  }

  Future<void> _launchComplaintWhatsApp(Map<String, dynamic> booking) async {
    await _openSupportWhatsApp(WhatsAppMessages.complaint());
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _launchReplaceWhatsApp(Map<String, dynamic> booking) async {
    final maidName = (booking['name'] as String?)?.trim();
    final service = booking['service'] as String?;
    final timeSlot = booking['timing'] as String?;

    await _openSupportWhatsApp(
      WhatsAppMessages.replaceMaid(
        maidName: maidName?.isNotEmpty == true ? maidName : null,
        service: service?.isNotEmpty == true ? service : null,
        timeSlot: timeSlot?.isNotEmpty == true ? timeSlot : null,
      ),
    );
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
        _showFlexibilityDialogForBackup(originalBooking);
      }
    });
  }

  void _showFlexibilityDialogForBackup(
    Map<String, dynamic> originalBooking,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _FlexibilityDialog();
      },
    );

    if (result != null && mounted) {
      _showLoading('Searching for backup maid...');
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final timeSlotLabel =
            '${(result['fromTime'] as TimeOfDay).format(context)} - ${(result['toTime'] as TimeOfDay).format(context)}';

        await _appointmentRepository.createBackupAppointment(
          authUser: user,
          originalBooking: originalBooking,
          date: result['date'] as DateTime,
          timeSlotLabel: timeSlotLabel,
        );

        if (mounted) {
          _hideLoading();
          _tabController.animateTo(1);
        }
      } on MaidSlotUnavailableException catch (e) {
        if (mounted) {
          _hideLoading();
          _showMessage(e.message);
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
              ? _buildEmptyBookingState(
                  icon: Icons.event_available_outlined,
                  title: 'No active bookings',
                  subtitle:
                      'Book a maid from Home and your upcoming schedule will appear here.',
                )
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
              ? _buildEmptyBookingState(
                  icon: Icons.history,
                  title: 'No previous bookings',
                  subtitle: 'Completed and past bookings will show up here.',
                )
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
    // Instant tab is book-only: Cleaning + Cooking cards (no booking cards here).
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Services',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.neutralBlack,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: instantServices.length,
              itemBuilder: (context, index) {
                final service = instantServices[index];

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectServiceScreen(
                          initialServiceTitle: service['name']!,
                          isInstantBooking: true,
                        ),
                      ),
                    );
                    if (!mounted) return;
                    // Show new instant booking under Active (Daily tab).
                    _tabController.animateTo(0);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutralMediumGray.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          service['image']!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          service['name']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.neutralBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBookingState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.neutralDarkGray),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralBlack,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.neutralDarkGray,
            ),
          ),
        ],
      ),
    );
  }

  String _maidInitial(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  String _friendlyStatusLabel(String status) {
    switch (status.trim().toLowerCase()) {
      case 'soon':
        return 'Starting soon';
      case 'backup requested':
        return 'Backup requested';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Widget _buildMaidAvatar(
    String name, {
    double radius = 28,
    bool onLightBackground = false,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: onLightBackground
          ? AppColors.primaryPurple.withOpacity(0.1)
          : AppColors.neutralWhite,
      child: Text(
        _maidInitial(name),
        style: GoogleFonts.poppins(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryPurple,
        ),
      ),
    );
  }

  Widget _buildRatingRow(
    double rating, {
    Color? emptyStarColor,
    double starSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (starIndex) {
          return Icon(
            Icons.star_rate_rounded,
            color: starIndex < rating
                ? AppColors.emotionYellow
                : (emptyStarColor ?? AppColors.neutralMediumGray),
            size: starSize,
          );
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: emptyStarColor ?? AppColors.neutralDarkGray,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingStatusBadge(String status) {
    Color background;
    Color textColor = AppColors.neutralWhite;

    switch (status.trim().toLowerCase()) {
      case 'backup requested':
        background = AppColors.emotionOrangeRed;
        break;
      case 'cancelled':
        background = AppColors.neutralDarkGray;
        break;
      case 'completed':
        background = AppColors.emotionGreen;
        break;
      default:
        background = AppColors.neutralWhite.withOpacity(0.22);
        textColor = AppColors.neutralWhite;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _friendlyStatusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking) {
    bool isInstant = booking['BookingType'] == 'Instant';
    final bookingDateTime = _getBookingDateTime(booking);
    final dateString = DateFormat('dd MMM yyyy').format(bookingDateTime);
    final maidName = (booking['name'] as String?)?.trim().isNotEmpty == true
        ? booking['name'] as String
        : 'Your helper';
    final rating = booking['rating'] as double? ?? 4.0;
    final status = (booking['Status'] as String?) ?? 'Starting soon';
    final service = booking['service'] as String? ?? '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildMaidAvatar(maidName),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            maidName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppColors.neutralWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildRatingRow(
                            rating,
                            emptyStarColor: AppColors.neutralWhite.withOpacity(
                              0.45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBookingStatusBadge(status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRowAligned(
                        'Service',
                        service,
                        isMultiLine: service.startsWith('All-rounder'),
                      ),
                      _buildDetailRowAligned(
                        'Contact',
                        booking['contact'] as String? ?? '—',
                      ),
                      _buildDetailRowAligned(
                        'Budget',
                        booking['salary'] as String? ?? '—',
                      ),
                      _buildDetailRowAligned('Starts', dateString),
                      _buildDetailRowAligned(
                        'Timing',
                        booking['timing'] as String? ?? '—',
                        isMultiLine: true,
                      ),
                    ],
                  ),
                ),
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
                    if (!isInstant) ...[
                      _buildOutlineButton(
                        'Flexibility',
                        Icons.calendar_today_outlined,
                        () => _launchFlexibilityWhatsApp(booking),
                      ),
                      _buildOutlineButton(
                        'Replace',
                        Icons.loop,
                        () => _launchReplaceWhatsApp(booking),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!isInstant) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _launchComplaintWhatsApp(booking),
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
    final dateString = DateFormat('dd MMM yyyy').format(serviceDate);
    final duration = booking['TimeType'] == 'Custom' ? 'One day' : 'Monthly';
    final maidName = (booking['name'] as String?)?.trim().isNotEmpty == true
        ? booking['name'] as String
        : 'Your helper';
    final rating = booking['rating'] as double? ?? 4.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutralMediumGray),
        ),
        child: Row(
          children: [
            _buildMaidAvatar(
              maidName,
              radius: 24,
              onLightBackground: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maidName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.neutralBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildRatingRow(rating, starSize: 12),
                  const SizedBox(height: 4),
                  Text(
                    booking['service'] as String? ?? '—',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.neutralDarkGray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateString,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.neutralDarkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    duration,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.neutralDarkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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

class _FlexibilityDialog extends StatefulWidget {
  const _FlexibilityDialog();

  @override
  __FlexibilityDialogState createState() => __FlexibilityDialogState();
}

class __FlexibilityDialogState extends State<_FlexibilityDialog> {
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
        'Flexibility Booking',
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
            label: fromTime == null
                ? 'From Time'
                : SuperbaiTimePicker.format(fromTime!),
            icon: Icons.access_time,
            hasError: fromTimeError,
            onTap: () async {
              final picked = await SuperbaiTimePicker.show(
                context,
                initialTime: fromTime,
                title: 'Select start time',
              );
              if (picked != null) {
                setState(() => fromTime = picked);
              }
            },
          ),
          if (fromTimeError) _buildErrorText('Please select a from time'),
          const SizedBox(height: 10),
          _buildDateTimePicker(
            label: toTime == null
                ? 'To Time'
                : SuperbaiTimePicker.format(toTime!),
            icon: Icons.access_time,
            hasError: toTimeError,
            onTap: () async {
              final picked = await SuperbaiTimePicker.show(
                context,
                initialTime: toTime,
                title: 'Select end time',
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
