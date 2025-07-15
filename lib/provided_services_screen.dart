import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:superbai/time_slot_screen.dart'; // Changed import to TimeSlotScreen

class ProvidedServicesScreen extends StatefulWidget {
  // Added maidData parameter as it will be passed from MaidDetailsScreen
  final Map<String, dynamic> maidData;
  final String?
  initialServiceTitle; // Keep for consistency if needed, but not used in this flow

  const ProvidedServicesScreen({
    super.key,
    required this.maidData,
    this.initialServiceTitle,
  });

  @override
  State<ProvidedServicesScreen> createState() => _ProvidedServicesScreenState();
}

class _ProvidedServicesScreenState extends State<ProvidedServicesScreen> {
  // Define a list of service items with their titles and image paths
  final List<Map<String, dynamic>> _services = [
    {'title': 'Cleaning', 'image': 'assets/dashboard_images/cleaning_icon.png'},
    {'title': 'Cooking', 'image': 'assets/dashboard_images/cooking_icon.jpg'},
    {'title': 'Laundry', 'image': 'assets/dashboard_images/laundry_icon.png'},
    {
      'title': 'Elder-care',
      'image': 'assets/dashboard_images/elder_care_icon.png',
    },
    {
      'title': 'Babysitter',
      'image': 'assets/dashboard_images/baby_sitter_icon.png',
    },
    {
      'title': 'All-rounder',
      'image': 'assets/dashboard_images/all_rounder_icon.png',
    },
  ];

  // Map to store selected states for each service's options
  String? _currentSelectedAreaOption;
  Set<String> _currentSelectedAdditionalServices = {};
  String? _currentSelectedMealType;
  Set<String> _currentSelectedMeals = {};
  Set<String> _currentSelectedCookingStyles = {};
  int _currentSelectedPeopleCount = 1; // For Laundry/Babysitter initial
  bool? _currentHasWashingMachine;
  Set<String> _currentSelectedLaundryAdditional = {};
  Set<String> _currentSelectedTypeOfCare = {};
  String? _currentSelectedHoursOfCare;
  Set<String> _currentSelectedSpecialNeeds = {};
  Set<String> _currentSelectedChildAges = {};
  int _currentNumChildren = 1; // Default for babysitter
  Set<String> _currentSelectedActivities = {};
  Set<String> _currentSelectedAllRounderTypes = {};

  // These variables are kept to satisfy the arguments needed for TimeSlotScreen, but their values are not updated via UI.
  double _currentBudget = 4000;
  int _currentNumShifts = 1;
  Set<String> _currentSelectedShiftTimes = {};
  String? _currentServiceType;
  Set<String> _currentSelectedDays = {};

  // Store the selected service title to pass to the confirmation screen
  String _selectedServiceTitle = '';

  // Keep track of the index of the current all-rounder sub-service being configured
  int _currentAllRounderServiceIndex = 0;
  List<String> _allRounderSelectedSubServices = [];

  // Define the filters for each service
  final Map<String, List<Map<String, dynamic>>> _serviceFilters = {
    'Cleaning': [
      {
        'heading': 'Select the area you need cleaning',
        'type': 'single_select',
        'options': [
          '1RK',
          '1BHK',
          '2BHK',
          '3BHK',
          '4BHK',
          '5BHK and more',
        ], // Added 1RK, changed 5BHK
        'has_input': false, // Removed input box
      },
      {
        'heading': 'Additional services',
        'type': 'multi_select',
        'options': ['Bathroom', 'Balcony', 'House-shifting', 'Other'],
        'has_input': false,
      },
    ],
    'Cooking': [
      {
        'heading': 'Select the Meal(s)',
        'type': 'multi_select',
        'options': ['Breakfast', 'Lunch', 'Dinner'],
        'has_input': false,
      },
      {
        'heading': 'Select Type',
        'type': 'single_select',
        'options': ['Veg', 'Non-Veg'],
        'has_input': false,
      },
      {
        'heading': 'Select the Style',
        'type': 'multi_select',
        'options': [
          'Maharashtrian',
          'South Indian',
          'Jain',
          'Italian',
          'Everything',
        ],
        'has_input': false,
      },
      {
        'heading':
            'Select the no. of meals', // Clarified heading for image context
        'type': 'single_select',
        'options': ['1', '2', '3', '4', '5', '6'],
        'has_input': true,
        'input_hint': 'Enter Number',
      },
    ],
    'Laundry': [
      {
        'heading': 'Select the no. of people',
        'type': 'single_select',
        'options': ['1', '2', '3', '4', '5', '6'],
        'has_input': true,
        'input_hint': 'Enter Number',
      },
      {
        'heading': 'Washing machine',
        'type': 'single_select_boolean', // Custom type for Yes/No
        'options': ['Yes', 'No'],
        'has_input': false,
      },
      {
        'heading': 'Additional',
        'type': 'multi_select',
        'options': ['Folding', 'Ironing'],
        'has_input': false,
      },
    ],
    'Elder-care': [
      {
        'heading': 'Type of Care',
        'type': 'multi_select',
        'options': [
          'Medication Management',
          'Companionship',
          'Dementia Care',
          'Mobility Assistance',
          'Personal Care (e.g., bathing, dressing)',
        ],
        'has_input': false,
      },
      {
        'heading': 'Hours of Care',
        'type': 'single_select',
        'options': ['Part-Time', 'Full-Time', 'Overnight'],
        'has_input': false,
      },
      {
        'heading': 'Special needs',
        'type': 'multi_select',
        'options': [
          'Alzheimer\'s/Dementia',
          'Parkinson\'s',
          'Diabetes',
          'Mobility Issues',
        ],
        'has_input': true,
        'input_hint': 'Enter Needs',
      },
    ],
    'Babysitter': [
      {
        'heading': 'No of Children',
        'type': 'number_stepper', // Custom type for stepper input
        'options': [], // No static options for stepper
        'has_input': false,
      },
      {
        'heading': 'Child\'s Age',
        'type': 'multi_select',
        'options': [
          'Infants (0-1 years)',
          'Toddlers (2-4 years)',
          'School-Aged (5-12 years)',
          'Teenagers (13+ years)',
        ],
        'has_input': false,
      },
      {
        'heading': 'Activities',
        'type': 'multi_select',
        'options': [
          'Homework help',
          'Arts and crafts',
          'Outdoor Play',
          'Educational Activities',
          'School pick & drop',
        ],
        'has_input': true,
        'input_hint': 'Enter Activity',
      },
    ],
    'All-rounder': [
      {
        'heading': 'Select type(s)',
        'type': 'multi_select',
        'options': [
          'Cleaning',
          'Cooking',
          'Laundry', // Changed from 'Washing Clothes' to 'Laundry' to match other service titles
          'Elder-care', // Changed from 'Elderly care' to 'Elder-care'
          'Babysitter', // Changed from 'Baby Sitting' to 'Babysitter'
        ],
        'has_input': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    // If an initial service title is provided, open its details sheet after the first frame
    if (widget.initialServiceTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedServiceTitle =
            widget.initialServiceTitle!; // Set the selected title
        _showServiceDetailsSheet(context, widget.initialServiceTitle!);
      });
    }
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
            // Navigate back to the MaidDetailsScreen
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select the Services',
          style: GoogleFonts.poppins(
            // Poppins Medium or SemiBold
            fontSize: 16, // Reduced font size
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w500, // Medium weight
          ),
        ),
        centerTitle: false, // Align title to the left
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ), // Increased vertical padding
              decoration: BoxDecoration(
                color: AppColors
                    .neutralWhite, // Background color for 1/3 badge changed to white
                borderRadius: BorderRadius.circular(8), // Reduced curve
                border: Border.all(
                  color: AppColors.neutralWhite,
                  width: 0,
                ), // No border
              ),
              child: Center(
                child: Text(
                  '1/3', // Page indicator
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 20.0, // Horizontal spacing
                  mainAxisSpacing: 20.0, // Vertical spacing
                  childAspectRatio:
                      0.9, // Adjust aspect ratio for better image/text fit
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return _buildServiceItem(
                    context,
                    _services[index]['image']!,
                    _services[index]['title']!,
                  );
                },
              ),
            ),
          ),
          // Removed the "Confirm Service" button from here
        ],
      ),
    );
  }

  // Helper widget to build each service item in the grid
  Widget _buildServiceItem(
    BuildContext context,
    String imagePath,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        _selectedServiceTitle = title; // Store the selected service title
        _currentAllRounderServiceIndex = 0; // Reset for new selection
        _allRounderSelectedSubServices.clear(); // Clear previous sub-services
        // When a service is tapped, open its details sheet
        _showServiceDetailsSheet(context, title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite, // White background for service item
          borderRadius: BorderRadius.circular(12.0), // Reduced rounded corners
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralMediumGray.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 100, // Fixed height for image
              width: 100, // Fixed width for image
              fit: BoxFit.contain, // Ensure image fits without cropping
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  size: 80,
                  color: AppColors.neutralMediumGray,
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // Poppins Regular or Medium
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w500, // Medium weight
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to navigate to TimeSlotScreen
  void _navigateToTimeSlotScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeSlotScreen(),
        settings: RouteSettings(
          arguments: {
            'maidData': widget.maidData, // Pass maidData from MaidDetailsScreen
            'serviceTitle': _selectedServiceTitle,
            'currentSelectedAreaOption': _currentSelectedAreaOption,
            'currentSelectedAdditionalServices':
                _currentSelectedAdditionalServices
                    .toList(), // Convert Set to List
            'currentSelectedMealType': _currentSelectedMealType,
            'currentSelectedMeals': _currentSelectedMeals
                .toList(), // Convert Set to List
            'currentSelectedCookingStyles': _currentSelectedCookingStyles
                .toList(), // Convert Set to List
            'currentSelectedPeopleCount': _currentSelectedPeopleCount,
            'currentHasWashingMachine': _currentHasWashingMachine,
            'currentSelectedLaundryAdditional':
                _currentSelectedLaundryAdditional
                    .toList(), // Convert Set to List
            'currentSelectedTypeOfCare': _currentSelectedTypeOfCare
                .toList(), // Convert Set to List
            'currentSelectedHoursOfCare': _currentSelectedHoursOfCare,
            'currentSelectedSpecialNeeds': _currentSelectedSpecialNeeds
                .toList(), // Convert Set to List
            'currentSelectedChildAges': _currentSelectedChildAges
                .toList(), // Convert Set to List
            'currentNumChildren': _currentNumChildren,
            'currentSelectedActivities': _currentSelectedActivities
                .toList(), // Convert Set to List
            'currentSelectedAllRounderTypes': _currentSelectedAllRounderTypes
                .toList(), // Convert Set to List
            'currentBudget': _currentBudget, // Dummy values
            'currentNumShifts': _currentNumShifts, // Dummy values
            'currentSelectedShiftTimes': _currentSelectedShiftTimes
                .toList(), // Dummy values, convert Set to List
            'currentServiceType': _currentServiceType, // Dummy values
            'currentSelectedDays': _currentSelectedDays
                .toList(), // Dummy values, convert Set to List
          },
        ),
      ),
    );
  }

  // Function to show the service details modal sheet
  void _showServiceDetailsSheet(BuildContext context, String serviceTitle) {
    // Reset selections when showing a new sheet, unless it's a sub-service modal in all-rounder flow
    if (!(_allRounderSelectedSubServices.isNotEmpty &&
        serviceTitle != 'All-rounder')) {
      _currentSelectedAreaOption = null;
      _currentSelectedAdditionalServices.clear();
      _currentSelectedMealType = null;
      _currentSelectedMeals.clear();
      _currentSelectedCookingStyles.clear();
      _currentSelectedPeopleCount = 1;
      _currentHasWashingMachine = null;
      _currentSelectedLaundryAdditional.clear();
      _currentSelectedTypeOfCare.clear();
      _currentSelectedHoursOfCare = null;
      _currentSelectedSpecialNeeds.clear();
      _currentSelectedChildAges.clear();
      _currentNumChildren = 1;
      _currentSelectedActivities.clear();
      _currentSelectedAllRounderTypes.clear();

      // Reset states for the second modal (these are now dummy values)
      _currentBudget = 4000;
      _currentNumShifts = 1;
      _currentSelectedShiftTimes.clear();
      _currentServiceType = null;
      _currentSelectedDays.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.0),
        ), // Reduced curved top corners
      ),
      backgroundColor: AppColors.neutralWhite, // Set background to white
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state inside modal
          builder: (BuildContext context, StateSetter modalSetState) {
            List<Map<String, dynamic>>? filters;
            String currentModalServiceTitle = serviceTitle;

            // Determine which filters to show based on serviceTitle and all-rounder flow
            if (serviceTitle == 'All-rounder' &&
                _allRounderSelectedSubServices.isNotEmpty) {
              currentModalServiceTitle =
                  _allRounderSelectedSubServices[_currentAllRounderServiceIndex];
              filters = _serviceFilters[currentModalServiceTitle];
            } else {
              filters = _serviceFilters[serviceTitle];
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Adjust for keyboard
              ),
              child: Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.75, // Approx 75% of screen height
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle/Drag Indicator - KEPT THIS ONE FOR THE FIRST MODAL
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neutralMediumGray,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    Text(
                      currentModalServiceTitle
                          .toUpperCase(), // Service Title in all caps
                      style: GoogleFonts.poppins(
                        // Poppins SemiBold or Bold
                        fontSize:
                            AppTextStyles.heading4.fontSize, // Adjusted size
                        fontWeight: FontWeight.w600, // SemiBold
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      // Use Expanded to make content scrollable if it overflows
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (filters != null)
                              ...filters.map((filterSection) {
                                // Explicitly convert to List<String> to prevent TypeError
                                final List<String> currentOptions =
                                    List<String>.from(
                                      filterSection['options'] as List<dynamic>,
                                    );

                                return _buildFilterSection(
                                  modalSetState,
                                  filterSection['heading'] as String,
                                  filterSection['type'] as String,
                                  currentOptions, // Use the converted list
                                  filterSection['has_input'] as bool,
                                  filterSection['input_hint'] as String?,
                                  currentModalServiceTitle, // Pass serviceTitle to manage specific states
                                );
                              }).toList(),
                            const SizedBox(
                              height: 20,
                            ), // Spacing before the next button if content is short
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle the initial 'All-rounder' selection
                          if (serviceTitle == 'All-rounder' &&
                              _allRounderSelectedSubServices.isEmpty) {
                            // Capture the selected sub-services from the 'All-rounder' filter
                            _allRounderSelectedSubServices =
                                _currentSelectedAllRounderTypes.toList();

                            // If no sub-services were selected, navigate directly to TimeSlotScreen
                            if (_allRounderSelectedSubServices.isEmpty) {
                              Navigator.pop(
                                context,
                              ); // Pop the current 'All-rounder' modal
                              _navigateToTimeSlotScreen(context);
                              return;
                            } else {
                              // Selected sub-services, open the first one
                              Navigator.pop(
                                context,
                              ); // Pop the initial All-rounder modal
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _currentAllRounderServiceIndex =
                                    0; // Start from the first sub-service
                                _showServiceDetailsSheet(
                                  context,
                                  _allRounderSelectedSubServices[_currentAllRounderServiceIndex],
                                );
                              });
                              return; // Important to return after scheduling the next modal
                            }
                          }

                          // Handle subsequent sub-service modals in the 'All-rounder' flow
                          if (_allRounderSelectedSubServices.isNotEmpty &&
                              _currentAllRounderServiceIndex <
                                  _allRounderSelectedSubServices.length - 1) {
                            setState(() {
                              _currentAllRounderServiceIndex++;
                            });
                            Navigator.pop(
                              context,
                            ); // Pop the current sub-service modal
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showServiceDetailsSheet(
                                context,
                                _allRounderSelectedSubServices[_currentAllRounderServiceIndex],
                              );
                            });
                            return; // Important to return after scheduling the next modal
                          }

                          // Final navigation for the last sub-service or a single service
                          Navigator.pop(context); // Pop the current modal
                          _navigateToTimeSlotScreen(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              50.0,
                            ), // Fully curved edges
                          ),
                        ),
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.poppins(
                            // Poppins Medium or SemiBold
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
          },
        );
      },
      // Removed the .whenComplete() block from here
    );
  }

  // Helper widget to build each service item in the grid
  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    Color borderColor = AppColors.neutralMediumGray;
    Color fillColor = AppColors.neutralWhite;
    Color textColor = AppColors.neutralBlack;

    if (text == 'Veg') {
      borderColor = AppColors.emotionGreen; // Thin green outline
      fillColor = isSelected
          ? AppColors.emotionGreen.withOpacity(0.1)
          : AppColors
                .neutralWhite; // Light transparent green fill, transparent when not selected
      textColor = AppColors.emotionGreen; // Green text
    } else if (text == 'Non-Veg') {
      borderColor = AppColors.emotionOrangeRed; // Thin red outline
      fillColor = isSelected
          ? AppColors.emotionOrangeRed.withOpacity(0.1)
          : AppColors
                .neutralWhite; // Light transparent red fill, transparent when not selected
      textColor = AppColors.emotionOrangeRed; // Red text
    } else {
      borderColor = isSelected
          ? AppColors.primaryPurple
          : AppColors.neutralMediumGray;
      fillColor = isSelected
          ? AppColors.primaryPurple.withOpacity(0.1)
          : AppColors.neutralWhite;
      textColor = isSelected ? AppColors.primaryPurple : AppColors.neutralBlack;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ), // Smaller padding
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(50.0), // Fully curved edges
          border: Border.all(
            color: borderColor,
            width: 1.5, // Slightly thinner border for options
          ),
        ),
        child: Text(
          text, // Keep original case if it's not strictly all caps in UI
          style: GoogleFonts.poppins(
            // Poppins Regular for options
            fontSize: 13, // Smaller font size
            color: textColor, // Text color changes with selection
            fontWeight: FontWeight.normal, // Regular weight
          ),
        ),
      ),
    );
  }

  // Helper to build a filter section with heading and options
  Widget _buildFilterSection(
    StateSetter modalSetState,
    String heading,
    String type,
    List<String> options, // Now guaranteed to be List<String>
    bool hasInput,
    String? inputHint,
    String serviceTitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: GoogleFonts.poppins(
            // Poppins Medium
            fontSize: 14, // Smaller font size
            fontWeight: FontWeight.w500, // Medium
            color: AppColors.neutralDarkGray,
          ),
        ),
        const SizedBox(height: 10),
        if (type ==
            'number_stepper') // Special handling for Babysitter children count
          _buildNumberStepperInput(modalSetState)
        else
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              ...options.map((option) {
                bool isSelected = false;
                if (serviceTitle == 'Cleaning') {
                  if (type == 'single_select') {
                    isSelected = _currentSelectedAreaOption == option;
                  } else if (type == 'multi_select') {
                    isSelected = _currentSelectedAdditionalServices.contains(
                      option,
                    );
                  }
                } else if (serviceTitle == 'Cooking') {
                  if (type == 'multi_select' &&
                      heading == 'Select the Meal(s)') {
                    isSelected = _currentSelectedMeals.contains(option);
                  } else if (type == 'single_select' &&
                      heading == 'Select Type') {
                    isSelected = _currentSelectedMealType == option;
                  } else if (type == 'multi_select' &&
                      heading == 'Select the Style') {
                    isSelected = _currentSelectedCookingStyles.contains(option);
                  } else if (type == 'single_select' &&
                      heading == 'Select the no. of meals') {
                    isSelected =
                        (_currentSelectedPeopleCount.toString() == option);
                  }
                } else if (serviceTitle == 'Laundry') {
                  if (type == 'single_select') {
                    isSelected =
                        (_currentSelectedPeopleCount.toString() == option);
                  } else if (type == 'single_select_boolean') {
                    isSelected =
                        (_currentHasWashingMachine == (option == 'Yes'));
                  } else if (type == 'multi_select') {
                    isSelected = _currentSelectedLaundryAdditional.contains(
                      option,
                    );
                  }
                } else if (serviceTitle == 'Elder-care') {
                  if (type == 'multi_select' && heading == 'Type of Care') {
                    isSelected = _currentSelectedTypeOfCare.contains(option);
                  } else if (type == 'single_select' &&
                      heading == 'Hours of Care') {
                    isSelected = _currentSelectedHoursOfCare == option;
                  } else if (type == 'multi_select' &&
                      heading == 'Special needs') {
                    isSelected = _currentSelectedSpecialNeeds.contains(option);
                  }
                } else if (serviceTitle == 'Babysitter') {
                  if (type == 'multi_select' && heading == 'Child\'s Age') {
                    isSelected = _currentSelectedChildAges.contains(option);
                  } else if (type == 'multi_select' &&
                      heading == 'Activities') {
                    isSelected = _currentSelectedActivities.contains(option);
                  }
                } else if (serviceTitle == 'All-rounder') {
                  if (type == 'multi_select') {
                    isSelected = _currentSelectedAllRounderTypes.contains(
                      option,
                    );
                  }
                }

                return _buildOptionButton(option, isSelected, () {
                  modalSetState(() {
                    if (serviceTitle == 'Cleaning') {
                      if (type == 'single_select') {
                        _currentSelectedAreaOption = option;
                      } else if (type == 'multi_select') {
                        if (_currentSelectedAdditionalServices.contains(
                          option,
                        )) {
                          _currentSelectedAdditionalServices.remove(option);
                        } else {
                          _currentSelectedAdditionalServices.add(option);
                        }
                      }
                    } else if (serviceTitle == 'Cooking') {
                      if (type == 'multi_select' &&
                          heading == 'Select the Meal(s)') {
                        if (_currentSelectedMeals.contains(option)) {
                          _currentSelectedMeals.remove(option);
                        } else {
                          _currentSelectedMeals.add(option);
                        }
                      } else if (type == 'single_select' &&
                          heading == 'Select Type') {
                        _currentSelectedMealType = option;
                      } else if (type == 'multi_select' &&
                          heading == 'Select the Style') {
                        if (_currentSelectedCookingStyles.contains(option)) {
                          _currentSelectedCookingStyles.remove(option);
                        } else {
                          _currentSelectedCookingStyles.add(option);
                        }
                      } else if (type == 'single_select' &&
                          heading == 'Select the no. of meals') {
                        _currentSelectedPeopleCount =
                            int.tryParse(option) ??
                            _currentSelectedPeopleCount; // Handle potential non-numeric option
                      }
                    } else if (serviceTitle == 'Laundry') {
                      if (type == 'single_select') {
                        _currentSelectedPeopleCount =
                            int.tryParse(option) ?? _currentSelectedPeopleCount;
                      } else if (type == 'single_select_boolean') {
                        _currentHasWashingMachine = (option == 'Yes');
                      } else if (type == 'multi_select') {
                        if (_currentSelectedLaundryAdditional.contains(
                          option,
                        )) {
                          _currentSelectedLaundryAdditional.remove(option);
                        } else {
                          _currentSelectedLaundryAdditional.add(option);
                        }
                      }
                    } else if (serviceTitle == 'Elder-care') {
                      if (type == 'multi_select' && heading == 'Type of Care') {
                        if (_currentSelectedTypeOfCare.contains(option)) {
                          _currentSelectedTypeOfCare.remove(option);
                        } else {
                          _currentSelectedTypeOfCare.add(option);
                        }
                      } else if (type == 'single_select' &&
                          heading == 'Hours of Care') {
                        _currentSelectedHoursOfCare = option;
                      } else if (type == 'multi_select' &&
                          heading == 'Special needs') {
                        if (_currentSelectedSpecialNeeds.contains(option)) {
                          _currentSelectedSpecialNeeds.remove(option);
                        } else {
                          _currentSelectedSpecialNeeds.add(option);
                        }
                      }
                    } else if (serviceTitle == 'Babysitter') {
                      if (type == 'multi_select' && heading == 'Child\'s Age') {
                        if (_currentSelectedChildAges.contains(option)) {
                          _currentSelectedChildAges.remove(option);
                        } else {
                          _currentSelectedChildAges.add(option);
                        }
                      } else if (type == 'multi_select' &&
                          heading == 'Activities') {
                        if (_currentSelectedActivities.contains(option)) {
                          _currentSelectedActivities.remove(option);
                        } else {
                          _currentSelectedActivities.add(option);
                        }
                      }
                    } else if (serviceTitle == 'All-rounder') {
                      if (type == 'multi_select') {
                        if (_currentSelectedAllRounderTypes.contains(option)) {
                          _currentSelectedAllRounderTypes.remove(option);
                        } else {
                          _currentSelectedAllRounderTypes.add(option);
                        }
                      }
                    }
                  });
                });
              }).toList(),
              // Only show the text field option if hasInput is true
              if (hasInput && inputHint != null)
                _buildTextFieldOption(
                  inputHint,
                  serviceTitle,
                  heading,
                  modalSetState,
                ),
            ],
          ),
        const SizedBox(height: 20), // Spacing between sections
      ],
    );
  }

  // Helper for text input options
  Widget _buildTextFieldOption(
    String hint,
    String serviceTitle,
    String heading,
    StateSetter modalSetState,
  ) {
    TextEditingController controller =
        TextEditingController(); // Local controller for this field
    return SizedBox(
      width: 120, // Adjust width as needed for the "Enter Area" type fields
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.neutralMediumGray,
            fontWeight: FontWeight.normal,
          ),
          filled: true,
          fillColor: AppColors.neutralWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0), // Fully curved edges
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0), // Fully curved edges
            borderSide: BorderSide(
              color: AppColors.neutralMediumGray,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0), // Fully curved edges
            borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 15,
          ), // Smaller padding
        ),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.neutralBlack),
        onChanged: (value) {
          // You might want to store this value in the state if needed later
          // For now, just a basic example.
        },
      ),
    );
  }

  // Helper for number stepper input (Babysitter's No of Children)
  Widget _buildNumberStepperInput(StateSetter modalSetState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(50.0), // Fully curved edges
        border: Border.all(color: AppColors.neutralMediumGray, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              modalSetState(() {
                if (_currentNumChildren > 1) _currentNumChildren--;
              });
            },
            child: Icon(Icons.remove, size: 20, color: AppColors.primaryPurple),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$_currentNumChildren',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutralBlack,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              modalSetState(() {
                if (_currentNumChildren < 99)
                  _currentNumChildren++; // Max limit for children
              });
            },
            child: Icon(Icons.add, size: 20, color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}
