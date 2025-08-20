import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/find_maid_screen.dart'; // Corrected import to FindMaidScreen
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import 'package:superbai/select_service_screen.dart'; // Import the new SelectServiceScreen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToggleScreen extends StatefulWidget {
  const ToggleScreen({super.key});

  @override
  State<ToggleScreen> createState() => _ToggleScreenState();
}

class _ToggleScreenState extends State<ToggleScreen> {
  String?
  _selectedOption; // Stores the currently selected option: 'yes' or 'no'
  String _userName =
      '...'; // State variable to hold the user's name, with a default loading state

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the screen loads
  }

  // Function to fetch the user's full name from Firestore
  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('DIM_USERS')
          .doc(user.uid)
          .get();
      if (mounted && userDoc.exists && userDoc.data() != null) {
        setState(() {
          // Update the state with the fetched name
          _userName = userDoc.data()!['FullName'] ?? 'User';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define messages based on selection
    String? infoCardTitle;
    String? infoCardSubtitle;
    // Default color for the info card background
    Color infoCardBackgroundColor = AppColors.neutralWhite;

    if (_selectedOption == 'yes') {
      infoCardTitle = 'Congratulations!';
      infoCardSubtitle =
          'You\'re already a master of household harmony. Let us help you maintain that peace effortlessly with our maid management services';
    } else if (_selectedOption == 'no') {
      infoCardTitle = 'No maid, no worries!';
      infoCardSubtitle =
          'Discover a world of trustworthy and verified maids at your fingertips. Your search for the perfect helping hand starts here.';
    }

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple, // AppBar background color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            // Use pop to go back to the UserDetailsScreen if it's on the stack
            Navigator.pop(context);
          },
        ),
        title: FittedBox(
          // Use FittedBox to ensure text fits horizontally
          fit: BoxFit.scaleDown, // Scale down text if it's too large
          alignment: Alignment.centerLeft, // Align left within the FittedBox
          child: Column(
            // Use a Column to stack the title and question
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $_userName,', // Display the fetched user name
                style: GoogleFonts.poppins(
                  // Poppins for 'Hello Ankit,'
                  fontSize: 16, // Reduced font size for header
                  color: AppColors.neutralWhite,
                  fontWeight: FontWeight.w500, // Poppins Medium or SemiBold
                ),
              ),
              Text(
                'Do you already have Maid?',
                style: GoogleFonts.poppins(
                  // Poppins for 'Do you already have Maid?'
                  fontSize: 16, // Reduced font size for header
                  color: AppColors.neutralWhite,
                  fontWeight: FontWeight.w500, // Poppins Medium or SemiBold
                ),
              ),
            ],
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: LayoutBuilder(
        // Use LayoutBuilder to get available screen height
        builder: (context, constraints) {
          // Calculate screen height and illustration height within the builder
          final double screenHeight = MediaQuery.of(context).size.height;
          final double illustrationHeight =
              screenHeight * 0.40; // Adjusted height for better fit

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Column(
                      // This column holds all content above the illustration
                      children: [
                        const SizedBox(height: 20), // Spacing below app bar

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ), // Apply horizontal padding here
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // Distribute space evenly
                            children: [
                              // Yes Option Button
                              Expanded(
                                child: _buildToggleOption(
                                  context: context,
                                  title: 'Yes',
                                  subtitle: 'A maid is already working for me',
                                  value: 'yes',
                                  groupValue: _selectedOption,
                                  onTap: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ), // Spacing between options
                              // No Option Button
                              Expanded(
                                child: _buildToggleOption(
                                  context: context,
                                  title: 'No',
                                  subtitle: 'Looking for a Maid to work',
                                  value: 'no',
                                  groupValue: _selectedOption,
                                  onTap: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ), // Spacing between options and info card
                        // Informational Card (conditionally displayed)
                        if (_selectedOption !=
                            null) // Only show when an option is selected
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ), // Apply horizontal padding here
                            child: AnimatedOpacity(
                              opacity: _selectedOption != null ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: infoCardBackgroundColor,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Curved edges for the card
                                  border: Border.all(
                                    color: AppColors
                                        .neutralLightGray, // Thin grey outline
                                    width: 3.0, // Thicker border as requested
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.neutralMediumGray
                                          .withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      // Adjusted based on previous instructions to be more concise.
                                      _selectedOption == 'yes'
                                          ? 'Congratulations!'
                                          : 'No maid, no worries!',
                                      style: GoogleFonts.poppins(
                                        // Poppins Bold for info card title
                                        fontSize:
                                            AppTextStyles.heading4.fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.neutralBlack,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _selectedOption == 'yes'
                                          ? 'You\'re already a master of household harmony. Let us help you maintain that peace effortlessly with our maid management services'
                                          : 'Discover a world of trustworthy and verified maids at your fingertips. Your search for the perfect helping hand starts here.',
                                      style: GoogleFonts.poppins(
                                        // Poppins Regular for info card subtitle
                                        fontSize:
                                            AppTextStyles.bodyText.fontSize,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.neutralDarkGray,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_selectedOption == 'yes') {
                                            // 'Yes' implies "Manage/Onboard your current Maid" contextually
                                            // Navigate to FindMaidScreen for 'Yes'
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const FindMaidScreen(), // Corrected name
                                              ),
                                            );
                                          } else if (_selectedOption == 'no') {
                                            // 'No' implies "Looking for a Maid"
                                            // Navigate to SelectServiceScreen for 'No'
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const SelectServiceScreen(),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors
                                              .primaryPurple, // Button background color
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25.0,
                                            ), // More curved edges for buttons
                                          ),
                                        ),
                                        child: Text(
                                          'CONTINUE',
                                          style: GoogleFonts.poppins(
                                            // Poppins Medium for button
                                            fontSize: AppTextStyles
                                                .buttonText
                                                .fontSize,
                                            color: AppColors.neutralWhite,
                                            fontWeight: FontWeight
                                                .w500, // Medium weight
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Spacer to push content up, illustration down
                    const Spacer(),

                    // Bottom Illustration - Adjusted to touch all three sides and controlled height
                    Image.asset(
                      'assets/bottom_illustration.png',
                      height: illustrationHeight,
                      width: double
                          .infinity, // Ensures it takes full available width
                      fit: BoxFit
                          .cover, // Use BoxFit.cover to fill the space without leaving white
                      filterQuality:
                          FilterQuality.high, // High quality rendering
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to build each selectable option tile
  Widget _buildToggleOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required String? groupValue,
    required ValueChanged<String> onTap,
  }) {
    final bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : AppColors.neutralWhite, // Transparent grey for deselected
          borderRadius: BorderRadius.circular(
            15,
          ), // Rounded corners for option boxes
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.neutralLightGray, // Grey border for deselected
            width: 3, // Thicker border for yes/no boxes
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                // Poppins Medium or SemiBold for button text
                fontSize: AppTextStyles.heading4.fontSize,
                color: isSelected
                    ? AppColors.neutralWhite
                    : AppColors.neutralBlack,
                fontWeight: FontWeight.w500, // Medium weight
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // Poppins Regular for subtext
                fontSize: AppTextStyles.bodyText.fontSize,
                color: isSelected
                    ? AppColors.neutralWhite.withOpacity(0.8)
                    : AppColors.neutralDarkGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
