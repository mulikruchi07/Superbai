import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:superbai/request_success_screen.dart'; // Import the new request success screen

class ConfirmationScreen extends StatefulWidget {
  // All the data that needs to be passed for confirmation
  final String serviceTitle;
  final String? currentSelectedAreaOption;
  final Set<String> currentSelectedAdditionalServices;
  final String? currentSelectedMealType;
  final Set<String> currentSelectedMeals;
  final Set<String> currentSelectedCookingStyles;
  final int currentSelectedPeopleCount;
  final bool? currentHasWashingMachine;
  final Set<String> currentSelectedLaundryAdditional;
  final Set<String> currentSelectedTypeOfCare;
  final String? currentSelectedHoursOfCare;
  final Set<String> currentSelectedSpecialNeeds;
  final Set<String> currentSelectedChildAges;
  final int currentNumChildren;
  final Set<String> currentSelectedActivities;
  final Set<String> currentSelectedAllRounderTypes;
  final double currentBudget;
  final int currentNumShifts;
  final Set<String> currentSelectedShiftTimes;
  final String? currentServiceType;
  final Set<String> currentSelectedDays;
  final String? customFromTime;
  final String? customToTime;
  final Map<String, Map<String, dynamic>>?
  allRounderSubServiceData; // New parameter for All-rounder details

  const ConfirmationScreen({
    super.key,
    required this.serviceTitle,
    this.currentSelectedAreaOption,
    required this.currentSelectedAdditionalServices,
    this.currentSelectedMealType,
    required this.currentSelectedMeals,
    required this.currentSelectedCookingStyles,
    required this.currentSelectedPeopleCount,
    this.currentHasWashingMachine,
    required this.currentSelectedLaundryAdditional,
    required this.currentSelectedTypeOfCare,
    this.currentSelectedHoursOfCare,
    required this.currentSelectedSpecialNeeds,
    required this.currentSelectedChildAges,
    required this.currentNumChildren,
    required this.currentSelectedActivities,
    required this.currentSelectedAllRounderTypes,
    required this.currentBudget,
    required this.currentNumShifts,
    required this.currentSelectedShiftTimes,
    this.currentServiceType,
    required this.currentSelectedDays,
    this.customFromTime,
    this.customToTime,
    this.allRounderSubServiceData, // Initialize the new parameter
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    // Initialize with a placeholder address. In a real app, this would fetch from user details.
    _addressController = TextEditingController(
      text:
          'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple, // AppBar background color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neutralWhite),
          onPressed: () {
            // Pop to go back to the previous screen (SelectServiceScreen's second modal)
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.serviceTitle.toUpperCase(), // Display selected service title
          style: GoogleFonts.poppins(
            fontSize: AppTextStyles.heading4.fontSize,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                // Allow scrolling if content overflows on smaller screens
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamically generate details based on serviceTitle
                    if (widget.serviceTitle == 'Cooking') ...[
                      _buildConfirmationRow(
                        'Meals',
                        widget.currentSelectedMeals.join(', '),
                      ),
                      _buildConfirmationRow(
                        'Type',
                        widget.currentSelectedMealType ?? 'N/A',
                      ),
                      _buildConfirmationRow(
                        'Style',
                        widget.currentSelectedCookingStyles.join(', '),
                      ),
                      _buildConfirmationRow(
                        'People',
                        widget.currentSelectedPeopleCount.toString(),
                      ),
                    ] else if (widget.serviceTitle == 'Cleaning') ...[
                      _buildConfirmationRow(
                        'Area',
                        widget.currentSelectedAreaOption ?? 'N/A',
                      ),
                      _buildConfirmationRow(
                        'Additional',
                        widget.currentSelectedAdditionalServices.join(', '),
                      ),
                    ] else if (widget.serviceTitle == 'Laundry') ...[
                      _buildConfirmationRow(
                        'People',
                        widget.currentSelectedPeopleCount.toString(),
                      ),
                      _buildConfirmationRow(
                        'Washing Machine',
                        widget.currentHasWashingMachine == true
                            ? 'Yes'
                            : (widget.currentHasWashingMachine == false
                                  ? 'No'
                                  : 'N/A'),
                      ),
                      _buildConfirmationRow(
                        'Additional',
                        widget.currentSelectedLaundryAdditional.join(', '),
                      ),
                    ] else if (widget.serviceTitle == 'Elder-care') ...[
                      _buildConfirmationRow(
                        'Type of Care',
                        widget.currentSelectedTypeOfCare.join(', '),
                      ),
                      _buildConfirmationRow(
                        'Hours of Care',
                        widget.currentSelectedHoursOfCare ?? 'N/A',
                      ),
                      _buildConfirmationRow(
                        'Special Needs',
                        widget.currentSelectedSpecialNeeds.join(', '),
                      ),
                    ] else if (widget.serviceTitle == 'Babysitter') ...[
                      _buildConfirmationRow(
                        'No. of Children',
                        widget.currentNumChildren.toString(),
                      ),
                      _buildConfirmationRow(
                        'Child\'s Age',
                        widget.currentSelectedChildAges.join(', '),
                      ),
                      _buildConfirmationRow(
                        'Activities',
                        widget.currentSelectedActivities.join(', '),
                      ),
                    ] else if (widget.serviceTitle == 'All-rounder') ...[
                      _buildConfirmationRow(
                        'Selected Types',
                        widget.currentSelectedAllRounderTypes.join(', '),
                      ),
                    ],

                    const SizedBox(height: 15), // Reduced spacing
                    // General Pricing, Shifts, Service Type
                    _buildConfirmationRow(
                      'Pricing', // Changed from Budget to Pricing
                      'Rs. ${widget.currentBudget.toInt()}',
                    ),
                    _buildConfirmationRow(
                      'Service Type',
                      widget.currentServiceType ?? 'N/A',
                    ),
                    if (widget.currentServiceType == 'Daily')
                      _buildConfirmationRow(
                        'Time Slots',
                        widget.currentSelectedShiftTimes.join(', '),
                      ),
                    if (widget.currentServiceType == 'Custom') ...[
                      _buildConfirmationRow(
                        'Date',
                        widget.currentSelectedDays.join(
                          ', ',
                        ), // This will contain the formatted custom date
                      ),
                      _buildConfirmationRow(
                        'From Time',
                        widget.customFromTime ?? 'N/A',
                      ),
                      _buildConfirmationRow(
                        'To Time',
                        widget.customToTime ?? 'N/A',
                      ),
                    ],
                    _buildConfirmationRow(
                      'Shifts per day',
                      '${widget.currentNumShifts}',
                    ),
                    // NEW: Display details for each selected sub-service in All-rounder, if applicable
                    if (widget.serviceTitle == 'All-rounder' &&
                        widget.allRounderSubServiceData != null)
                      ...widget.allRounderSubServiceData!.entries.map((entry) {
                        final subServiceTitle = entry.key;
                        final subServiceData = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ), // Spacing before sub-service details
                            Text(
                              '${subServiceTitle} Filters:', // Changed "Details" to "Filters"
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutralBlack,
                              ),
                            ),
                            if (subServiceTitle == 'Cleaning') ...[
                              _buildConfirmationRow(
                                'Area',
                                subServiceData['currentSelectedAreaOption'] ??
                                    'N/A',
                              ),
                              _buildConfirmationRow(
                                'Additional',
                                (subServiceData['currentSelectedAdditionalServices']
                                        as Set<String>)
                                    .join(', '),
                              ),
                            ] else if (subServiceTitle == 'Cooking') ...[
                              _buildConfirmationRow(
                                'Meals',
                                (subServiceData['currentSelectedMeals']
                                        as Set<String>)
                                    .join(', '),
                              ),
                              _buildConfirmationRow(
                                'Type',
                                subServiceData['currentSelectedMealType'] ??
                                    'N/A',
                              ),
                              _buildConfirmationRow(
                                'Style',
                                (subServiceData['currentSelectedCookingStyles']
                                        as Set<String>)
                                    .join(', '),
                              ),
                              _buildConfirmationRow(
                                'People',
                                subServiceData['currentSelectedPeopleCount']
                                    .toString(),
                              ),
                            ] else if (subServiceTitle == 'Laundry') ...[
                              _buildConfirmationRow(
                                'People',
                                subServiceData['currentSelectedPeopleCount']
                                    .toString(),
                              ),
                              _buildConfirmationRow(
                                'Washing Machine',
                                subServiceData['currentHasWashingMachine'] ==
                                        true
                                    ? 'Yes'
                                    : (subServiceData['currentHasWashingMachine'] ==
                                              false
                                          ? 'No'
                                          : 'N/A'),
                              ),
                              _buildConfirmationRow(
                                'Additional',
                                (subServiceData['currentSelectedLaundryAdditional']
                                        as Set<String>)
                                    .join(', '),
                              ),
                            ] else if (subServiceTitle == 'Elder-care') ...[
                              _buildConfirmationRow(
                                'Type of Care',
                                (subServiceData['currentSelectedTypeOfCare']
                                        as Set<String>)
                                    .join(', '),
                              ),
                              _buildConfirmationRow(
                                'Hours of Care',
                                subServiceData['currentSelectedHoursOfCare'] ??
                                    'N/A',
                              ),
                              _buildConfirmationRow(
                                'Special Needs',
                                (subServiceData['currentSelectedSpecialNeeds']
                                        as Set<String>)
                                    .join(', '),
                              ),
                            ] else if (subServiceTitle == 'Babysitter') ...[
                              _buildConfirmationRow(
                                'No. of Children',
                                subServiceData['currentNumChildren'].toString(),
                              ),
                              _buildConfirmationRow(
                                'Child\'s Age',
                                (subServiceData['currentSelectedChildAges']
                                        as Set<String>)
                                    .join(', '),
                              ),
                              _buildConfirmationRow(
                                'Activities',
                                (subServiceData['currentSelectedActivities']
                                        as Set<String>)
                                    .join(', '),
                              ),
                            ],
                          ],
                        );
                      }).toList(),
                    const SizedBox(height: 15), // Reduced spacing
                    // Address section
                    Text(
                      'Address',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500, // Medium weight for labels
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ), // Adjusted padding
                      decoration: BoxDecoration(
                        color: AppColors.neutralLightGray.withOpacity(
                          0.5,
                        ), // Light transparent gray
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neutralMediumGray,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _addressController,
                              maxLines: null, // Allows multiline input
                              keyboardType: TextInputType.multiline,
                              decoration: const InputDecoration(
                                border:
                                    InputBorder.none, // Remove default border
                                isDense: true, // Reduce vertical space
                                contentPadding:
                                    EdgeInsets.zero, // Remove inner padding
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 13, // Smaller font size
                                fontWeight: FontWeight
                                    .normal, // Regular weight for paragraph
                                color: AppColors.neutralDarkGray,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8), // Reduced spacing
                          Icon(
                            Icons.edit,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ), // Smaller icon
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Adjusted spacing
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the new RequestSuccessScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestSuccessScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: Text(
                  'CONFIRM REQUIREMENTS',
                  style: GoogleFonts.poppins(
                    fontSize: AppTextStyles.buttonText.fontSize,
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w600, // SemiBold for button
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

  // Helper widget for confirmation page rows
  Widget _buildConfirmationRow(String label, String value) {
    // Check if the value is empty or "N/A" and return an empty SizedBox to hide the row
    if (value.isEmpty || value == 'N/A' || value.trim() == '') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ), // Slightly reduced bottom padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using a fixed width for the label to align the ":"
          SizedBox(
            width:
                100, // Increased width to accommodate longer labels on one line
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14, // Smaller font size for labels
                fontWeight: FontWeight.w500, // Medium weight for labels
                color: AppColors.neutralBlack,
              ),
              maxLines: 1, // Ensure label stays on single line
              overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(
              fontSize: 14, // Smaller font size
              fontWeight: FontWeight.w500,
              color: AppColors.neutralBlack,
            ),
          ),
          const SizedBox(width: 8), // Reduced spacing
          Expanded(
            // Expanded to give remaining space to values
            child: Wrap(
              spacing: 6.0, // Reduced spacing
              runSpacing: 6.0, // Reduced spacing
              children: value.split(', ').map((item) {
                // Return an empty SizedBox if item is empty after split (e.g., from an empty Set)
                if (item.trim().isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ), // Further reduced padding
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightPurple.withOpacity(
                      0.1,
                    ), // Light transparent purple
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Slightly more curved
                    border: Border.all(
                      color: AppColors.primaryPurple,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 12, // Smaller font size for chip text
                      fontWeight: FontWeight.normal, // Regular for chip text
                      color: AppColors.primaryPurple,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
