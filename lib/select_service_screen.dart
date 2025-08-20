import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/confirmation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  final List<Map<String, String>> _services = [
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

  String? _currentSelectedAreaOption;
  Set<String> _currentSelectedAdditionalServices = {};
  String? _currentSelectedMealType;
  Set<String> _currentSelectedMeals = {};
  Set<String> _currentSelectedCookingStyles = {};
  int _currentSelectedPeopleCount = 1;
  bool? _currentHasWashingMachine;
  Set<String> _currentSelectedLaundryAdditional = {};
  Set<String> _currentSelectedTypeOfCare = {};
  String? _currentSelectedHoursOfCare;
  Set<String> _currentSelectedSpecialNeeds = {};
  Set<String> _currentSelectedChildAges = {};
  int _currentNumChildren = 1;
  Set<String> _currentSelectedActivities = {};
  Set<String> _currentSelectedAllRounderTypes = {};

  double _currentBudget = 0;
  int _currentNumShifts = 0;
  String? _currentServiceType;

  Set<String> _selectedTimeSlots = {};
  final List<String> _timeSlotsOptions = [
    '9:00 AM - 12:00 PM',
    '1:00 PM - 4:00 PM',
    '5:00 PM - 8:00 PM',
  ];

  DateTime? _selectedCustomDate;
  String _selectedServiceTitle = '';
  int _currentAllRounderServiceIndex = 0;
  List<String> _allRounderSelectedSubServices = [];
  Map<String, Map<String, dynamic>> _allRounderSubServiceData = {};

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
        'heading': 'Select the no. of meals',
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
        'type': 'single_select_boolean',
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
        'type': 'number_stepper',
        'options': [],
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
            fontSize: AppTextStyles.heading4.fontSize,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
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
        _allRounderSubServiceData.clear();
        _showServiceDetailsSheet(context, title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(15.0),
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
      _currentSelectedAllRounderTypes.clear();
      _currentBudget = 0;
      _currentNumShifts = 0;
      _selectedTimeSlots.clear();
      _selectedCustomDate = null;
      _currentServiceType = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      backgroundColor: AppColors.neutralWhite,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            List<Map<String, dynamic>>? filters;
            String currentModalServiceTitle = serviceTitle;

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
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
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
                              _allRounderSelectedSubServices.isNotEmpty) {
                            _allRounderSubServiceData[currentModalServiceTitle] =
                                {
                                  'currentSelectedAreaOption':
                                      _currentSelectedAreaOption,
                                  'currentSelectedAdditionalServices':
                                      Set<String>.from(
                                        _currentSelectedAdditionalServices,
                                      ),
                                  'currentSelectedMealType':
                                      _currentSelectedMealType,
                                  'currentSelectedMeals': Set<String>.from(
                                    _currentSelectedMeals,
                                  ),
                                  'currentSelectedCookingStyles':
                                      Set<String>.from(
                                        _currentSelectedCookingStyles,
                                      ),
                                  'currentSelectedPeopleCount':
                                      _currentSelectedPeopleCount,
                                  'currentHasWashingMachine':
                                      _currentHasWashingMachine,
                                  'currentSelectedLaundryAdditional':
                                      Set<String>.from(
                                        _currentSelectedLaundryAdditional,
                                      ),
                                  'currentSelectedTypeOfCare': Set<String>.from(
                                    _currentSelectedTypeOfCare,
                                  ),
                                  'currentSelectedHoursOfCare':
                                      _currentSelectedHoursOfCare,
                                  'currentSelectedSpecialNeeds':
                                      Set<String>.from(
                                        _currentSelectedSpecialNeeds,
                                      ),
                                  'currentSelectedChildAges': Set<String>.from(
                                    _currentSelectedChildAges,
                                  ),
                                  'currentNumChildren': _currentNumChildren,
                                  'currentSelectedActivities': Set<String>.from(
                                    _currentSelectedActivities,
                                  ),
                                };
                          }

                          if (serviceTitle == 'All-rounder' &&
                              _allRounderSelectedSubServices.isEmpty) {
                            _allRounderSelectedSubServices =
                                _currentSelectedAllRounderTypes.toList();

                            if (_allRounderSelectedSubServices.isEmpty) {
                              Navigator.pop(context);
                              _showBudgetShiftModal(context);
                              return;
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  _currentAllRounderServiceIndex = 0;
                                });
                                Navigator.pop(context);
                                _showServiceDetailsSheet(context, serviceTitle);
                              });
                              return;
                            }
                          }

                          if (_allRounderSelectedSubServices.isNotEmpty &&
                              _currentAllRounderServiceIndex <
                                  _allRounderSelectedSubServices.length - 1) {
                            setState(() {
                              _currentAllRounderServiceIndex++;
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pop(context);
                              _showServiceDetailsSheet(context, serviceTitle);
                            });
                            return;
                          }
                          Navigator.pop(context);
                          _showBudgetShiftModal(context);
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
                } else if (_selectedServiceTitle == 'All-rounder') {
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
                            int.tryParse(option) ?? _currentSelectedPeopleCount;
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
                    } else if (_selectedServiceTitle == 'All-rounder') {
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

  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    Color borderColor = AppColors.neutralMediumGray;
    Color fillColor = AppColors.neutralWhite;
    Color textColor = AppColors.neutralBlack;

    if (text == 'Veg') {
      borderColor = AppColors.emotionGreen;
      fillColor = isSelected
          ? AppColors.emotionGreen.withOpacity(0.1)
          : Colors.transparent;
      textColor = AppColors.emotionGreen;
    } else if (text == 'Non-Veg') {
      borderColor = AppColors.emotionOrangeRed;
      fillColor = isSelected
          ? AppColors.emotionOrangeRed.withOpacity(0.1)
          : Colors.transparent;
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
          borderRadius: BorderRadius.circular(20),
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
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.neutralMediumGray,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(20),
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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(
    BuildContext context,
    StateSetter modalSetState,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedCustomDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPurple,
              onPrimary: AppColors.neutralWhite,
              onSurface: AppColors.neutralBlack,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedCustomDate) {
      modalSetState(() {
        _selectedCustomDate = picked;
      });
    }
  }

  Widget _buildServiceTypeOption(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.neutralMediumGray,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.neutralWhite,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryPurple
                      : AppColors.neutralMediumGray,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: AppColors.neutralWhite,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetShiftModal(BuildContext context) {
    bool serviceTypeError = false;
    bool timeSlotError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      backgroundColor: AppColors.neutralWhite,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) return;
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.neutralBlack,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service type',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutralDarkGray,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildServiceTypeOption(
                                'Daily',
                                _currentServiceType == 'Daily',
                                () => modalSetState(() {
                                  _currentServiceType = 'Daily';
                                  _currentNumShifts = 0;
                                  _selectedTimeSlots.clear();
                                  _selectedCustomDate = null;
                                  serviceTypeError = false;
                                }),
                              ),
                              const SizedBox(height: 10),
                              if (_currentServiceType == 'Daily')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available Time Slots',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutralDarkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: _timeSlotsOptions.map((slot) {
                                        final isSelected = _selectedTimeSlots
                                            .contains(slot);
                                        return GestureDetector(
                                          onTap: () {
                                            modalSetState(() {
                                              if (isSelected) {
                                                _selectedTimeSlots.remove(slot);
                                              } else {
                                                _selectedTimeSlots.add(slot);
                                              }
                                              _currentNumShifts =
                                                  _selectedTimeSlots.length;
                                              timeSlotError = false;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryPurple
                                                        .withOpacity(0.1)
                                                  : AppColors.neutralWhite,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryPurple
                                                    : AppColors
                                                          .neutralMediumGray,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              slot,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: isSelected
                                                    ? AppColors.primaryPurple
                                                    : AppColors.neutralBlack,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Number of Shifts: $_currentNumShifts',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutralBlack,
                                      ),
                                    ),
                                    if (timeSlotError)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          'Please select at least one time slot for Daily service.',
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              _buildServiceTypeOption(
                                'Custom',
                                _currentServiceType == 'Custom',
                                () => modalSetState(() {
                                  _currentServiceType = 'Custom';
                                  _currentNumShifts = 0;
                                  _selectedTimeSlots.clear();
                                  serviceTypeError = false;
                                }),
                              ),
                              if (_currentServiceType == 'Custom')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    Text(
                                      'Select Date',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.neutralDarkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    GestureDetector(
                                      onTap: () =>
                                          _selectDate(context, modalSetState),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutralWhite,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.neutralMediumGray,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDate(_selectedCustomDate),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color:
                                                    _selectedCustomDate == null
                                                    ? AppColors
                                                          .neutralMediumGray
                                                    : AppColors.neutralBlack,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              color:
                                                  AppColors.neutralMediumGray,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_selectedCustomDate != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          Text(
                                            'Available Time Slots',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.neutralDarkGray,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            children: _timeSlotsOptions.map((
                                              slot,
                                            ) {
                                              final isSelected =
                                                  _selectedTimeSlots.contains(
                                                    slot,
                                                  );
                                              return GestureDetector(
                                                onTap: () {
                                                  modalSetState(() {
                                                    if (isSelected) {
                                                      _selectedTimeSlots.remove(
                                                        slot,
                                                      );
                                                    } else {
                                                      _selectedTimeSlots.add(
                                                        slot,
                                                      );
                                                    }
                                                    _currentNumShifts =
                                                        _selectedTimeSlots
                                                            .length;
                                                    timeSlotError = false;
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors
                                                              .primaryPurple
                                                              .withOpacity(0.1)
                                                        : AppColors
                                                              .neutralWhite,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors
                                                                .primaryPurple
                                                          : AppColors
                                                                .neutralMediumGray,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    slot,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: isSelected
                                                          ? AppColors
                                                                .primaryPurple
                                                          : AppColors
                                                                .neutralBlack,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Number of Shifts: $_currentNumShifts',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.neutralBlack,
                                            ),
                                          ),
                                          if (timeSlotError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                'Please select a date and at least one time slot for Custom service.',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              if (serviceTypeError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Please select a service type (Daily or Custom).',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            bool isValid = true;
                            modalSetState(() {
                              serviceTypeError = _currentServiceType == null;
                              if (_currentServiceType == 'Daily') {
                                timeSlotError = _selectedTimeSlots.isEmpty;
                              } else if (_currentServiceType == 'Custom') {
                                timeSlotError =
                                    _selectedCustomDate == null ||
                                    _selectedTimeSlots.isEmpty;
                              } else {
                                timeSlotError = false;
                              }
                            });

                            if (serviceTypeError || timeSlotError) {
                              isValid = false;
                            }

                            if (!isValid) return;

                            _currentBudget = _calculateFixedBudget();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmationScreen(
                                  serviceTitle: _selectedServiceTitle,
                                  currentSelectedAreaOption:
                                      _currentSelectedAreaOption,
                                  currentSelectedAdditionalServices:
                                      _currentSelectedAdditionalServices,
                                  currentSelectedMealType:
                                      _currentSelectedMealType,
                                  currentSelectedMeals: _currentSelectedMeals,
                                  currentSelectedCookingStyles:
                                      _currentSelectedCookingStyles,
                                  currentSelectedPeopleCount:
                                      _currentSelectedPeopleCount,
                                  currentHasWashingMachine:
                                      _currentHasWashingMachine,
                                  currentSelectedLaundryAdditional:
                                      _currentSelectedLaundryAdditional,
                                  currentSelectedTypeOfCare:
                                      _currentSelectedTypeOfCare,
                                  currentSelectedHoursOfCare:
                                      _currentSelectedHoursOfCare,
                                  currentSelectedSpecialNeeds:
                                      _currentSelectedSpecialNeeds,
                                  currentSelectedChildAges:
                                      _currentSelectedChildAges,
                                  currentNumChildren: _currentNumChildren,
                                  currentSelectedActivities:
                                      _currentSelectedActivities,
                                  currentSelectedAllRounderTypes:
                                      _currentSelectedAllRounderTypes,
                                  currentBudget: _currentBudget,
                                  currentNumShifts: _currentNumShifts,
                                  currentSelectedShiftTimes: _selectedTimeSlots
                                      .toSet(),
                                  currentServiceType: _currentServiceType,
                                  currentSelectedDays:
                                      _currentServiceType == 'Custom' &&
                                          _selectedCustomDate != null
                                      ? {
                                          _formatDate(_selectedCustomDate),
                                        }.toSet()
                                      : <String>{}.toSet(),
                                  allRounderSubServiceData:
                                      _selectedServiceTitle == 'All-rounder'
                                      ? _allRounderSubServiceData
                                      : null,
                                ),
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
              ),
            );
          },
        );
      },
    );
  }

  double _calculateFixedBudget() {
    double baseBudget = 0;

    switch (_selectedServiceTitle) {
      case 'Cleaning':
        baseBudget = 1500;
        if (_currentSelectedAreaOption == '1RK')
          baseBudget += 200;
        else if (_currentSelectedAreaOption == '1BHK')
          baseBudget += 400;
        else if (_currentSelectedAreaOption == '2BHK')
          baseBudget += 600;
        else if (_currentSelectedAreaOption == '3BHK')
          baseBudget += 800;
        else if (_currentSelectedAreaOption == '4BHK')
          baseBudget += 1000;
        else if (_currentSelectedAreaOption == '5BHK and more')
          baseBudget += 1200;
        if (_currentSelectedAdditionalServices.contains('Bathroom'))
          baseBudget += 150;
        if (_currentSelectedAdditionalServices.contains('Balcony'))
          baseBudget += 100;
        if (_currentSelectedAdditionalServices.contains('House-shifting'))
          baseBudget += 500;
        if (_currentSelectedAdditionalServices.contains('Other'))
          baseBudget += 200;
        break;
      case 'Cooking':
        baseBudget = 3000;
        if (_currentSelectedMeals.contains('Breakfast')) baseBudget += 200;
        if (_currentSelectedMeals.contains('Lunch')) baseBudget += 300;
        if (_currentSelectedMeals.contains('Dinner')) baseBudget += 250;
        if (_currentSelectedMealType == 'Non-Veg') baseBudget += 300;
        baseBudget += (_currentSelectedPeopleCount - 1) * 100;
        break;
      case 'Laundry':
        baseBudget = 1000;
        baseBudget += (_currentSelectedPeopleCount - 1) * 150;
        if (_currentHasWashingMachine == false) baseBudget += 250;
        if (_currentSelectedLaundryAdditional.contains('Folding'))
          baseBudget += 50;
        if (_currentSelectedLaundryAdditional.contains('Ironing'))
          baseBudget += 100;
        break;
      case 'Elder-care':
        baseBudget = 5000;
        if (_currentSelectedTypeOfCare.contains('Medication Management'))
          baseBudget += 300;
        if (_currentSelectedTypeOfCare.contains('Companionship'))
          baseBudget += 200;
        if (_currentSelectedTypeOfCare.contains('Dementia Care'))
          baseBudget += 700;
        if (_currentSelectedHoursOfCare == 'Full-Time')
          baseBudget += 1000;
        else if (_currentSelectedHoursOfCare == 'Overnight')
          baseBudget += 1500;
        break;
      case 'Babysitter':
        baseBudget = 4000;
        baseBudget += (_currentNumChildren - 1) * 400;
        if (_currentSelectedChildAges.contains('Infants (0-1 years)'))
          baseBudget += 300;
        if (_currentSelectedActivities.contains('School pick & drop'))
          baseBudget += 200;
        break;
      case 'All-rounder':
        baseBudget = 6000;
        _allRounderSubServiceData.forEach((subServiceTitle, data) {
          switch (subServiceTitle) {
            case 'Cleaning':
              baseBudget += 500;
              break;
            case 'Cooking':
              baseBudget += 1000;
              break;
            case 'Laundry':
              baseBudget += 300;
              break;
            case 'Elder-care':
              baseBudget += 1500;
              break;
            case 'Babysitter':
              baseBudget += 1200;
              break;
          }
        });
        break;
    }

    if (_currentServiceType == 'Custom' && _selectedCustomDate != null) {
      baseBudget += 100;
    }

    return baseBudget;
  }
}
