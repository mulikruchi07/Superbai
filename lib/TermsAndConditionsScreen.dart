import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/data/terms_and_conditions.dart';
import 'package:superbai/theme.dart';

enum LegalDocumentSection { termsOfService, privacyPolicy }

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({
    super.key,
    required this.section,
  });

  final LegalDocumentSection section;

  String get _appBarTitle {
    switch (section) {
      case LegalDocumentSection.termsOfService:
        return 'Terms of Service';
      case LegalDocumentSection.privacyPolicy:
        return 'Privacy Policy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTerms = section == LegalDocumentSection.termsOfService;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _appBarTitle,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTerms ? 'SUPERBAI TERMS OF SERVICE' : 'SUPERBAI PRIVACY POLICY',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.neutralBlack,
              ),
            ),
            const SizedBox(height: 16),
            if (isTerms) ...[
              Text(
                TermsAndConditions.intro,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.neutralBlack,
                ),
              ),
              const SizedBox(height: 16),
              ...TermsAndConditions.termsSections.map(_buildSection),
            ] else ...[
              Text(
                TermsAndConditions.privacyIntro,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.neutralDarkGray,
                ),
              ),
              const SizedBox(height: 16),
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
                    '✓ $item',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.neutralBlack,
                    ),
                  ),
                ),
              ),
            ],
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
