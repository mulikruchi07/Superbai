import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/toggle_screen.dart'; // To navigate to the next screen
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final TextEditingController _towerBuildingNoController =
      TextEditingController();
  final TextEditingController _societyNameController = TextEditingController();

  String? _selectedGender; // State for radio button selection

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _flatNoController.dispose();
    _towerBuildingNoController.dispose();
    _societyNameController.dispose();
    super.dispose();
  }

  // Function to show a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPurple, // Header background color
              onPrimary: AppColors.neutralWhite, // Header text color
              onSurface: AppColors.neutralBlack, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Helper for InputDecoration consistent styling
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.neutralMediumGray,
        fontWeight: FontWeight.normal,
      ), // Poppins Regular for hint
      filled: true,
      fillColor: AppColors.neutralWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.neutralMediumGray,
          width: 1.0,
        ), // Thin grey outline
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.neutralMediumGray,
          width: 1.0,
        ), // Thin grey outline
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.primaryPurple,
          width: 2.0,
        ), // Purple when focused
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple, // AppBar background color
        elevation: 0,
        // Removed leading IconButton to remove the back button
        title: Text(
          'Create Your profile',
          style: GoogleFonts.poppins(
            // Poppins SemiBold for section title
            fontSize: AppTextStyles.heading4.fontSize,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w600, // SemiBold
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
              'Quickly fill these details correctly for best experience',
              style: GoogleFonts.poppins(
                // Poppins Regular for subtext
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
                // Poppins Regular for labels
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fullNameController,
              decoration: _buildInputDecoration('Enter your name'),
              style: GoogleFonts.poppins(
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ), // Poppins Regular for input text
            ),
            const SizedBox(height: 20),

            // Gender Selection
            Text(
              'Gender',
              style: GoogleFonts.poppins(
                // Poppins Regular for labels
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Male',
                      style: GoogleFonts.poppins(
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.w500,
                      ), // Poppins Medium for radio labels
                    ),
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Female',
                      style: GoogleFonts.poppins(
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.w500,
                      ), // Poppins Medium for radio labels
                    ),
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      'Other',
                      style: GoogleFonts.poppins(
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.w500,
                      ), // Poppins Medium for radio labels
                    ),
                    value: 'Other',
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    activeColor: AppColors.primaryPurple,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Society name: Input (Moved up)
            Text(
              'Society name:',
              style: GoogleFonts.poppins(
                // Poppins Regular for labels
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _societyNameController,
              decoration: _buildInputDecoration('Enter Society Name'),
              style: GoogleFonts.poppins(
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ), // Poppins Regular for input text
            ),
            const SizedBox(height: 20),

            // Tower/ Building no/Block no: Input
            Text(
              'Tower/ Building no/Block no:',
              style: GoogleFonts.poppins(
                // Poppins Regular for labels
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _towerBuildingNoController,
              decoration: _buildInputDecoration(
                'Enter Tower/Building/Block No.',
              ),
              style: GoogleFonts.poppins(
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ), // Poppins Regular for input text
            ),
            const SizedBox(height: 20),

            // Flat No. Input (Moved down)
            Text(
              'Flat No:',
              style: GoogleFonts.poppins(
                // Poppins Regular for labels
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _flatNoController,
              decoration: _buildInputDecoration('Enter Flat No.'),
              style: GoogleFonts.poppins(
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ), // Poppins Regular for input text
            ),
            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the toggle screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ToggleScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryPurple, // Button background color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ), // More curved edges for the button
                  ),
                ),
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.poppins(
                    // Poppins Medium or SemiBold for button
                    fontSize: AppTextStyles.buttonText.fontSize,
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w500, // Medium weight
                    letterSpacing: 1.5, // Clear spacing
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
