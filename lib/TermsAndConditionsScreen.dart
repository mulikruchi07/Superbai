import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/data/terms_and_conditions.dart';
import 'package:superbai/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontSize: 18,
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
            Text(
              TermsAndConditions.intro,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.45,
                color: AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terms of Service',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 10),
            ...TermsAndConditions.termsSections.map(_buildSection),
            const SizedBox(height: 18),
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              TermsAndConditions.privacyIntro,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.45,
                color: AppColors.neutralDarkGray,
              ),
            ),
            const SizedBox(height: 10),
            ...TermsAndConditions.privacySections.map(_buildSection),
            const SizedBox(height: 12),
            Text(
              'Consent',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 8),
            ...TermsAndConditions.privacyConsent.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $item',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.neutralBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(TermsSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.body,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.45,
              color: AppColors.neutralDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}
