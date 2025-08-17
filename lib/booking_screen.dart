import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/complaint_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/account_screen.dart';
import 'dart:async';
import 'dart:ui'; // Required for BackdropFilter
import 'package:superbai/maid_linking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavbarIndex = 1;
  bool _isLoading = false;
  String _loadingMessage = '';

  // --- State Management for Bookings ---
  List<Map<String, dynamic>> _activeBookings = [
    {
      'id': 1,
      'name': 'Jane Doe',
      'service': 'Cleaning',
      'contact': '9873724556',
      'salary': '2000/mon',
      'timing': '9am - 11am',
      'rating': 4.0,
      'maidId': '3231',
    },
  ];

  List<Map<String, dynamic>> _instantBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Loading Overlay Logic ---
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

  // --- Dialog and Page Logic ---

  // 1. Cancel Booking Flow
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

  void _showCancelDialog(int bookingId) {
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
                    onPressed: () {
                      Navigator.pop(dialogContext); // Close the dialog
                      setState(() {
                        _activeBookings.removeWhere(
                          (b) => b['id'] == bookingId,
                        );
                      });
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

  // 2. Reschedule Booking Flow
  void _showRescheduleDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _RescheduleDialog();
      },
    );

    if (result != null) {
      _showLoading('Searching for maid...');
      await Future.delayed(const Duration(seconds: 2));
      _hideLoading();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MaidLinkingScreen()),
        );
      }
    }
  }

  // 3. Replace Maid Flow
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

  // 4. Backup Maid Flow
  void _showBackupMaidDialog() {
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
        _showRescheduleDialogForBackup();
      }
    });
  }

  void _showRescheduleDialogForBackup() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const _RescheduleDialog();
      },
    );

    if (result != null) {
      _showLoading('Searching for maid...');
      await Future.delayed(const Duration(seconds: 2));
      _hideLoading();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MaidLinkingScreen()),
        );
        // Add new instant booking card after returning from linking screen
        setState(() {
          _instantBookings.add({
            'id': DateTime.now().millisecondsSinceEpoch,
            'name': 'Backup Maid',
            'service': 'Cleaning',
            'contact': '9876543210',
            'salary': '500/day',
            'timing':
                '${result['fromTime'].format(context)} - ${result['toTime'].format(context)}',
            'rating': 5.0,
            'maidId': 'INSTANT',
          });
          _tabController.animateTo(1);
        });
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
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _loadingMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.neutralWhite,
                          ),
                        ),
                      ],
                    ),
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
    final List<Map<String, String>> previousBookings = [
      {
        'name': 'Sophie T',
        'role': 'House Maid',
        'rating': '4.5',
        'date': '21 Aug 23',
        'duration': '2 months',
      },
      {
        'name': 'Jane Doe',
        'role': 'Cook',
        'rating': '4.0',
        'date': '05 May 23',
        'duration': '8 months',
      },
    ];

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
          if (_activeBookings.isEmpty)
            const Center(child: Text('No active bookings.'))
          else
            ..._activeBookings
                .map((booking) => _buildActiveBookingCard(booking))
                .toList(),
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previousBookings.length,
            itemBuilder: (context, index) {
              final booking = previousBookings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.secondaryPastelPurple,
                    backgroundImage: NetworkImage(
                      'https://placehold.co/80x80/${ColorHex(AppColors.secondaryPastelPurple).toHex().substring(1)}/${ColorHex(AppColors.primaryPurple).toHex().substring(1)}?text=${booking['name']![0]}',
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
                          double rating = double.parse(booking['rating']!);
                          return Icon(
                            Icons.star_rate_rounded,
                            color: starIndex < rating.floor()
                                ? AppColors.emotionYellow
                                : AppColors.neutralMediumGray,
                            size: 12,
                          );
                        }),
                      ),
                      Text(
                        booking['role']!,
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
                    children: [
                      Text(
                        booking['date']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        booking['duration']!,
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking) {
    bool isInstant = booking['maidId'] == 'INSTANT';
    return Column(
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
                          'https://placehold.co/100x100/FFFFFF/5D4EFF?text=${booking['name'][0]}',
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
                        _buildDetailRowAligned('Service', booking['service']),
                        _buildDetailRowAligned('Contact', booking['contact']),
                        _buildDetailRowAligned('Salary', booking['salary']),
                        _buildDetailRowAligned('Timing', booking['timing']),
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
                      _showRescheduleDialog,
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
              onPressed: _showBackupMaidDialog,
              icon: Icon(Icons.group, color: AppColors.neutralWhite, size: 24),
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
    );
  }

  Widget _buildInstantBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instant Booking',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          if (_instantBookings.isEmpty)
            const Center(child: Text('No instant bookings.'))
          else
            ..._instantBookings
                .map((booking) => _buildActiveBookingCard(booking))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRowAligned(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
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
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.neutralWhite,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
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

// Helper class for hex color conversion
extension ColorHex on Color {
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

// --- Reschedule Dialog Widget ---
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
                : "${selectedDate!.toLocal()}".split(' ')[0],
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
