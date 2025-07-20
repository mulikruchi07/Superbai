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

  // MODIFICATION: State variable to track gender validation error
  bool _showGenderError = false;

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

  // MODIFICATION: Updated form submission logic
  void _submitForm() {
    // First, validate the form fields using the form key
    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    // Update state to show/hide the gender error message
    setState(() {
      _showGenderError = _selectedGender == null;
    });

    // If all fields are valid (including gender), navigate to the next screen
    if (isFormValid && _selectedGender != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const ToggleScreen()));
    }
  }

  // MODIFICATION: Helper function to handle gender selection and clear error
  void _onGenderSelected(String? value) {
    setState(() {
      _selectedGender = value;
      // When a gender is selected, hide the error message
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

              // MODIFICATION: Gender Selection section updated to show inline error
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
                  // Conditionally display the error message
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
                  // To make the radio buttons and text appear together and be responsive
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: _onGenderSelected, // Use helper function
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        // Using a GestureDetector to allow text click to also select the radio
                        GestureDetector(
                          onTap: () =>
                              _onGenderSelected('Male'), // Use helper function
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
                          onChanged: _onGenderSelected, // Use helper function
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        GestureDetector(
                          onTap: () => _onGenderSelected(
                            'Female',
                          ), // Use helper function
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
                          onChanged: _onGenderSelected, // Use helper function
                          activeColor: AppColors.primaryPurple,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        GestureDetector(
                          onTap: () =>
                              _onGenderSelected('Other'), // Use helper function
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
