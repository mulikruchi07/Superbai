import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/data/terms_and_conditions.dart';
import 'package:superbai/repositories/user_repository.dart';
import 'package:superbai/services/auth_flow_service.dart';
import 'package:superbai/theme.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final UserRepository _userRepository = UserRepository();

  bool _hasScrolledToEnd = false;
  bool _agreed = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkIfContentFits());
  }

  void _checkIfContentFits() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent <= 8) {
      setState(() => _hasScrolledToEnd = true);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _hasScrolledToEnd) return;
    final atEnd = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 24;
    if (atEnd) {
      setState(() => _hasScrolledToEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _onAgree() async {
    if (!_agreed || !_hasScrolledToEnd) return;

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      _showMessage('Please log in again.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _userRepository.saveTermsResponse(
        authUser: authUser,
        accepted: true,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => postProfileSetupScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Could not save your response. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.neutralWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryPurple,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Terms and Conditions',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralWhite,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (!_hasScrolledToEnd)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppColors.primaryPurple.withOpacity(0.08),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_vertical,
                      size: 16,
                      color: AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scroll to the end to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TermsAndConditions.customerTermsWelcome,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.neutralDarkGray,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...TermsAndConditions.customerTermsSections
                          .map(_buildSection),
                      const SizedBox(height: 12),
                      Text(
                        'Declaration',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...TermsAndConditions.customerDeclarations.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: AppColors.primaryPurple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.neutralBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18, 12, 18, bottomPadding + 12),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                border: Border(
                  top: BorderSide(color: AppColors.neutralMediumGray),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _hasScrolledToEnd
                        ? () => setState(() => _agreed = !_agreed)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _agreed,
                            activeColor: AppColors.primaryPurple,
                            onChanged: _hasScrolledToEnd
                                ? (value) =>
                                      setState(() => _agreed = value ?? false)
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the Terms and Conditions',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _hasScrolledToEnd
                                    ? AppColors.neutralBlack
                                    : AppColors.neutralMediumGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving || !_agreed || !_hasScrolledToEnd
                          ? null
                          : _onAgree,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        disabledBackgroundColor:
                            AppColors.neutralMediumGray,
                        foregroundColor: AppColors.neutralWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'I Agree & Continue',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(TermsSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            section.body,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.45,
              color: AppColors.neutralDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}
