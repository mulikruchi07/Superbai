import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Import your theme for colors and text styles
import 'package:superbai/dashboard_screen.dart'; // Import the dashboard screen

class RequestSuccessScreen extends StatelessWidget {
  const RequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      // UPDATED: Wrapped the body in a SafeArea to prevent overlap with system UI
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration Image
              Image.asset(
                'assets/success_illustration.PNG', // Corrected asset path (ensure .png suffix)
                width:
                    MediaQuery.of(context).size.width * 0.8, // Responsive width
                height:
                    MediaQuery.of(context).size.height *
                    0.4, // Responsive height
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: AppColors.neutralLightGray,
                    child: Center(
                      child: Text(
                        'Success Illustration Placeholder',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralDarkGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Main Success Message
              Text(
                'Your Request is Generated Successfully!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18, // Slightly larger for emphasis
                  fontWeight: FontWeight.w500, // Poppins Medium
                  color: AppColors
                      .primaryPink, // Matching the pink color in the UI
                ),
              ),
              const SizedBox(height: 10),

              // Sub-message
              Text(
                '*Maid will be assigned to you shortly!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Poppins Medium
                  color: AppColors
                      .primaryPurple, // Matching the purple color in the UI
                ),
              ),
              const Spacer(), // Pushes the button to the bottom
              // Go To Home Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the DashboardScreen and remove all other routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryPurple, // Button background color
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        25.0,
                      ), // Curved edges for the button
                    ),
                  ),
                  child: Text(
                    'GO TO HOME',
                    style: GoogleFonts.poppins(
                      fontSize: AppTextStyles.buttonText.fontSize,
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w600, // SemiBold for button
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
