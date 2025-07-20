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
  int _currentSelectedPeopleCount = 1; // For Laundry/Cooking initial
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
        'options': ['1RK', '1BHK', '2BHK', '3BHK', '4BHK', '5BHK and more'],
        'has_input': false,
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
        'heading': 'Select the no. of people',
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
          'Laundry',
          'Elder-care',
          'Babysitter',
        ],
        'has_input': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceTitle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectedServiceTitle = widget.initialServiceTitle!;
        _showServiceDetailsSheet(context, widget.initialServiceTitle!);
      });
    }
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select the Services',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '1/3',
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            childAspectRatio: 0.9,
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
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String imagePath,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        _selectedServiceTitle = title;
        _currentAllRounderServiceIndex = 0;
        _allRounderSelectedSubServices.clear();
        _showServiceDetailsSheet(context, title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(12.0),
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
              height: 100,
              width: 100,
              fit: BoxFit.contain,
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
                fontSize: AppTextStyles.bodyText.fontSize,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTimeSlotScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TimeSlotScreen(),
        settings: RouteSettings(
          arguments: {
            'maidData': widget.maidData,
            'serviceTitle': _selectedServiceTitle,
            'currentSelectedAreaOption': _currentSelectedAreaOption,
            'currentSelectedAdditionalServices':
                _currentSelectedAdditionalServices.toList(),
            'currentSelectedMealType': _currentSelectedMealType,
            'currentSelectedMeals': _currentSelectedMeals.toList(),
            'currentSelectedCookingStyles': _currentSelectedCookingStyles
                .toList(),
            'currentSelectedPeopleCount': _currentSelectedPeopleCount,
            'currentHasWashingMachine': _currentHasWashingMachine,
            'currentSelectedLaundryAdditional':
                _currentSelectedLaundryAdditional.toList(),
            'currentSelectedTypeOfCare': _currentSelectedTypeOfCare.toList(),
            'currentSelectedHoursOfCare': _currentSelectedHoursOfCare,
            'currentSelectedSpecialNeeds': _currentSelectedSpecialNeeds
                .toList(),
            'currentSelectedChildAges': _currentSelectedChildAges.toList(),
            'currentNumChildren': _currentNumChildren,
            'currentSelectedActivities': _currentSelectedActivities.toList(),
            'currentSelectedAllRounderTypes': _currentSelectedAllRounderTypes
                .toList(),
            'currentBudget': _currentBudget,
            'currentSelectedDays': _currentSelectedDays.toList(),
          },
        ),
      ),
    );
  }

  void _showServiceDetailsSheet(BuildContext context, String serviceTitle) {
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
      if (serviceTitle != 'All-rounder') {
        _currentSelectedAllRounderTypes.clear();
      }
      _currentSelectedDays.clear();
      _currentBudget = 4000;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      backgroundColor: AppColors.neutralWhite,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            List<Map<String, dynamic>>? filters;
            String currentModalServiceTitle = serviceTitle;

            if (serviceTitle == 'All-rounder' &&
                _allRounderSelectedSubServices.isNotEmpty &&
                _currentAllRounderServiceIndex <
                    _allRounderSelectedSubServices.length) {
              currentModalServiceTitle =
                  _allRounderSelectedSubServices[_currentAllRounderServiceIndex];
              filters = _serviceFilters[currentModalServiceTitle];
            } else {
              filters = _serviceFilters[serviceTitle];
            }

            // UPDATED: Wrap the content in a Padding that respects the bottom safe area
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                // Add padding to account for system UI like the navigation bar
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context).padding.bottom + 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      currentModalServiceTitle.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: AppTextStyles.heading4.fontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (filters != null)
                              ...filters.map((filterSection) {
                                final List<String> currentOptions =
                                    List<String>.from(
                                      filterSection['options'] as List,
                                    );

                                return _buildFilterSection(
                                  modalSetState,
                                  filterSection['heading'] as String,
                                  filterSection['type'] as String,
                                  currentOptions,
                                  filterSection['has_input'] as bool,
                                  filterSection['input_hint'] as String?,
                                  currentModalServiceTitle,
                                );
                              }).toList(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (serviceTitle == 'All-rounder' &&
                              _allRounderSelectedSubServices.isEmpty) {
                            _allRounderSelectedSubServices =
                                _currentSelectedAllRounderTypes.toList();
                            Navigator.pop(context);
                            if (_allRounderSelectedSubServices.isNotEmpty) {
                              _currentAllRounderServiceIndex = 0;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showServiceDetailsSheet(
                                  context,
                                  serviceTitle,
                                ); // Re-show for sub-service
                              });
                            } else {
                              _navigateToTimeSlotScreen(context);
                            }
                            return;
                          }

                          if (_allRounderSelectedSubServices.isNotEmpty &&
                              _currentAllRounderServiceIndex <
                                  _allRounderSelectedSubServices.length - 1) {
                            _currentAllRounderServiceIndex++;
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showServiceDetailsSheet(context, serviceTitle);
                            });
                            return;
                          }

                          Navigator.pop(context);
                          _navigateToTimeSlotScreen(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                        child: Text(
                          'NEXT',
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
            );
          },
        );
      },
    );
  }

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    Color borderColor = AppColors.neutralMediumGray;
    Color fillColor = AppColors.neutralWhite;
    Color textColor = AppColors.neutralBlack;

    if (text == 'Veg') {
      borderColor = AppColors.emotionGreen;
      fillColor = isSelected
          ? AppColors.emotionGreen.withOpacity(0.1)
          : AppColors.neutralWhite;
      textColor = AppColors.emotionGreen;
    } else if (text == 'Non-Veg') {
      borderColor = AppColors.emotionOrangeRed;
      fillColor = isSelected
          ? AppColors.emotionOrangeRed.withOpacity(0.1)
          : AppColors.neutralWhite;
      textColor = AppColors.emotionOrangeRed;
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    StateSetter modalSetState,
    String heading,
    String type,
    List<String> options,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralDarkGray,
          ),
        ),
        const SizedBox(height: 10),
        if (type == 'number_stepper')
          _buildNumberStepperInput(modalSetState)
        else
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              ...options.map((option) {
                bool isSelected = false;
                // Simplified state checking logic
                switch (serviceTitle) {
                  case 'Cleaning':
                    if (type == 'single_select') {
                      isSelected = _currentSelectedAreaOption == option;
                    } else {
                      isSelected = _currentSelectedAdditionalServices.contains(
                        option,
                      );
                    }
                    break;
                  case 'Cooking':
                    if (heading == 'Select the Meal(s)') {
                      isSelected = _currentSelectedMeals.contains(option);
                    } else if (heading == 'Select Type') {
                      isSelected = _currentSelectedMealType == option;
                    } else if (heading == 'Select the Style') {
                      isSelected = _currentSelectedCookingStyles.contains(
                        option,
                      );
                    } else if (heading == 'Select the no. of people') {
                      isSelected =
                          _currentSelectedPeopleCount.toString() == option;
                    }
                    break;
                  case 'Laundry':
                    if (heading == 'Select the no. of people') {
                      isSelected =
                          _currentSelectedPeopleCount.toString() == option;
                    } else if (heading == 'Washing machine') {
                      isSelected =
                          (_currentHasWashingMachine == (option == 'Yes'));
                    } else {
                      isSelected = _currentSelectedLaundryAdditional.contains(
                        option,
                      );
                    }
                    break;
                  case 'Elder-care':
                    if (heading == 'Type of Care') {
                      isSelected = _currentSelectedTypeOfCare.contains(option);
                    } else if (heading == 'Hours of Care') {
                      isSelected = _currentSelectedHoursOfCare == option;
                    } else {
                      isSelected = _currentSelectedSpecialNeeds.contains(
                        option,
                      );
                    }
                    break;
                  case 'Babysitter':
                    if (heading == 'Child\'s Age') {
                      isSelected = _currentSelectedChildAges.contains(option);
                    } else {
                      isSelected = _currentSelectedActivities.contains(option);
                    }
                    break;
                  case 'All-rounder':
                    isSelected = _currentSelectedAllRounderTypes.contains(
                      option,
                    );
                    break;
                }

                return _buildOptionButton(option, isSelected, () {
                  modalSetState(() {
                    // Simplified state update logic
                    switch (serviceTitle) {
                      case 'Cleaning':
                        if (type == 'single_select') {
                          _currentSelectedAreaOption = option;
                        } else {
                          _currentSelectedAdditionalServices.contains(option)
                              ? _currentSelectedAdditionalServices.remove(
                                  option,
                                )
                              : _currentSelectedAdditionalServices.add(option);
                        }
                        break;
                      case 'Cooking':
                        if (heading == 'Select the Meal(s)') {
                          _currentSelectedMeals.contains(option)
                              ? _currentSelectedMeals.remove(option)
                              : _currentSelectedMeals.add(option);
                        } else if (heading == 'Select Type') {
                          _currentSelectedMealType = option;
                        } else if (heading == 'Select the Style') {
                          _currentSelectedCookingStyles.contains(option)
                              ? _currentSelectedCookingStyles.remove(option)
                              : _currentSelectedCookingStyles.add(option);
                        } else if (heading == 'Select the no. of people') {
                          _currentSelectedPeopleCount =
                              int.tryParse(option) ?? 1;
                        }
                        break;
                      case 'Laundry':
                        if (heading == 'Select the no. of people') {
                          _currentSelectedPeopleCount =
                              int.tryParse(option) ?? 1;
                        } else if (heading == 'Washing machine') {
                          _currentHasWashingMachine = (option == 'Yes');
                        } else {
                          _currentSelectedLaundryAdditional.contains(option)
                              ? _currentSelectedLaundryAdditional.remove(option)
                              : _currentSelectedLaundryAdditional.add(option);
                        }
                        break;
                      case 'Elder-care':
                        if (heading == 'Type of Care') {
                          _currentSelectedTypeOfCare.contains(option)
                              ? _currentSelectedTypeOfCare.remove(option)
                              : _currentSelectedTypeOfCare.add(option);
                        } else if (heading == 'Hours of Care') {
                          _currentSelectedHoursOfCare = option;
                        } else {
                          _currentSelectedSpecialNeeds.contains(option)
                              ? _currentSelectedSpecialNeeds.remove(option)
                              : _currentSelectedSpecialNeeds.add(option);
                        }
                        break;
                      case 'Babysitter':
                        if (heading == 'Child\'s Age') {
                          _currentSelectedChildAges.contains(option)
                              ? _currentSelectedChildAges.remove(option)
                              : _currentSelectedChildAges.add(option);
                        } else {
                          _currentSelectedActivities.contains(option)
                              ? _currentSelectedActivities.remove(option)
                              : _currentSelectedActivities.add(option);
                        }
                        break;
                      case 'All-rounder':
                        _currentSelectedAllRounderTypes.contains(option)
                            ? _currentSelectedAllRounderTypes.remove(option)
                            : _currentSelectedAllRounderTypes.add(option);
                        break;
                    }
                  });
                });
              }).toList(),
              if (hasInput && inputHint != null)
                _buildTextFieldOption(
                  inputHint,
                  serviceTitle,
                  heading,
                  modalSetState,
                ),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextFieldOption(
    String hint,
    String serviceTitle,
    String heading,
    StateSetter modalSetState,
  ) {
    return SizedBox(
      width: 120,
      child: TextField(
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
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(
              color: AppColors.neutralMediumGray,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0),
            borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 15,
          ),
        ),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.neutralBlack),
      ),
    );
  }

  Widget _buildNumberStepperInput(StateSetter modalSetState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(50.0),
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
                if (_currentNumChildren < 99) _currentNumChildren++;
              });
            },
            child: Icon(Icons.add, size: 20, color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }
}
