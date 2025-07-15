import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart'; // Import DashboardScreen
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class MaidLinkingScreen extends StatelessWidget {
  // Data passed from TimeSlotScreen (dummy for now, will connect to maid data later)
  final List<String>
  selectedDays; // Keeping for compatibility, though time is now more detailed
  final String
  selectedTimeSlot; // Keeping for compatibility, though time is now more detailed
  final Map<String, dynamic>?
  maidData; // Optional, if you want to display the specific maid

  const MaidLinkingScreen({
    super.key,
    required this.selectedDays,
    required this.selectedTimeSlot,
    this.maidData, // Optional maid data
  });

  @override
  Widget build(BuildContext context) {
    // Use the maidData passed from the previous screen
    final displayMaidData = maidData ?? {}; // Ensure it's not null

    // Extract relevant data from displayMaidData
    final String maidName = displayMaidData['name'] ?? 'N/A';
    final String service = displayMaidData['service'] ?? 'N/A';
    final String salary = displayMaidData['salary'] ?? 'N/A';
    final String dateOfPayment = displayMaidData['dateOfPayment'] ?? 'N/A';
    final String selectedFromTime =
        displayMaidData['selectedFromTime'] ?? 'N/A';
    final String selectedToTime = displayMaidData['selectedToTime'] ?? 'N/A';
    final int numberOfShifts = displayMaidData['numberOfShifts'] ?? 1;
    final List<String>? selectedAllRounderTypes =
        displayMaidData['currentSelectedAllRounderTypes'] as List<String>?;

    // Determine the service display string
    String serviceDisplay = service;
    if (service == 'All-rounder' &&
        selectedAllRounderTypes != null &&
        selectedAllRounderTypes.isNotEmpty) {
      serviceDisplay = 'All-rounder (${selectedAllRounderTypes.join(', ')})';
    }

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center primary elements horizontally
          children: [
            // Top Icon (assuming image will be provided in assets)
            Image.asset(
              'assets/linking_icon.png', // Placeholder for the actual image asset
              height: 100,
              width: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person_pin_circle, // Fallback icon if image not found
                  size: 100,
                  color: AppColors.emotionYellow,
                );
              },
            ),
            const SizedBox(height: 30),

            // "Hurray!" Text - Aligned to left (with horizontal padding to match card)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hurray! Your Maid Linking under approval',
                textAlign: TextAlign.left, // Ensured left alignment
                style: GoogleFonts.poppins(
                  // Use GoogleFonts
                  fontSize: 18, // Small font size
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.normal, // Not bold
                ),
              ),
            ),
            const SizedBox(height: 20), // Reduced spacing as per image
            // Maid Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(
                  0.1,
                ), // Card filled color to purple transparent
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryPurple,
                  width: 2,
                ), // Outline color
              ),
              child: Column(
                // Centered horizontally within the card
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Maid Profile Picture above the name
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple,
                        width: 1.0,
                      ), // Thin purple outline
                    ),
                    child: CircleAvatar(
                      radius: 40, // Increased size slightly to match
                      backgroundColor: AppColors
                          .secondaryPastelPurple, // Background for the avatar
                      backgroundImage: const NetworkImage(
                        'https://placehold.co/100x100/E0BBE4/5D4EFF?text=R',
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // Spacing between image and name
                  Text(
                    maidName,
                    style: GoogleFonts.poppins(
                      // Use GoogleFonts
                      fontSize: 18, // Small font size
                      color: AppColors.primaryPurple, // Maid name purple
                      fontWeight: FontWeight.bold, // Maid name bold
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ), // Spacing between name and details block
                  // Details block - left-aligned within this column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Left-align text within this column
                    children: [
                      Text(
                        'Time-slot: $selectedFromTime - $selectedToTime ($numberOfShifts shifts)',
                        style: GoogleFonts.poppins(
                          // Use GoogleFonts
                          fontSize: 14, // Small font size
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal, // Not bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Service : $serviceDisplay', // Display service or sub-services
                        style: GoogleFonts.poppins(
                          // Use GoogleFonts
                          fontSize: 14, // Small font size
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal, // Not bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Salary : $salary', // Fetch salary
                        style: GoogleFonts.poppins(
                          // Use GoogleFonts
                          fontSize: 14, // Small font size
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal, // Not bold
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Payment Date : $dateOfPayment', // Fetch salary date
                        style: GoogleFonts.poppins(
                          // Use GoogleFonts
                          fontSize: 14, // Small font size
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.normal, // Not bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Spacing below the card
            // "Your Maid will be linked..." Text
            Text(
              'Your Maid will be linked\nonce $maidName confirms\nall the details.',
              textAlign: TextAlign.center, // Centered as per image
              style: GoogleFonts.poppins(
                // Use GoogleFonts
                fontSize: 16, // Increased font size
                color: AppColors.primaryPink, // Pink color
                fontWeight: FontWeight.bold, // Bold
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            // Go To Home Button
            Padding(
              // Added Padding to match the bottom padding of other pages
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the DashboardScreen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ), // Navigate to DashboardScreen
                      (Route<dynamic> route) =>
                          false, // Clear all previous routes
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ), // Fully curved edges
                    ),
                  ),
                  child: Text(
                    'GO TO HOME',
                    style: GoogleFonts.poppins(
                      // Use GoogleFonts
                      fontSize: AppTextStyles.buttonText.fontSize,
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight
                          .w600, // Kept bold for button text as it's common
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
