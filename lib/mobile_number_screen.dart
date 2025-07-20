import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'dart:async'; // Required for Timer
import 'package:superbai/user_details_screen.dart'; // Import the existing user details screen
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

// Enum to manage the state of the MobileNumberScreen
enum MobileScreenState { mobileInput, otpInput }

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen>
    with TickerProviderStateMixin {
  MobileScreenState _currentState = MobileScreenState.mobileInput;

  // --- Firebase and Auth State ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId; // To store the verification ID from Firebase
  bool _isLoading = false; // To show a loading indicator on buttons
  bool _isOtpInvalid = false; // NEW: To track OTP error state

  // Onboarding/Slider related
  late AnimationController _onboardingFadeController;
  late Timer _onboardingTimer;
  int _currentPage = 0;
  final List<Map<String, String>> _onboardingPages = [
    {
      'image': 'assets/image_cae9e2.png',
      'title': 'WELCOME',
      'subtitle':
          '\"Experience Effortless Cleanliness at Your\nFingertips with Our Trusted App.\"',
    },
    {
      'image': 'assets/image_cd33ff.png',
      'title': 'BENEFITS',
      'subtitle':
          '\"Connect Your Maid, Collect Coupons,\nand Enjoy Exclusive Rewards!\"',
    },
    {
      'image': 'assets/image_cbc3bb.png',
      'title': 'MANAGE',
      'subtitle':
          '\"All-in-One Maid Management Simplified\n– Features, Tracking, and More!\"',
    },
  ];

  // Mobile Number Input related
  final TextEditingController _mobileNumberController = TextEditingController();
  final FocusNode _mobileNumberFocusNode = FocusNode();

  // OTP Input related
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  String _maskedMobileNumber = ''; // To show in OTP screen

  @override
  void initState() {
    super.initState();
    _setupOnboardingAnimation();
    _setupOtpListeners();
  }

  void _setupOnboardingAnimation() {
    _onboardingFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _onboardingTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
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
  }

  void _setupOtpListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      // Listener to move focus forward automatically
      _otpControllers[i].addListener(() {
        if (!mounted) return;
        if (_otpControllers[i].text.length == 1 && i < _otpControllers.length - 1) {
          FocusScope.of(context).requestFocus(_otpFocusNodes[i + 1]);
        }
        if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
          _verifyOtp();
        }
      });

      // NEW: Listener to clear error state on focus
      _otpFocusNodes[i].addListener(() {
        if (_otpFocusNodes[i].hasFocus && _isOtpInvalid) {
          setState(() {
            _isOtpInvalid = false;
          });
        }
      });
    }
  }

  // --- Firebase Phone Auth Logic ---

  Future<void> _requestOtp() async {
    FocusScope.of(context).unfocus();
    if (_mobileNumberController.text.length != 10) {
      // You can add an inline error for mobile number too if you wish
      return;
    }

    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${_mobileNumberController.text}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Can also add inline error handling here
        setState(() => _isLoading = false);
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _maskedMobileNumber =
              '+91 | ${_mobileNumberController.text.substring(0, 5)} *****';
          _currentState = MobileScreenState.otpInput;
          _isLoading = false;
          _isOtpInvalid = false; // Reset error state on new OTP request
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    if (_verificationId == null) return;

    final enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length != 6) return;

    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredOtp,
      );
      await _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // NEW: Handle invalid OTP error inline
      if (e.code == 'invalid-verification-code') {
        setState(() {
          _isOtpInvalid = true; // Set error state to true
          _isLoading = false;
          for (var controller in _otpControllers) {
            controller.clear(); // Clear all OTP fields
          }
        });
        // Request focus on the first box for quick re-entry
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      } else {
        // Handle other potential errors if necessary
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await _auth.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const UserDetailsScreen()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
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
      resizeToAvoidBottomInset: true,
      // NEW: SafeArea prevents UI from being overlapped by system UI (status bar, nav bar)
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Top Onboarding Content ---
                    Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.05),
                        SizedBox(
                          height: constraints.maxHeight * 0.4,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(opacity: animation, child: child),
                            child: Image.asset(
                              _onboardingPages[_currentPage]['image']!,
                              key: ValueKey(_currentPage),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          _onboardingPages[_currentPage]['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: AppTextStyles.heading3.fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutralBlack,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            _onboardingPages[_currentPage]['subtitle']!,
                            style: GoogleFonts.poppins(
                              fontSize: AppTextStyles.subtext.fontSize,
                              color: AppColors.neutralDarkGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // --- Page Indicators ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_onboardingPages.length, (index) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? AppColors.primaryPurple
                                : AppColors.neutralMediumGray,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),

                    // --- Bottom Input Section ---
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightPurple.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _currentState == MobileScreenState.mobileInput
                            ? _buildMobileInputContent()
                            : _buildOtpInputContent(),
                        key: ValueKey(_currentState),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- UI Builder Widgets ---

  Widget _buildMobileInputContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mobile Number', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _mobileNumberController,
            focusNode: _mobileNumberFocusNode,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              hintText: '+91 | Enter Mobile Number',
              counterText: "",
              filled: true,
              fillColor: AppColors.neutralWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _requestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CONTINUE', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter OTP', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: AppColors.neutralWhite,
                    // NEW: Border color changes based on error state
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: _isOtpInvalid ? Colors.red : AppColors.neutralMediumGray,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: _isOtpInvalid ? Colors.red : AppColors.primaryPurple,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              );
            }),
          ),
          // NEW: Inline error message widget
          if (_isOtpInvalid)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Invalid OTP. Please try again.',
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
              ),
            )
          else
            const SizedBox(height: 15), // Keep spacing consistent when no error
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Haven\'t received OTP?', style: GoogleFonts.poppins()),
              GestureDetector(
                onTap: _isLoading ? null : _requestOtp, // Resend OTP
                // UPDATED: Font weight removed
                child: Text('Resend OTP', style: GoogleFonts.poppins(color: AppColors.primaryPurple)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OTP sent to the Number', style: GoogleFonts.poppins()),
                      Text(_maskedMobileNumber, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentState = MobileScreenState.mobileInput;
                      for (var controller in _otpControllers) {
                        controller.clear();
                      }
                    });
                  },
                  // UPDATED: Font weight removed
                  child: Text('Change Number', style: GoogleFonts.poppins(color: AppColors.primaryPink)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CONTINUE', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
