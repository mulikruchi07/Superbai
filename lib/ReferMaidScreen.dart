import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and other theme definitions are here
import 'package:flutter/services.dart'; // For Clipboard

class ReferMaidScreen extends StatefulWidget {
  const ReferMaidScreen({super.key});

  @override
  State<ReferMaidScreen> createState() => _ReferMaidScreenState();
}

class _ReferMaidScreenState extends State<ReferMaidScreen> {
  bool _isChecked = false;
  final String _referralCode = 'UJHSAC'; // Fixed code, not a controller anymore

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Copied "$text" to clipboard!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPink, // Pink background for AppBar
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // No title here, title content moved below AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Separate header section below AppBar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryPink, // Pink background
                // Removed bottom curved edges if any, ensuring it's a solid block
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center align content
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center align row content
                    children: [
                      Text(
                        'Earn 50',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          color: AppColors.neutralWhite, // White font color
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.monetization_on,
                        size: 28,
                        color: AppColors.emotionYellow, // Gold coin icon
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Invite a friend to SuperBai\nand get 50 Points when they do\ntheir first booking',
                    textAlign: TextAlign.center, // Center align text
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.neutralWhite, // White font color
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Reduced space after header
                  Text(
                    'Invite a friend',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // A little bold
                      color: Colors.black, // Black font color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    // Row to contain code box and share button
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ), // Adjusted vertical padding for height
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(
                              0.1,
                            ), // Purple transparent background
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Slightly curved edges
                          ),
                          child: Row(
                            // Added Row to place copy icon inside
                            children: [
                              Expanded(
                                child: Text(
                                  // Changed from TextField to Text for non-selectable fixed code
                                  _referralCode,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors
                                        .primaryPurple, // Purple code color
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                // Copy icon inside the code box
                                icon: Icon(
                                  Icons.copy,
                                  color: AppColors.primaryPurple,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _copyToClipboard(_referralCode);
                                },
                                padding: EdgeInsets
                                    .zero, // Remove default IconButton padding
                                constraints:
                                    BoxConstraints(), // Remove default IconButton constraints
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Space between code box and share button
                      Container(
                        // Container for share icon to give it a background and consistent height
                        padding: const EdgeInsets.all(
                          8,
                        ), // Adjusted padding to match height
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(
                            0.1,
                          ), // Purple transparent background
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Slightly curved edges
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: AppColors.primaryPurple,
                            size: 20,
                          ), // Share icon and color
                          onPressed: () {
                            // Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Share button clicked!')),
                            );
                          },
                          padding: EdgeInsets
                              .zero, // Remove default IconButton padding
                          constraints:
                              BoxConstraints(), // Remove default IconButton constraints
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'OR',
                      style: GoogleFonts.poppins(
                        fontSize: 22, // Increased "OR" text font size
                        fontWeight: FontWeight.normal, // Not bold
                        color: Colors.black, // Black font color
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Register a New Maid',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600, // A little bold
                      color: Colors.black, // Black font color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'After approval of your own maid fill-up the form\nbelow & Share the benefits of Registration with\nher.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black, // Black font color
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('Maid\'s Full Name'),
                  const SizedBox(height: 15),
                  _buildTextField('Maid\'s Contact'),
                  const SizedBox(height: 15),
                  _buildTextField('Location'),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24, // Standard checkbox size
                        height: 24,
                        child: Checkbox(
                          value: _isChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isChecked = newValue!;
                            });
                          },
                          activeColor:
                              AppColors.primaryPurple, // Purple when checked
                          checkColor: AppColors.neutralWhite, // White checkmark
                          materialTapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Reduce tap area
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'I here by agree, that i have taken maid\'s permission/\napproval to share her details.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black, // Black font color
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              'Terms and Conditions',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black, // Black font color
                                fontWeight: FontWeight.normal, // No underline
                                decoration: TextDecoration.none, // No underline
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    // Center the button, then make it full width
                    child: SizedBox(
                      width: double.infinity, // Full width button
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Submit button clicked!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryPurple, // Purple button
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ), // Maintained padding for height
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16, // Maintained font size
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildTextField(String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralLightGray, // Light gray background
        borderRadius: BorderRadius.circular(8), // Slightly curved edges
      ),
      child: TextField(
        style: GoogleFonts.poppins(
          fontSize: 14, // Small font size
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: AppColors.neutralMediumGray, // Dark grey hint text color
            fontSize: 14, // Small font size
          ),
          border: InputBorder.none,
          isDense: true, // Reduce TextField height
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ), // Reduced vertical padding for height
        ),
      ),
    );
  }
}
