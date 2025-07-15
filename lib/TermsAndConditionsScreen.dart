import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and other theme definitions are here

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple, // AppBar color from image
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontSize: 18, // Small font size for app bar title
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed "Terms & Conditions" text below header as requested
            Text(
              'Thank you for using SUPERBAI\nPlease read these terms and conditions carefully before\nusing our services.',
              style: GoogleFonts.poppins(
                fontSize: 13, // Small font size
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing or using our App, you agree to comply with and be bound by these terms and conditions. If you do not agree with any part of these terms, please do not use the App.',
            ),
            _buildSection(
              '2. User Eligibility',
              'You must be at least 18 years old to use our services. By using the App, you confirm that you meet this age requirement.',
            ),
            _buildSection(
              '3. Service Description',
              'Our App connects users with independent cleaning professionals ("Maids") who offer cleaning services. We do not employ the Maids directly, and they are not our employees or agents.',
            ),
            _buildSection(
              '4. Booking and Payment',
              'a. Users can book cleaning services through the App.\nb. Payment is processed securely within the App.\nc. Prices and payment methods are clearly displayed in the App, and you agree to pay the specified amount for services.\nd. Cancellations and refunds are subject to our cancellation policy, as detailed in the App.',
            ),
            _buildSection(
              '5. User Responsibilities',
              'a. You are responsible for providing accurate information for bookings.\nb. You must ensure a safe and suitable environment for the Maids to work in.\nc. You agree not to engage in any discriminatory, harassing, or harmful behavior towards Maids or other users.',
            ),
            _buildSection(
              '6. Maids\' Responsibilities',
              'a. Maids are responsible for providing cleaning services as booked.\nb. Maids must maintain professionalism and respect towards users at all times.',
            ),
            _buildSection(
              '7. Ratings and Reviews',
              'Users can rate and review Maids based on their experiences. Abusive or false reviews will not be tolerated.',
            ),
            _buildSection(
              '8. Privacy',
              'We collect and process user data in accordance with our privacy policy, which can be accessed through the App.',
            ),
            _buildSection(
              '9. Liability',
              'a. We are not liable for the quality of the cleaning services provided by Maids.\nb. Users and Maids are responsible for any damage or injury resulting from their actions.',
            ),
            _buildSection(
              '10. Termination',
              'We reserve the right to terminate or suspend access to the App for users or Maids who violate these terms and conditions.',
            ),
            _buildSection(
              '11. Changes to Terms',
              'We may update these terms and conditions at any time, and it is your responsibility to review them periodically.',
            ),
            _buildSection(
              '12. Contact Us',
              'If you have any questions or concerns about these terms and conditions, please contact us through the App.',
            ),
            const SizedBox(height: 20),
            Text(
              'By using our Maid Service Providing App, you acknowledge that you have read, understood, and agreed\nto these terms and conditions. These terms and conditions constitute a legally binding agreement between you and the App provider.',
              style: GoogleFonts.poppins(
                fontSize: 13, // Small font size
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14, // Small font size for section titles
              fontWeight: FontWeight.bold,
              color: Colors.black, // Black font color
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13, // Small font size for content
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
