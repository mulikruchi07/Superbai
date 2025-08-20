import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  int _selectedNavbarIndex = 2;
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final bookingSnapshot = await FirebaseFirestore.instance
          .collection('FACT_BOOKINGS')
          .where('UserID', isEqualTo: user.uid)
          .get();

      if (bookingSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      List<Map<String, dynamic>> fetchedBills = [];
      for (var bookingDoc in bookingSnapshot.docs) {
        final bookingData = bookingDoc.data();

        // **FIX**: Add checks for null IDs and status to prevent crashes.
        if (bookingData['Status'] == 'Cancelled' ||
            bookingData['Status'] == 'Backup Requested' ||
            bookingData['ServiceID'] == null ||
            bookingData['SalaryID'] == null ||
            bookingData['TimeSlotID'] == null ||
            bookingData['BookingDate'] == null) {
          continue; // Skip invalid or irrelevant bookings
        }

        final serviceDoc = await FirebaseFirestore.instance
            .collection('DIM_SERVICES')
            .doc(bookingData['ServiceID'])
            .get();
        final salaryDoc = await FirebaseFirestore.instance
            .collection('DIM_SALARY')
            .doc(bookingData['SalaryID'])
            .get();
        final timeSlotDoc = await FirebaseFirestore.instance
            .collection('DIM_TIME_SLOTS')
            .doc(bookingData['TimeSlotID'])
            .get();

        // **FIX**: Safely handle potentially null Timestamp.
        final paymentTimestamp = salaryDoc.data()?['PaymentDate'] as Timestamp?;
        final paymentDate = paymentTimestamp?.toDate() ?? DateTime.now();

        final bookingTimestamp = bookingData['BookingDate'] as Timestamp;

        final serviceEndTime = _getServiceEndTime(
          bookingTimestamp.toDate(),
          timeSlotDoc.data(),
        );
        final dueDate = serviceEndTime.subtract(const Duration(hours: 1));

        fetchedBills.add({
          'amount': salaryDoc.data()?['Amount'] ?? 0.0,
          'serviceName': serviceDoc.data()?['ServiceName'] ?? 'N/A',
          'maidName': 'Rani Obey', // Placeholder
          'maidId': '3545', // Placeholder
          'billMonth': DateFormat('MMM yyyy').format(paymentDate),
          'dueDate': dueDate,
          'dueDateString': _getDueDateString(dueDate),
        });
      }

      fetchedBills.sort((a, b) {
        final dueDateA = a['dueDate'] as DateTime;
        final dueDateB = b['dueDate'] as DateTime;
        final now = DateTime.now();

        final isAOverdue = dueDateA.isBefore(now);
        final isBOverdue = dueDateB.isBefore(now);

        if (isAOverdue && !isBOverdue) {
          return -1;
        } else if (!isAOverdue && isBOverdue) {
          return 1;
        } else {
          return dueDateA.compareTo(dueDateB);
        }
      });

      if (mounted) {
        setState(() {
          _bills = fetchedBills;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching bills: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime _getServiceEndTime(
    DateTime bookingDate,
    Map<String, dynamic>? timeSlotData,
  ) {
    if (timeSlotData == null) return bookingDate;

    final timeSlots = (timeSlotData['TimeSlots'] as String? ?? '').split(', ');
    if (timeSlots.isEmpty || timeSlots.first.isEmpty) return bookingDate;

    try {
      final endTimeStr = timeSlots.last.split(' - ')[1];
      int hour = int.parse(endTimeStr.split(':')[0]);
      final minute = int.parse(endTimeStr.split(':')[1].split(' ')[0]);
      if (endTimeStr.contains('PM') && hour != 12) {
        hour += 12;
      }
      if (endTimeStr.contains('AM') && hour == 12) {
        hour = 0;
      }
      return DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        hour,
        minute,
      );
    } catch (e) {
      return bookingDate;
    }
  }

  String _getDueDateString(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Bill is overdue';
    } else if (difference.inDays > 0) {
      return 'Bill due in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'Bill due in ${difference.inHours} hours';
    } else {
      return 'Bill due in ${difference.inMinutes} minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Bills',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
          ? Center(child: Text('No bills found.', style: GoogleFonts.poppins()))
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                return _BillCard(billData: _bills[index]);
              },
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedNavbarIndex == 0
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              color: _selectedNavbarIndex == 1
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt,
              color: _selectedNavbarIndex == 2
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedNavbarIndex == 3
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index;
          });
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingScreen()),
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
}

class _BillCard extends StatelessWidget {
  final Map<String, dynamic> billData;

  const _BillCard({required this.billData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill for ${billData['billMonth']}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryPurple, AppColors.primaryPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neutralMediumGray.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹ ${billData['amount'].toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total Charge for Maid Service',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pay Now clicked!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neutralWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'PAY NOW',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Maid : ${billData['maidName']} (${billData['maidId']})',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.neutralBlack,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          billData['billMonth'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.neutralBlack,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'For ${billData['serviceName']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      billData['dueDateString'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
