import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/toggle_screen.dart'; // To navigate to the next screen

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // A global key that uniquely identifies the Form widget and allows validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final TextEditingController _societyNameController = TextEditingController();

  // State variables for selected values
  String? _selectedGender;
  String? _selectedBuilding;

  // List of buildings for the dropdown menu
  final List<String> _buildings = [
    'Dreams Building',
    'Kukreja Building',
    'Mahavir Universe Building',
    'Phoenix Building',
    'Mahindra Splendour Building',
    'Lodha Imperial Building',
  ];

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _fullNameController.dispose();
    _flatNoController.dispose();
    _societyNameController.dispose();
    super.dispose();
  }

  // Helper function for consistent input field styling
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.neutralMediumGray,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: AppColors.neutralWhite,
      // Using FormField's error style for validation messages
      errorStyle: GoogleFonts.poppins(color: Colors.redAccent),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0), // Slightly curved border
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

  // Function to handle form submission
  void _submitForm() {
    // First, validate the form fields using the form key
    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    // Check if a gender has been selected (since it's not a FormField)
    bool isGenderSelected = true;
    if (_selectedGender == null) {
      isGenderSelected = false;
      // Show a message to the user if gender is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select your gender.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    // If all fields are valid, navigate to the next screen
    if (isFormValid && isGenderSelected) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ToggleScreen()));
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
          'Create Your Profile',
          style: GoogleFonts.poppins(
            fontSize: AppTextStyles.heading4.fontSize,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Assigning the key to the Form
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

              // Full Name Input
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

              // Gender Selection
              Text(
                'Gender*',
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.bodyText.fontSize,
                  color: AppColors.neutralBlack,
                ),
              ),
              Row(
                children: [
                  // To make the radio buttons and text appear together and be responsive
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        // Using a GestureDetector to allow text click to also select the radio
                        GestureDetector(
                          onTap: () => setState(() => _selectedGender = 'Male'),
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
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGender = 'Female'),
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
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGender = 'Other'),
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

              // Society Name Input
              Text(
                'Society Name*',
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.bodyText.fontSize,
                  color: AppColors.neutralBlack,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _societyNameController,
                decoration: _buildInputDecoration('Enter Society Name'),
                style: GoogleFonts.poppins(color: AppColors.neutralBlack),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your society name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Building Dropdown
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
                  setState(() {
                    _selectedBuilding = newValue;
                  });
                },
                items: _buildings.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: AppColors.neutralBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a building' : null,
              ),
              const SizedBox(height: 20),

              // Flat No. Input
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
              const SizedBox(height: 60), // Increased space before the button
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _submitForm, // Calls the validation and navigation logic
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child: Text(
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
