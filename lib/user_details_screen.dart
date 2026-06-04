import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/repositories/user_repository.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/services/auth_flow_service.dart';
import 'package:superbai/theme.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _flatNoController = TextEditingController();
  final UserRepository _userRepository = UserRepository();

  String? _selectedGender;
  String? _selectedBuilding;
  String? _selectedWing;
  bool _showGenderError = false;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _buildings = [
    'Evershine Madhuvan CHS',
    'Sigma Building',
    'Bhoomi Towers',
  ];

  final List<String> _wings = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final profile = await _userRepository.getProfileForAuthUser(authUser);
      if (profile != null && profile.shouldSkipProfileSetup) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
        return;
      }
      if (profile != null && mounted) {
        _fullNameController.text = profile.name;
        _flatNoController.text = profile.pincode;
        final wing = profile.wingFromBuilding;
        final buildingName = profile.buildingNameOnly;
        if (_buildings.contains(buildingName)) {
          _selectedBuilding = buildingName;
        }
        if (wing != null && _wings.contains(wing)) {
          _selectedWing = wing;
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _flatNoController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.neutralMediumGray,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: AppColors.neutralWhite,
      errorStyle: GoogleFonts.poppins(color: Colors.redAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
    );
  }

  Future<void> _submitForm() async {
    final isFormValid = _formKey.currentState?.validate() ?? false;

    setState(() {
      _showGenderError = _selectedGender == null;
    });

    if (!isFormValid || _selectedGender == null) return;

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in again.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _userRepository.saveProfile(
        authUser: authUser,
        name: _fullNameController.text,
        buildingName: _selectedBuilding!,
        wing: _selectedWing!,
        flatNumber: _flatNoController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => postProfileSetupScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onGenderSelected(String? value) {
    setState(() {
      _selectedGender = value;
      if (value != null) {
        _showGenderError = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        title: Text(
          'Create Your Profile',
          style: GoogleFonts.poppins(
            fontSize: AppTextStyles.heading4.fontSize,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quickly fill these details correctly for the best experience',
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.bodyText.fontSize,
                        color: AppColors.neutralDarkGray,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Full Name*',
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.bodyText.fontSize,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _buildInputDecoration('Enter your name'),
                      style: GoogleFonts.poppins(color: AppColors.neutralBlack),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Gender*',
                          style: GoogleFonts.poppins(
                            fontSize: AppTextStyles.bodyText.fontSize,
                            color: AppColors.neutralBlack,
                          ),
                        ),
                        if (_showGenderError)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Please select a gender',
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'Male',
                                groupValue: _selectedGender,
                                onChanged: _onGenderSelected,
                                activeColor: AppColors.primaryPurple,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              GestureDetector(
                                onTap: () => _onGenderSelected('Male'),
                                child: Text(
                                  'Male',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.neutralBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'Female',
                                groupValue: _selectedGender,
                                onChanged: _onGenderSelected,
                                activeColor: AppColors.primaryPurple,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              GestureDetector(
                                onTap: () => _onGenderSelected('Female'),
                                child: Text(
                                  'Female',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.neutralBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<String>(
                                value: 'Other',
                                groupValue: _selectedGender,
                                onChanged: _onGenderSelected,
                                activeColor: AppColors.primaryPurple,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              GestureDetector(
                                onTap: () => _onGenderSelected('Other'),
                                child: Text(
                                  'Other',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.neutralBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Building*',
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.bodyText.fontSize,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('Select a Building'),
                      value: _selectedBuilding,
                      hint: Text(
                        'Select a Building',
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralMediumGray,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() => _selectedBuilding = newValue);
                      },
                      items: _buildings.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: AppColors.neutralBlack,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a building' : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Wing*',
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.bodyText.fontSize,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('Select Wing'),
                      value: _selectedWing,
                      hint: Text(
                        'Select Wing',
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralMediumGray,
                          fontSize: 15,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() => _selectedWing = newValue);
                      },
                      items: _wings.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: AppColors.neutralBlack,
                              fontSize: 15,
                            ),
                          ),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Please select a wing' : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Flat No*',
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.bodyText.fontSize,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _flatNoController,
                      decoration: _buildInputDecoration('Enter Flat No.'),
                      style: GoogleFonts.poppins(color: AppColors.neutralBlack),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your flat number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'CONTINUE',
                                style: GoogleFonts.poppins(
                                  fontSize: AppTextStyles.buttonText.fontSize,
                                  color: AppColors.neutralWhite,
                                  fontWeight: FontWeight.w500,
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
