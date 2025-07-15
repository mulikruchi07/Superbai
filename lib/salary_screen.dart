import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:superbai/time_slot_screen.dart'; // Import TimeSlotScreen for back navigation
import 'package:superbai/maid_linking_screen.dart'; // Import MaidLinkingScreen

class SalaryScreen extends StatefulWidget {
  final Map<String, dynamic>? routeArguments;

  const SalaryScreen({super.key, this.routeArguments});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  DateTime? _selectedDateOfPayment; // State variable for the selected date

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfPayment ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
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
    if (picked != null && picked != _selectedDateOfPayment) {
      setState(() {
        _selectedDateOfPayment = picked;
      });
    }
  }

  // Helper to format DateTime for display
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? maidData =
        widget.routeArguments?['maidData'] as Map<String, dynamic>?;
    final String? serviceTitle =
        widget.routeArguments?['serviceTitle'] as String?;
    final String? selectedFromTime =
        widget.routeArguments?['selectedFromTime'] as String?;
    final String? selectedToTime =
        widget.routeArguments?['selectedToTime'] as String?;
    final int? numberOfShifts =
        widget.routeArguments?['numberOfShifts'] as int?;
    // Retrieve the list of selected all-rounder sub-services
    final List<String>? currentSelectedAllRounderTypes =
        widget.routeArguments?['currentSelectedAllRounderTypes']
            as List<String>?;

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            // Navigate back to TimeSlotScreen, replacing the current route
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const TimeSlotScreen(),
                // Pass back the original arguments if TimeSlotScreen needs them
                settings: RouteSettings(arguments: widget.routeArguments),
              ),
            );
          },
        ),
        title: Text(
          'Mention the salary you pay:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutralWhite, width: 0),
              ),
              child: Center(
                child: Text(
                  '3/3', // Page indicator
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.primaryPurple.withOpacity(0.7),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Enter amount',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Like: 2000Rs. /month',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutralMediumGray,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: AppColors.neutralWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.neutralMediumGray,
                    width: 1.0,
                  ), // Thin border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.neutralMediumGray,
                    width: 1.0,
                  ), // Thin border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.primaryPurple,
                    width: 1.0,
                  ), // Thin purple border
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),

            // Date of Payment Input
            Text(
              'Date of Payment',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neutralWhite,
                  borderRadius: BorderRadius.circular(8), // Small curve
                  border: Border.all(
                    color: AppColors.neutralMediumGray,
                    width: 1.0,
                  ), // Thin border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(_selectedDateOfPayment),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _selectedDateOfPayment == null
                            ? AppColors.neutralMediumGray
                            : AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.neutralMediumGray,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Remark',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _remarkController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Write about any change you want in maid\'s behavior, work style ,etc',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutralMediumGray,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: AppColors.neutralWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.neutralMediumGray,
                    width: 1.0,
                  ), // Thin border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.neutralMediumGray,
                    width: 1.0,
                  ), // Thin border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // Small curve
                  borderSide: BorderSide(
                    color: AppColors.primaryPurple,
                    width: 1.0,
                  ), // Thin purple border
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Spacer(), // Pushes the button to the bottom

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Create a mutable copy of maidData and add salary/remark
                  Map<String, dynamic> updatedMaidData = Map.from(
                    maidData ?? {}, // Use the maidData received
                  );
                  updatedMaidData['salary'] = _amountController.text;
                  updatedMaidData['remark'] = _remarkController.text;
                  updatedMaidData['dateOfPayment'] = _formatDate(
                    _selectedDateOfPayment,
                  ); // Add date of payment

                  // Add time slot details
                  updatedMaidData['selectedFromTime'] = selectedFromTime;
                  updatedMaidData['selectedToTime'] = selectedToTime;
                  updatedMaidData['numberOfShifts'] = numberOfShifts;

                  // Add service title (which could be the main service or the last configured sub-service)
                  updatedMaidData['service'] = serviceTitle ?? 'N/A';
                  // Add the list of selected all-rounder sub-services
                  // This is crucial for passing the sub-services to MaidLinkingScreen
                  updatedMaidData['currentSelectedAllRounderTypes'] =
                      currentSelectedAllRounderTypes;

                  // Navigate to MaidLinkingScreen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MaidLinkingScreen(
                        // selectedDays and selectedTimeSlot are now redundant if fetching from maidData
                        selectedDays:
                            widget.routeArguments?['selectedDays'] ??
                            [], // Keeping for compatibility
                        selectedTimeSlot:
                            widget.routeArguments?['selectedTimeSlot'] ??
                            '', // Keeping for compatibility
                        maidData: updatedMaidData, // Pass the updated maidData
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ), // Fully curved edges
                  ),
                ),
                child: Text(
                  'CONFIRM & CONNECT',
                  style: GoogleFonts.poppins(
                    fontSize: AppTextStyles.buttonText.fontSize,
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600,
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
