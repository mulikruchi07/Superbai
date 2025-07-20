import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';

class FAQAnswerScreen extends StatelessWidget {
  final String screenTitle;
  final String contentText;

  const FAQAnswerScreen({
    super.key,
    required this.screenTitle,
    required this.contentText,
  });

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
            Navigator.pop(context);
          },
        ),
        title: Text(
          screenTitle,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  contentText,
                  style: GoogleFonts.poppins(fontSize: 16, color: AppColors.neutralBlack), // Changed to neutralBlack
                  textAlign: TextAlign.left, // Align text to left
                ),
              ),
            ),
            const SizedBox(height: 30), // Space before the button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Still Need Help? button clicked!')),
                  );
                  // Optionally, navigate to a chat screen or contact form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple, // Purple color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Full curved edges
                  ),
                ),
                child: Text(
                  'STILL NEED HELP?',
                  style: GoogleFonts.poppins(
                    fontSize: AppTextStyles.buttonText.fontSize,
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
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
