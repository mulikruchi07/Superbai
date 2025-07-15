import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'dart:async'; // Required for Timer
import 'package:superbai/user_details_screen.dart'; // Import the existing user details screen
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

// Enum to manage the state of the MobileNumberScreen
enum MobileScreenState { mobileInput, otpInput }

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> with TickerProviderStateMixin {
  MobileScreenState _currentState = MobileScreenState.mobileInput;

  // Onboarding/Slider related
  late AnimationController _onboardingFadeController;
  late Timer _onboardingTimer;
  int _currentPage = 0;
  final List<Map<String, String>> _onboardingPages = [
    {
      'image': 'assets/image_cae9e2.png',
      'title': 'WELCOME',
      'subtitle': '\"Experience Effortless Cleanliness at\nYour Fingertips with Our Trusted App.\"'
    },
    {
      'image': 'assets/image_cd33ff.png',
      'title': 'BENEFITS',
      'subtitle': '\"Connect Your Maid, Collect Coupons,\nand Enjoy Exclusive Rewards!\"'
    },
    {
      'image': 'assets/image_cbc3bb.png',
      'title': 'MANAGE',
      'subtitle': '\"All-in-One Maid Management Simplified\n– Features, Tracking, and More!\"'
    },
  ];

  // Mobile Number Input related
  final TextEditingController _mobileNumberController = TextEditingController();
  final FocusNode _mobileNumberFocusNode = FocusNode();

  // OTP Input related
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  String _maskedMobileNumber = ''; // To show in OTP screen
  bool _showOtpInfoLine = false; // Controls visibility of "OTP send to the Number" line

  @override
  void initState() {
    super.initState();

    _onboardingFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _onboardingFadeController.forward();

    _onboardingTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentPage = (_currentPage + 1) % _onboardingPages.length;
      });
      _onboardingFadeController.reset();
      _onboardingFadeController.forward();
    });

    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (!mounted) return; // Check if widget is still mounted

        if (_otpControllers[i].text.isNotEmpty) {
          if (i < _otpControllers.length - 1) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[i + 1]);
          } else {
            _verifyOtp();
          }
        } else {
          if (i > 0 && _otpFocusNodes[i].hasFocus) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[i - 1]);
          }
        }
      });

      _otpFocusNodes[i].addListener(() {
        if (!mounted) return; // Check if widget is still mounted
        if (_otpFocusNodes[i].hasFocus) {
          setState(() {
            _showOtpInfoLine = true;
          });
        } else {
          // If no OTP field has focus, hide the info line
          if (!_otpFocusNodes.any((node) => node.hasFocus)) {
             setState(() {
              _showOtpInfoLine = false;
            });
          }
        }
      });
    }
  }

  void _requestOtp() {
    FocusScope.of(context).unfocus(); // Hide keyboard

    if (_mobileNumberController.text.length == 10) {
      setState(() {
        _maskedMobileNumber = '+91 | ${_mobileNumberController.text.substring(0, 5)} ***** ${(_mobileNumberController.text.length > 9) ? _mobileNumberController.text.substring(8, 10) : ''}';
        _currentState = MobileScreenState.otpInput;
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _showOtpInfoLine = false; // Ensure it's hidden initially on OTP screen
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
      );
    }
  }

  void _verifyOtp() {
    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() {
      _showOtpInfoLine = false; // Hide info line after verification attempt
    });

    String enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifying OTP: $enteredOtp')),
      );
      // Navigate to UserDetailsScreen after successful OTP verification
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserDetailsScreen()), // Navigate to UserDetailsScreen
        (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the 4-digit OTP.')),
      );
    }
  }

  @override
  void dispose() {
    _onboardingFadeController.dispose();
    _onboardingTimer.cancel();
    _mobileNumberController.dispose();
    _mobileNumberFocusNode.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      // This ensures the screen resizes when the keyboard appears, pushing content up.
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder( // Use LayoutBuilder to get available screen height
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Padding here to lift content above the keyboard if necessary.
            // This is generally handled by resizeToAvoidBottomInset, but can be explicit if needed.
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox( // Ensure content takes at least full height
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom, // Adjust minHeight for keyboard
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                children: [
                  // 1. Onboarding Content (at the top)
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      SizedBox( // Fixed height for image area for consistency
                        height: constraints.maxHeight * 0.4, // Responsive height based on available space
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Image.asset(
                            _onboardingPages[_currentPage]['image']!,
                            key: ValueKey(_currentPage),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.neutralLightGray,
                                child: Center(
                                  child: Text(
                                    'Image Placeholder\n${_onboardingPages[_currentPage]['title']}',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyText.copyWith(color: AppColors.neutralDarkGray),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _onboardingPages[_currentPage]['title']!,
                        style: GoogleFonts.poppins( // Poppins Bold for heading
                          fontSize: AppTextStyles.heading3.fontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          _onboardingPages[_currentPage]['subtitle']!,
                          style: GoogleFonts.poppins( // Poppins Regular for subtext
                            fontSize: AppTextStyles.subtext.fontSize,
                            fontWeight: FontWeight.normal,
                            color: AppColors.neutralDarkGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // Page Indicators (Always visible below onboarding content)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingPages.length, (index) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primaryPurple
                              : AppColors.neutralMediumGray,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10), // Spacing above input section

                  // 2. Input Section (Mobile Number or OTP) - now fixed at bottom when keyboard is down
                  Container(
                    // Removed horizontal margin to stick to edges
                    // Removed padding from here as it will be inside the _build*Content methods
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightPurple.withOpacity(0.1),
                      // Apply borderRadius only to top corners
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _currentState == MobileScreenState.mobileInput
                          ? _buildMobileInputContent()
                          : _buildOtpInputContent(),
                      key: ValueKey(_currentState),
                    ),
                  ),
                  // Removed SizedBox here, ConstrainedBox with SpaceBetween handles spacing
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget for Mobile Number Input section
  Widget _buildMobileInputContent() {
    return Padding( // Added Padding inside this method for consistency
      padding: const EdgeInsets.all(20.0), // Padding to match the UI
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mobile Number',
            style: GoogleFonts.poppins( // Poppins for body text
              fontSize: AppTextStyles.bodyText.fontSize,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mobileNumberController,
            focusNode: _mobileNumberFocusNode,
            keyboardType: TextInputType.phone, // Use native phone keyboard
            maxLength: 10,
            decoration: InputDecoration(
              hintText: '+91 | Enter Mobile Number',
              hintStyle: GoogleFonts.poppins(color: AppColors.neutralMediumGray), // Poppins for hint
              filled: true,
              fillColor: AppColors.neutralWhite, // Inner fill color for text field
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.neutralLightGray, width: 1.0), // Thin grey outline
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            style: GoogleFonts.poppins(color: AppColors.neutralBlack), // Poppins for input text
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // More curved edges
                ),
                shadowColor: AppColors.primaryPurple.withOpacity(0.5),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE',
                    style: GoogleFonts.poppins( // Poppins Medium for button
                      fontSize: AppTextStyles.buttonText.fontSize,
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w500, // Medium weight
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: AppColors.neutralWhite, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for OTP Input section
  Widget _buildOtpInputContent() {
    return Padding( // Added Padding inside this method for consistency
      padding: const EdgeInsets.all(20.0), // Padding to match the UI
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter OTP',
            style: GoogleFonts.poppins( // Poppins for body text
              fontSize: AppTextStyles.bodyText.fontSize,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number, // Use native number keyboard
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.poppins(color: AppColors.neutralBlack, fontSize: AppTextStyles.heading3.fontSize), // Poppins for OTP input text
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: AppColors.neutralWhite, // OTP boxes inner fill color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColors.primaryPurple, width: 1.0), // Thin purple outline
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Align text to top
            children: [
              Text(
                'Haven\'t received OTP?',
                style: GoogleFonts.poppins(color: AppColors.neutralDarkGray), // Poppins for body text
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Resending OTP...')),
                  );
                },
                child: Text(
                  'Resend OTP',
                  style: GoogleFonts.poppins(color: AppColors.primaryPurple), // Poppins for resend OTP
                ),
              ),
            ],
          ),
          // "OTP sent to the Number" line (now on its own line) and "Change Number" on the same line
          if (_showOtpInfoLine && _maskedMobileNumber.isNotEmpty) // Conditionally display
            Padding(
              padding: const EdgeInsets.only(top: 10.0), // Space above this text
              child: Row( // Changed to Row to put text and change number on same line
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out horizontally
                children: [
                  Column( // Use Column to stack "OTP send to the Number" and the masked number
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OTP send to the Number',
                        style: GoogleFonts.poppins(color: AppColors.neutralDarkGray), // Poppins for body text
                      ),
                      Text(
                        _maskedMobileNumber, // Masked number on its own line
                        style: GoogleFonts.poppins(color: AppColors.neutralDarkGray, fontWeight: FontWeight.bold), // Poppins for masked number
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentState = MobileScreenState.mobileInput;
                        _mobileNumberController.clear();
                        _maskedMobileNumber = ''; // Clear masked number when changing back
                        _showOtpInfoLine = false; // Hide info line on return to mobile input
                      });
                      FocusScope.of(context).requestFocus(_mobileNumberFocusNode);
                    },
                    child: Text(
                      'Change Number',
                      style: GoogleFonts.poppins(color: AppColors.primaryPink), // Poppins for change number
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // More curved edges
                ),
                shadowColor: AppColors.primaryPurple.withOpacity(0.5),
                elevation: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONTINUE',
                    style: GoogleFonts.poppins( // Poppins Medium for button
                      fontSize: AppTextStyles.buttonText.fontSize,
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w500, // Medium weight
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: AppColors.neutralWhite, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
