import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Ensure theme.dart is imported
import 'package:superbai/booking_screen.dart'; // Import BookingScreen for navigation

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  String? _selectedReason; // Stores the selected reason for complaint
  final TextEditingController _remarkController = TextEditingController();

  final List<String> _complaintReasons = [
    'Reason 1',
    'Reason 2',
    'Reason 3',
    'Reason 4',
    'Reason 5',
    'Reason 6',
    'Reason 7',
    'Reason 8',
    'Reason 9',
  ];

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  // Function to show the reason selection popup
  void _showReasonSelectionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.neutralWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Slightly curved edges for popup
          ),
          title: Text(
            'Select Reason',
            style: GoogleFonts.poppins(
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _complaintReasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(
                    reason,
                    style: GoogleFonts.poppins(
                      color: AppColors.neutralBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReason = newValue;
                    });
                    Navigator.pop(dialogContext); // Close the dialog
                  },
                  activeColor: AppColors.primaryPurple, // Color of selected radio button
                  controlAffinity: ListTileControlAffinity.trailing, // Radio button on the right
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Function to show the complaint registered popup
  void _showComplaintRegisteredPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.neutralWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Slightly curved edges for popup
          ),
          contentPadding: const EdgeInsets.all(20), // Padding inside the alert
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined, // File icon
                color: AppColors.emotionOrangeRed, // Red color
                size: 60,
              ),
              const SizedBox(height: 15),
              Text(
                'Complaint Registered !',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.emotionOrangeRed, // Red color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Complaint ID: 216534874',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.neutralBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We are sorry for your trouble.\nYour problem would be solved as soon as possible.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.neutralDarkGray,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen (BookingScreen)
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pop(context); // Go back to BookingScreen
          },
        ),
        title: Text(
          'File a Complaint',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for Complaint*',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w500, // Medium weight
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showReasonSelectionPopup,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(8), // Less curved edges
                  border: Border.all(color: AppColors.neutralMediumGray, width: 1), // Thin grey border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedReason ?? 'Select your reason',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedReason == null ? AppColors.neutralMediumGray : AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.neutralDarkGray),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Remark',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w500, // Medium weight
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _remarkController,
              maxLines: 5, // Allow multiple lines for remark
              decoration: InputDecoration(
                hintText: 'Write your complaint',
                hintStyle: GoogleFonts.poppins(color: AppColors.neutralMediumGray, fontSize: 14),
                filled: true,
                fillColor: AppColors.neutralWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Less curved edges
                  borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1), // Thin grey border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              ),
              style: GoogleFonts.poppins(color: AppColors.neutralBlack, fontSize: 14),
            ),
            const Spacer(), // Pushes the button to the bottom

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedReason == null || _remarkController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a reason and write your complaint.')),
                    );
                  } else {
                    _showComplaintRegisteredPopup(); // Show success popup
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Fully curved edges
                  ),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(
                    fontSize: AppTextStyles.buttonText.fontSize,
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w500, // Medium weight
                    letterSpacing: 1.5,
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
