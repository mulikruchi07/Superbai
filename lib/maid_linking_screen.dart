import 'package:flutter/material.dart';
import 'package:superbai/salary_screen.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart'; // Import DashboardScreen
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'dart:math'; // Import for min function

class MaidLinkingScreen extends StatelessWidget {
  final Map<String, dynamic>? maidData;

  const MaidLinkingScreen({super.key, this.maidData});

  // Helper function for responsive font size
  double getResponsiveFontSize(double baseSize, double screenWidth) {
    // Scale font size based on screen width, with a minimum size
    return max(
      baseSize * (screenWidth / 414.0),
      12.0,
    ); // 414 is a reference width (e.g., iPhone 11 Pro Max)
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen dimensions for responsive UI
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Use the maidData passed from the previous screen
    final displayMaidData = maidData ?? {}; // Ensure it's not null

    // Extract relevant data from displayMaidData
    final String maidName =
        (displayMaidData['maidData'] as Map<String, dynamic>?)?['name'] ??
        'N/A';
    final String serviceTitle = displayMaidData['serviceTitle'] ?? 'N/A';
    final String salary = displayMaidData['salary'] ?? 'N/A';
    final String dateOfPayment = displayMaidData['dateOfPayment'] ?? 'N/A';
    final int numberOfShifts = displayMaidData['numberOfShifts'] ?? 1;
    final List<dynamic>? shiftSlotsDynamic =
        displayMaidData['selectedShiftTimes'];
    final List<String?> shiftSlots =
        shiftSlotsDynamic?.map((s) => s.toString()).toList() ?? [];
    final String timeSlotDisplay = shiftSlots
        .where((s) => s != null)
        .join(' | ');

    final List<dynamic>? selectedAllRounderTypesDynamic =
        displayMaidData['currentSelectedAllRounderTypes'];
    final List<String>? selectedAllRounderTypes = selectedAllRounderTypesDynamic
        ?.map((e) => e.toString())
        .toList();

    // Determine the service display string
    String serviceDisplay = serviceTitle;
    if (serviceTitle == 'All-rounder' &&
        selectedAllRounderTypes != null &&
        selectedAllRounderTypes.isNotEmpty) {
      serviceDisplay = 'All-rounder (${selectedAllRounderTypes.join(', ')})';
    }

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Confirmation',
          style: GoogleFonts.poppins(
            fontSize: getResponsiveFontSize(18, screenWidth),
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        // To prevent vertical overflow on small screens
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
          ), // Responsive padding
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute space
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03), // Responsive spacing
                    // Top Icon
                    Image.asset(
                      'assets/linking_icon.png',
                      height: screenWidth * 0.25, // Responsive size
                      width: screenWidth * 0.25, // Responsive size
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person_pin_circle,
                          size: screenWidth * 0.25, // Responsive size
                          color: AppColors.emotionYellow,
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // "Hurray!" Text
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hurray! Your Maid Linking under approval',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveFontSize(18, screenWidth),
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Maid Details Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        screenWidth * 0.05,
                      ), // Responsive padding
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryPurple,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Maid Profile Picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryPurple,
                                width: 1.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: screenWidth * 0.1, // Responsive radius
                              backgroundColor: AppColors.secondaryPastelPurple,
                              child: Text(
                                maidName.isNotEmpty
                                    ? maidName[0].toUpperCase()
                                    : 'S',
                                style: GoogleFonts.poppins(
                                  fontSize: getResponsiveFontSize(
                                    40,
                                    screenWidth,
                                  ),
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            maidName,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(18, screenWidth),
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          // Details block
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time-slot: $timeSlotDisplay ($numberOfShifts shifts)',
                                style: GoogleFonts.poppins(
                                  fontSize: getResponsiveFontSize(
                                    14,
                                    screenWidth,
                                  ),
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Service : $serviceDisplay',
                                style: GoogleFonts.poppins(
                                  fontSize: getResponsiveFontSize(
                                    14,
                                    screenWidth,
                                  ),
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Salary : $salary',
                                style: GoogleFonts.poppins(
                                  fontSize: getResponsiveFontSize(
                                    14,
                                    screenWidth,
                                  ),
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Payment Date : $dateOfPayment',
                                style: GoogleFonts.poppins(
                                  fontSize: getResponsiveFontSize(
                                    14,
                                    screenWidth,
                                  ),
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // "Your Maid will be linked..." Text
                    Text(
                      'Your Maid will be linked\nonce $maidName confirms\nall the details.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: getResponsiveFontSize(16, screenWidth),
                        color: AppColors.primaryPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Go To Home Button - Pushed to the bottom
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    bottom: screenHeight * 0.06,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to the DashboardScreen
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ), // Responsive padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        'GO TO HOME',
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveFontSize(
                            AppTextStyles.buttonText.fontSize ?? 16,
                            screenWidth,
                          ),
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
