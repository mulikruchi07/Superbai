import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Fetches user data from Firestore and populates the text fields.
  Future<void> _fetchUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot userDoc = await _firestore
            .collection('DIM_USERS')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          _nameController.text = userDoc.get('FullName') ?? '';
          // Mobile number is directly from the auth user object
          _mobileController.text = user.phoneNumber ?? 'Not available';
          // Email is not collected in your flow, so we'll leave it blank or show a message.
          _emailController.text = user.email ?? 'No email provided';
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Validates the form and saves the updated name to Firestore.
  Future<void> _saveChanges() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _isLoading = true;
        });
        try {
          await _firestore.collection('DIM_USERS').doc(user.uid).update({
            'FullName': _nameController.text.trim(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );

          // Pop the screen and return `true` to signal a successful update
          Navigator.of(context).pop(true);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.neutralLightGray,
                        backgroundImage: const NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwh1EKt_AqF35M7LTejJXysIIKQ31zWt3fzlX5-F5DoUDrhOxfeySO5E_lgNeIuTrWJKM&usqp=CAU',
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Full Name (Editable)
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      readOnly: false, // This field is editable
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Mobile Number (Not Editable)
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      readOnly: true, // This field is not editable
                    ),
                    const SizedBox(height: 20),

                    // Email (Not Editable)
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      readOnly: true, // This field is not editable
                    ),
                    const SizedBox(height: 50),

                    // Save Changes Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        child: Text(
                          'SAVE CHANGES',
                          style: GoogleFonts.poppins(
                            fontSize: AppTextStyles.buttonText.fontSize,
                            color: AppColors.neutralWhite,
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

  /// Helper widget to build consistently styled text fields.
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool readOnly,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: AppTextStyles.bodyText.fontSize,
            color: AppColors.neutralBlack,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          validator: validator,
          style: GoogleFonts.poppins(
            color: readOnly
                ? AppColors.neutralDarkGray
                : AppColors.neutralBlack,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? AppColors.neutralLightGray.withOpacity(0.5)
                : AppColors.neutralWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.neutralMediumGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.neutralMediumGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: AppColors.primaryPurple,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 15,
            ),
          ),
        ),
      ],
    );
  }
}
