import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/exceptions/maid_slot_unavailable_exception.dart';
import 'package:superbai/repositories/appointment_repository.dart';
import 'package:superbai/theme.dart';

class MaidLinkingScreen extends StatefulWidget {
  final Map<String, dynamic>? maidData;

  const MaidLinkingScreen({super.key, this.maidData});

  @override
  State<MaidLinkingScreen> createState() => _MaidLinkingScreenState();
}

class _MaidLinkingScreenState extends State<MaidLinkingScreen> {
  final _appointmentRepository = AppointmentRepository();
  bool _isLinking = true;
  bool _linked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _linkMaidNow());
  }

  double getResponsiveFontSize(double baseSize, double screenWidth) {
    return max(baseSize * (screenWidth / 414.0), 12.0);
  }

  Future<void> _linkMaidNow() async {
    if (_linked) return;

    final user = FirebaseAuth.instance.currentUser;
    final args = widget.maidData ?? {};
    final maidId = AppointmentRepository.maidIdFromRouteArguments(args);

    if (user == null) {
      setState(() {
        _isLinking = false;
        _errorMessage = 'Please sign in again.';
      });
      return;
    }

    if (maidId == null) {
      setState(() {
        _isLinking = false;
        _errorMessage = 'Maid not found. Please select your maid again.';
      });
      return;
    }

    setState(() {
      _isLinking = true;
      _errorMessage = null;
    });

    try {
      await _appointmentRepository.createFromMaidOnboarding(
        authUser: user,
        maidId: maidId,
        routeArguments: args,
      );
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _linked = true;
      });
    } on MaidSlotUnavailableException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _errorMessage = e.message;
      });
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _errorMessage = 'Could not link maid. Please try again.';
      });
    }
  }

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Map<String, dynamic> _displayArgs() => widget.maidData ?? {};

  String _maidName() {
    final display = _displayArgs();
    final nestedMaid = display['maidData'];
    final maidMap = nestedMaid is Map<String, dynamic> ? nestedMaid : null;
    return (maidMap?['name'] as String?) ??
        (display['name'] as String?) ??
        'Your maid';
  }

  Widget _buildSummaryCard(double screenWidth, double screenHeight) {
    final display = _displayArgs();
    final serviceTitle = display['serviceTitle'] ?? 'N/A';
    final salary = display['salary'] ?? 'N/A';
    final dateOfPayment = display['dateOfPayment'] ?? 'N/A';
    final numberOfShifts = display['numberOfShifts'] ?? 1;
    final shiftSlotsDynamic = display['selectedShiftTimes'];
    final List<String> shiftSlots = shiftSlotsDynamic is List
        ? shiftSlotsDynamic.map((s) => s.toString()).toList()
        : <String>[];
    final timeSlotDisplay =
        shiftSlots.where((String s) => s.isNotEmpty).join(' | ');

    final selectedAllRounderTypesDynamic =
        display['currentSelectedAllRounderTypes'];
    final selectedAllRounderTypes = selectedAllRounderTypesDynamic
        ?.map((e) => e.toString())
        .toList();

    String serviceDisplay = serviceTitle.toString();
    if (serviceDisplay == 'All-rounder' &&
        selectedAllRounderTypes != null &&
        selectedAllRounderTypes.isNotEmpty) {
      serviceDisplay =
          'All-rounder (${selectedAllRounderTypes.join(', ')})';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.neutralLightGray, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maid : ${_maidName()}',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            'Shifts : $numberOfShifts',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            'Time : $timeSlotDisplay',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            'Service : $serviceDisplay',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            'Salary : $salary',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
            ),
          ),
          SizedBox(height: screenHeight * 0.005),
          Text(
            'Payment Date : $dateOfPayment',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(14, screenWidth),
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maidName = _maidName();

    return PopScope(
      canPop: !_isLinking,
      child: Scaffold(
        backgroundColor: AppColors.neutralWhite,
        appBar: AppBar(
          backgroundColor: AppColors.primaryPurple,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
            onPressed: _isLinking ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            _linked ? 'Maid linked' : 'Confirmation',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(18, screenWidth),
              color: AppColors.neutralWhite,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        if (_isLinking) ...[
                          CircularProgressIndicator(
                            color: AppColors.primaryPurple,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Linking $maidName to your booking…',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(16, screenWidth),
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (_linked) ...[
                          Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: AppColors.primaryPurple,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Maid linked successfully',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(18, screenWidth),
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            '$maidName is assigned to your booking for the selected time slot.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(14, screenWidth),
                              color: AppColors.neutralDarkGray,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildSummaryCard(screenWidth, screenHeight),
                        ] else ...[
                          Icon(
                            Icons.error_outline,
                            size: 56,
                            color: AppColors.emotionOrangeRed,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            _errorMessage ?? 'Could not link maid.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(14, screenWidth),
                              color: AppColors.emotionOrangeRed,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.02,
                    bottom: screenHeight * 0.06,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLinking
                          ? null
                          : () {
                              if (_linked) {
                                _navigateHome();
                              } else {
                                _linkMaidNow();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Text(
                        _linked
                            ? 'GO TO HOME'
                            : (_errorMessage != null ? 'TRY AGAIN' : 'GO TO HOME'),
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
