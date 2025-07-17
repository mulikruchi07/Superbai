// maid_details_screen.dart
import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:superbai/provided_services_screen.dart'; // Import the new ProvidedServicesScreen

class MaidDetailsScreen extends StatelessWidget {
  // Maid data to be passed to this screen
  // IMPORTANT: Changed to dynamic to match find_maid_screen.dart
  final Map<String, dynamic> maidData;

  const MaidDetailsScreen({super.key, required this.maidData});

  @override
  Widget build(BuildContext context) {
    // Check if the maid is verified
    final bool isVerified =
        maidData['isVerified'] ?? false; // Default to false if not specified

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor:
            AppColors.primaryPurple, // AppBar background color kept purple
        elevation: 0, // Removed elevation
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.neutralWhite,
          ), // White back button
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: false, // Ensure title is not centered if it were present
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10), // Gap from top of the screen/app bar

            Row(
              crossAxisAlignment: CrossAxisAlignment
                  .center, // Align items to center vertically in the row
              children: [
                // Maid Profile Picture
                CircleAvatar(
                  radius: 40, // Standard size
                  backgroundColor: AppColors
                      .secondaryPastelPurple, // Pastel purple background
                  // Using first letter of maid's name as a placeholder
                  child: Text(
                    maidData['name'] != null && maidData['name']!.isNotEmpty
                        ? maidData['name']![0].toUpperCase()
                        : '',
                    style: GoogleFonts.poppins(
                      fontSize: 24, // Reduced font size for initial
                      color: AppColors.primaryPurple,
                      fontWeight:
                          FontWeight.bold, // Keep initial bold for visibility
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ), // Spacing between avatar and text details
                Expanded(
                  // Use Expanded to ensure text details column doesn't overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        // Row to contain name and badge for horizontal layout
                        children: [
                          Flexible(
                            // IMPORTANT: Use Flexible to allow the name to wrap
                            child: Text(
                              maidData['name'] ?? 'Maid Name',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow
                                  .visible, // Ensures wrapping, not truncation
                            ),
                          ),
                          if (isVerified) // Conditionally show the verified badge
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Image.asset(
                                'assets/verified_badge.png', // Path to your badge image
                                width: 20, // Adjust size as needed
                                height: 20, // Adjust size as needed
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3), // Smaller gap
                      Text(
                        'Code: ${maidData['code'] ?? 'XXXX'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 3), // Smaller gap
                      Text(
                        '${maidData['gender'] ?? 'Female'} | ${maidData['age'] ?? 'XX'} yr old',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 3), // Smaller gap
                      Text(
                        '${maidData['experience'] ?? 'X+'} yr experience',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 3), // Smaller gap
                      Text(
                        maidData['location'] ?? 'Location',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25), // Reduced space after maid details

            Text(
              'Are you sure this maid works in your house?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 12,
            ), // Reduced space between question and instruction

            Text(
              'Please Confirm the above Maid and\nFill out the following Service Information.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 18), // Reduced space before bullet points
            // Service Information Bullet Points
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
              ), // Consistent left padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• Service',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.neutralBlack,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ), // Smaller space between bullet points
                  Text(
                    '• Duration',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.neutralBlack,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ), // Smaller space between bullet points
                  Text(
                    '• Salary',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.neutralBlack,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            // Yes, Confirm Maid Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the new ProvidedServicesScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProvidedServicesScreen(
                          maidData:
                              maidData, // Pass maidData to the next screen
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryPurple, // Button background color
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ), // Reduced vertical padding slightly
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ), // Fully curved edges
                    ),
                  ),
                  child: Text(
                    'YES, CONFIRM MAID',
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
