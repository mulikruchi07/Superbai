import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/complaint_screen.dart';
import 'package:superbai/location_screen.dart';
import 'package:superbai/customer_care_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CouponScreen.dart';
import 'EditProfileScreen.dart';
import 'ReferMaidScreen.dart';
import 'TermsAndConditionsScreen.dart';
import 'mobile_number_screen.dart'; // Import for logout navigation

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedNavbarIndex = 3; // Default to 'Account' tab
  String _userName = 'Loading...'; // State variable to hold the user's name
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches the logged-in user's full name from Firestore.
  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot userDoc = await _firestore
            .collection('DIM_USERS')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          setState(() {
            // Set the user name from the 'FullName' field in Firestore
            _userName = userDoc.get('FullName') ?? 'No Name';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = 'Error';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data: $e')),
          );
        }
      }
    }
  }

  /// Handles the user logout process.
  Future<void> _logout() async {
    await _auth.signOut();
    // Navigate back to the login screen and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MobileNumberScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Column(
        children: [
          // Top Purple Section with Profile and Points
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              30,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.neutralWhite,
                      backgroundImage: const NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwh1EKt_AqF35M7LTejJXysIIKQ31zWt3fzlX5-F5DoUDrhOxfeySO5E_lgNeIuTrWJKM&usqp=CAU',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the fetched user name here
                        Text(
                          _userName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutralWhite,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'My Points ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.primaryPink,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                '350',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.primaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.monetization_on,
                                size: 18,
                                color: AppColors.emotionYellow,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        // Navigate to EditProfileScreen and wait for a result.
                        // If the profile was updated, refresh the user data.
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          _fetchUserData(); // Refresh user data if name was changed
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.neutralWhite,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildAccountOption(
                    icon: Icons.location_on_outlined,
                    text: 'My Address',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.redeem_outlined,
                    text: 'Coupons',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CouponScreen()),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.people_outline,
                    text: 'Refer a Maid/Friend',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReferMaidScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.headset_mic_outlined,
                    text: 'Customer Care',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerCareScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.info_outline,
                    text: 'Terms & Conditions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.edit_note_outlined,
                    text: 'File a Complaint',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ComplaintScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.settings_outlined,
                    text: 'Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings clicked!')),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.logout,
                    text: 'Logout',
                    textColor: AppColors.emotionOrangeRed,
                    iconColor: AppColors.emotionOrangeRed,
                    showArrow: false,
                    onTap: _logout, // Call the logout function
                  ),
                  const SizedBox(height: 20),
                ],
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
          if (index == _selectedNavbarIndex)
            return; // Avoid redundant navigation
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
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BillScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.primaryPurple),
            const SizedBox(width: 15),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor ?? AppColors.primaryPurple,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primaryPink,
              ),
          ],
        ),
      ),
    );
  }
}
