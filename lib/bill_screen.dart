import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart'; // For navigation
import 'package:superbai/booking_screen.dart'; // For navigation
import 'package:superbai/account_screen.dart'; // Import AccountScreen

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  int _selectedNavbarIndex = 2; // Default to 'Bill' tab in navbar (index 2)

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
            // Navigate back to the DashboardScreen and clear the navigation stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // This condition removes all previous routes
            );
          },
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Bill',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal, // Not bold
              ),
            ),
            const SizedBox(height: 15),
            // Main Container surrounding Current Bill Card and Maid details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0), // Padding inside this container
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1), // Transparent light purple
                borderRadius: BorderRadius.circular(10), // Little curve
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Bill Card (inside the main container)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primaryPink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10), // Little curve
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
                          '₹ 2000', // Example amount
                          style: GoogleFonts.poppins(
                            fontSize: 32, // Large font size
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.w600, // Semi-bold
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
                                SnackBar(content: Text('Pay Now clicked!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neutralWhite, // White background
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Little curve
                              ),
                            ),
                            child: Text(
                              'PAY NOW',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.neutralBlack, // Black text
                                fontWeight: FontWeight.normal, // Not bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing between bill card and maid details
                  // Maid details section (inside the main container)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Maid : Rani Obey (3545)',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            'Aug 2023', // Example date
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
                        'For Cleaning',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.w500, // Semi-bold as per image
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Bill due in 2 days',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red, // Changed to red
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(), // Pushes content up and navbar down
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDarkGray,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavbarIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedNavbarIndex == 0 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: _selectedNavbarIndex == 1 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, color: _selectedNavbarIndex == 2 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedNavbarIndex == 3 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index;
          });
          // Handle navigation
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
            // Already on BillScreen, do nothing or show a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Already on Bill page')),
            );
          } else if (index == 3) {
            Navigator.pushReplacement( // Navigate to AccountScreen
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
      ),
    );
  }
}
