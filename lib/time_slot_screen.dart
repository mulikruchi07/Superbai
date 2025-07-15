import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/salary_screen.dart'; // Import the new SalaryScreen
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts

class TimeSlotScreen extends StatefulWidget {
  const TimeSlotScreen({super.key});

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  // State variables for selected items
  TimeOfDay? _selectedFromTime;
  TimeOfDay? _selectedToTime;
  int _numberOfShifts = 1;

  // Data received from the previous screen (ProvidedServicesScreen)
  Map<String, dynamic>? _routeArguments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments when the route changes or dependencies change
    _routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  // Helper to show the time picker
  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _selectedFromTime = picked;
        } else {
          _selectedToTime = picked;
        }
      });
    }
  }

  // Helper to format TimeOfDay for display
  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select Time';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? maidData =
        _routeArguments?['maidData'] as Map<String, dynamic>?;
    final String? serviceTitle = _routeArguments?['serviceTitle'] as String?;

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            Navigator.pop(context); // Go back to ProvidedServicesScreen
          },
        ),
        title: Text(
          'Select your time-slot:', // Updated title text as per image
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal, // No bold
          ),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ), // Adjusted vertical padding
              decoration: BoxDecoration(
                color: AppColors
                    .neutralWhite, // Background color for 2/3 badge changed to white
                borderRadius: BorderRadius.circular(8), // Reduced curve
                border: Border.all(
                  color: AppColors.neutralWhite,
                  width: 0,
                ), // No border
              ),
              child: Center(
                child: Text(
                  '2/3', // Page indicator
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Small font size
                    color:
                        AppColors.primaryPurple, // Text color changed to purple
                    fontWeight: FontWeight.normal, // Not bold
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
            // Removed Lorem Ipsum text
            const SizedBox(height: 20), // Gap after paragraph (if it existed)
            // From and To Time Input Boxes
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutralWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neutralMediumGray,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.neutralDarkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatTime(_selectedFromTime),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutralWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neutralMediumGray,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.neutralDarkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatTime(_selectedToTime),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.neutralBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Select no. of shifts option
            Text(
              'Select no. of shifts',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(50.0), // Fully curved edges
                border: Border.all(
                  color: AppColors.neutralMediumGray,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_numberOfShifts > 1) _numberOfShifts--;
                      });
                    },
                    child: Icon(
                      Icons.remove,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '$_numberOfShifts',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _numberOfShifts++;
                      });
                    },
                    child: Icon(
                      Icons.add,
                      size: 20,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(), // Pushes the button to the bottom
            // Confirm Time-slot Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedFromTime != null && _selectedToTime != null) {
                    // Navigate to the new SalaryScreen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => SalaryScreen(
                          routeArguments: {
                            'selectedFromTime': _formatTime(_selectedFromTime),
                            'selectedToTime': _formatTime(_selectedToTime),
                            'numberOfShifts': _numberOfShifts,
                            'maidData':
                                maidData, // Pass maidData to next screen
                            'serviceTitle':
                                serviceTitle, // Pass serviceTitle to next screen
                            // Pass other arguments received from previous screen if needed
                            'currentSelectedAreaOption':
                                _routeArguments?['currentSelectedAreaOption'],
                            'currentSelectedAdditionalServices':
                                _routeArguments?['currentSelectedAdditionalServices'],
                            'currentSelectedMealType':
                                _routeArguments?['currentSelectedMealType'],
                            'currentSelectedMeals':
                                _routeArguments?['currentSelectedMeals'],
                            'currentSelectedCookingStyles':
                                _routeArguments?['currentSelectedCookingStyles'],
                            'currentSelectedPeopleCount':
                                _routeArguments?['currentSelectedPeopleCount'],
                            'currentHasWashingMachine':
                                _routeArguments?['currentHasWashingMachine'],
                            'currentSelectedLaundryAdditional':
                                _routeArguments?['currentSelectedLaundryAdditional'],
                            'currentSelectedTypeOfCare':
                                _routeArguments?['currentSelectedTypeOfCare'],
                            'currentSelectedHoursOfCare':
                                _routeArguments?['currentSelectedHoursOfCare'],
                            'currentSelectedSpecialNeeds':
                                _routeArguments?['currentSelectedSpecialNeeds'],
                            'currentSelectedChildAges':
                                _routeArguments?['currentSelectedChildAges'],
                            'currentNumChildren':
                                _routeArguments?['currentNumChildren'],
                            'currentSelectedActivities':
                                _routeArguments?['currentSelectedActivities'],
                            'currentSelectedAllRounderTypes':
                                _routeArguments?['currentSelectedAllRounderTypes'],
                            'currentBudget': _routeArguments?['currentBudget'],
                            'currentNumShifts':
                                _routeArguments?['currentNumShifts'],
                            'currentSelectedShiftTimes':
                                _routeArguments?['currentSelectedShiftTimes'],
                            'currentServiceType':
                                _routeArguments?['currentServiceType'],
                            'currentSelectedDays':
                                _routeArguments?['currentSelectedDays'],
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select both From and To times.'),
                      ),
                    );
                  }
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
                  'CONFIRM TIME-SLOT',
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
