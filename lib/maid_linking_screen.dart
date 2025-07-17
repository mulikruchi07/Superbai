import 'package:flutter/material.dart';
import 'package:superbai/salary_screen.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart'; // Import DashboardScreen
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class MaidLinkingScreen extends StatelessWidget {
  final Map<String, dynamic>? maidData;

  const MaidLinkingScreen({super.key, this.maidData});

  @override
  Widget build(BuildContext context) {
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
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30), // Move image down
            // Top Icon
            Image.asset(
              'assets/linking_icon.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person_pin_circle,
                  size: 100,
                  color: AppColors.emotionYellow,
                );
              },
            ),
            const SizedBox(height: 30),

            // "Hurray!" Text
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hurray! Your Maid Linking under approval',
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Maid Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryPurple, width: 2),
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
                      radius: 40,
                      backgroundColor: AppColors.secondaryPastelPurple,
                      child: Text(
                        maidName.isNotEmpty ? maidName[0].toUpperCase() : 'S',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    maidName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Details block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time-slot: $timeSlotDisplay ($numberOfShifts shifts)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Service : $serviceDisplay',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Salary : $salary',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Payment Date : $dateOfPayment',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // "Your Maid will be linked..." Text
            Text(
              'Your Maid will be linked\nonce $maidName confirms\nall the details.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.primaryPink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            // Go To Home Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'GO TO HOME',
                    style: GoogleFonts.poppins(
                      fontSize: AppTextStyles.buttonText.fontSize,
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
    );
  }
}
