import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/complaint_screen.dart'; // Assuming this exists for "File a Complaint"
import 'package:superbai/location_screen.dart'; // Import LocationScreen
import 'package:superbai/customer_care_screen.dart'; // Import CustomerCareScreen
import 'CouponScreen.dart';
import 'EditProfileScreen.dart';
import 'ReferMaidScreen.dart';
import 'TermsAndConditionsScreen.dart'; // Import the new EditProfileScreen

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedNavbarIndex = 3; // Default to 'Account' tab in navbar (index 3)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Column(
        children: [
          // Top Purple Section with Profile and Points
          Container(
            width: double.infinity,
            // Adjust padding to remove top header space, accounting for safe area
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              30,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              // Removed bottom curved edges
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35, // Slightly smaller radius
                      backgroundColor: AppColors.neutralWhite,
                      backgroundImage: NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwh1EKt_AqF35M7LTejJXysIIKQ31zWt3fzlX5-F5DoUDrhOxfeySO5E_lgNeIuTrWJKM&usqp=CAU',
                      ), // Placeholder for profile image
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Snow',
                          style: GoogleFonts.poppins(
                            fontSize: 20, // Slightly larger for name
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal, // Not bold
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ), // Adjusted padding
                          decoration: BoxDecoration(
                            color:
                                AppColors.neutralWhite, // Changed to white fill
                            borderRadius: BorderRadius.circular(
                              20,
                            ), // Fully curved
                            // Removed border: Border.all(color: AppColors.primaryPink, width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'My Points ',
                                style: GoogleFonts.poppins(
                                  fontSize: 14, // Increased font size
                                  color: AppColors.primaryPink, // Pink color
                                  fontWeight: FontWeight.normal, // Not bold
                                ),
                              ),
                              Text(
                                '350',
                                style: GoogleFonts.poppins(
                                  fontSize: 14, // Increased font size
                                  color: AppColors.primaryPink, // Pink color
                                  fontWeight:
                                      FontWeight.bold, // Bold for points number
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.monetization_on,
                                size: 18,
                                color: AppColors.emotionYellow,
                              ), // Gold coin icon
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      // Added GestureDetector to the arrow icon
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(), // Removed 'const' here
                          ),
                        );
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.neutralWhite,
                        size: 20,
                      ), // Arrow icon
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Spacing after purple header

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
                      // Navigate to the new CouponScreen
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
                      // Navigate to the new ReferMaidScreen
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
                      // Navigate to the new TermsAndConditionsScreen
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
                        SnackBar(content: Text('Settings clicked!')),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.logout,
                    text: 'Logout',
                    textColor:
                        AppColors.emotionOrangeRed, // Red color for Logout text
                    iconColor:
                        AppColors.emotionOrangeRed, // Red color for Logout icon
                    showArrow: false, // No arrow for Logout
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout clicked!')),
                      );
                    },
                  ),
                  const SizedBox(height: 20), // Spacing at the bottom
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
          } else if (index == 3) {
            // Already on AccountScreen, do nothing or show a snackbar
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Already on Account page')));
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
    Color? iconColor, // Added iconColor parameter
    bool showArrow = true, // Added showArrow parameter, default to true
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ), // Increased vertical padding
        // Removed Border(bottom: ...) to remove lines between elements
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? AppColors.primaryPurple,
            ), // Use iconColor or default to purple
            const SizedBox(width: 15), // Gap between icon and text
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14, // Small font size
                color:
                    textColor ??
                    AppColors
                        .primaryPurple, // Use provided color or default to purple
                fontWeight: FontWeight.normal, // Not bold
              ),
            ),
            const Spacer(),
            if (showArrow) // Conditionally display arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primaryPink,
              ), // Arrow icon color pink
          ],
        ),
      ),
    );
  }
}
