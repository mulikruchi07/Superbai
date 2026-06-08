import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/repositories/user_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superbai/data/whatsapp_messages.dart';

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
  final Map<String, Map<String, dynamic>>?
  allRounderSubServiceData; // New parameter for All-rounder details
  final String? maidId;

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
    this.allRounderSubServiceData,
    this.maidId,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  static const String _supportWhatsAppNumber = '919819293826';

  late TextEditingController _addressController;
  bool _isCreatingBooking = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;

    final profile = await UserRepository().getProfileForAuthUser(authUser);
    if (!mounted || profile == null) return;

    final parts = <String>[];
    if (profile.building.trim().isNotEmpty) {
      parts.add(profile.building.trim());
    }
    if (profile.pincode.trim().isNotEmpty) {
      parts.add('Flat ${profile.pincode.trim()}');
    }
    if (parts.isEmpty) return;

    _addressController.text = parts.join(', ');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createBooking() async {
    if (_isCreatingBooking) return;

    setState(() => _isCreatingBooking = true);

    try {
      final message = _buildWhatsAppMessage();
      await _openSupportWhatsApp(message);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not open WhatsApp.');
    } finally {
      if (mounted) {
        setState(() => _isCreatingBooking = false);
      }
    }
  }

  String _buildWhatsAppMessage() {
    return WhatsAppMessages.instantBooking(
      service: _formatServiceForWhatsApp(),
      houseSize: _formatHouseSizeForWhatsApp(),
      additionalRequirements: _formatAdditionalRequirementsForWhatsApp(),
      preferredTimeSlot: _formatPreferredTimeSlotForWhatsApp(),
    );
  }

  String _formatServiceForWhatsApp() {
    if (widget.serviceTitle == 'All-rounder' &&
        widget.currentSelectedAllRounderTypes.isNotEmpty) {
      return 'All-rounder (${widget.currentSelectedAllRounderTypes.join(', ')})';
    }
    return widget.serviceTitle;
  }

  String? _formatHouseSizeForWhatsApp() {
    if (widget.currentSelectedAreaOption != null &&
        widget.currentSelectedAreaOption!.isNotEmpty) {
      return widget.currentSelectedAreaOption;
    }

    if (widget.serviceTitle == 'All-rounder' &&
        widget.allRounderSubServiceData != null) {
      for (final subServiceData in widget.allRounderSubServiceData!.values) {
        final area = subServiceData['currentSelectedAreaOption'] as String?;
        if (area != null && area.isNotEmpty) {
          return area;
        }
      }
    }

    if (widget.currentSelectedPeopleCount > 0) {
      return '${widget.currentSelectedPeopleCount} people';
    }

    return null;
  }

  String? _formatAdditionalRequirementsForWhatsApp() {
    final details = <String>[];

    void addDetail(String label, String? value) {
      if (value == null || value.isEmpty || value == 'N/A') return;
      details.add('$label: $value');
    }

    void addSetDetail(String label, Set<String> values) {
      if (values.isEmpty) return;
      details.add('$label: ${values.join(', ')}');
    }

    if (widget.serviceTitle == 'Cooking') {
      addSetDetail('Meals', widget.currentSelectedMeals);
      addDetail('Meal type', widget.currentSelectedMealType);
      addSetDetail('Cooking style', widget.currentSelectedCookingStyles);
      addDetail('People', widget.currentSelectedPeopleCount.toString());
    } else if (widget.serviceTitle == 'Cleaning') {
      addSetDetail('Additional services', widget.currentSelectedAdditionalServices);
    } else if (widget.serviceTitle == 'Laundry') {
      addDetail('People', widget.currentSelectedPeopleCount.toString());
      addDetail(
        'Washing machine',
        widget.currentHasWashingMachine == true
            ? 'Yes'
            : (widget.currentHasWashingMachine == false ? 'No' : null),
      );
      addSetDetail('Additional', widget.currentSelectedLaundryAdditional);
    } else if (widget.serviceTitle == 'Elder-care') {
      addSetDetail('Type of care', widget.currentSelectedTypeOfCare);
      addDetail('Hours of care', widget.currentSelectedHoursOfCare);
      addSetDetail('Special needs', widget.currentSelectedSpecialNeeds);
    } else if (widget.serviceTitle == 'Babysitter') {
      addDetail('Children', widget.currentNumChildren.toString());
      addSetDetail('Child age', widget.currentSelectedChildAges);
      addSetDetail('Activities', widget.currentSelectedActivities);
    }

    if (widget.serviceTitle == 'All-rounder' &&
        widget.allRounderSubServiceData != null) {
      for (final entry in widget.allRounderSubServiceData!.entries) {
        final subServiceTitle = entry.key;
        final subServiceData = entry.value;
        final subDetails = <String>[];

        if (subServiceTitle == 'Cleaning') {
          final area = subServiceData['currentSelectedAreaOption'] as String?;
          if (area != null && area.isNotEmpty) {
            subDetails.add('Area: $area');
          }
          final additional =
              subServiceData['currentSelectedAdditionalServices'] as Set<String>?;
          if (additional != null && additional.isNotEmpty) {
            subDetails.add('Additional: ${additional.join(', ')}');
          }
        } else if (subServiceTitle == 'Cooking') {
          final meals = subServiceData['currentSelectedMeals'] as Set<String>?;
          if (meals != null && meals.isNotEmpty) {
            subDetails.add('Meals: ${meals.join(', ')}');
          }
          final mealType = subServiceData['currentSelectedMealType'] as String?;
          if (mealType != null && mealType.isNotEmpty) {
            subDetails.add('Type: $mealType');
          }
          final styles =
              subServiceData['currentSelectedCookingStyles'] as Set<String>?;
          if (styles != null && styles.isNotEmpty) {
            subDetails.add('Style: ${styles.join(', ')}');
          }
          subDetails.add(
            'People: ${subServiceData['currentSelectedPeopleCount']}',
          );
        } else if (subServiceTitle == 'Laundry') {
          subDetails.add(
            'People: ${subServiceData['currentSelectedPeopleCount']}',
          );
          final hasMachine = subServiceData['currentHasWashingMachine'];
          if (hasMachine == true) {
            subDetails.add('Washing machine: Yes');
          } else if (hasMachine == false) {
            subDetails.add('Washing machine: No');
          }
          final additional =
              subServiceData['currentSelectedLaundryAdditional'] as Set<String>?;
          if (additional != null && additional.isNotEmpty) {
            subDetails.add('Additional: ${additional.join(', ')}');
          }
        } else if (subServiceTitle == 'Elder-care') {
          final careTypes =
              subServiceData['currentSelectedTypeOfCare'] as Set<String>?;
          if (careTypes != null && careTypes.isNotEmpty) {
            subDetails.add('Type of care: ${careTypes.join(', ')}');
          }
          final hours = subServiceData['currentSelectedHoursOfCare'] as String?;
          if (hours != null && hours.isNotEmpty) {
            subDetails.add('Hours of care: $hours');
          }
          final needs =
              subServiceData['currentSelectedSpecialNeeds'] as Set<String>?;
          if (needs != null && needs.isNotEmpty) {
            subDetails.add('Special needs: ${needs.join(', ')}');
          }
        } else if (subServiceTitle == 'Babysitter') {
          subDetails.add('Children: ${subServiceData['currentNumChildren']}');
          final ages = subServiceData['currentSelectedChildAges'] as Set<String>?;
          if (ages != null && ages.isNotEmpty) {
            subDetails.add('Child age: ${ages.join(', ')}');
          }
          final activities =
              subServiceData['currentSelectedActivities'] as Set<String>?;
          if (activities != null && activities.isNotEmpty) {
            subDetails.add('Activities: ${activities.join(', ')}');
          }
        }

        if (subDetails.isNotEmpty) {
          details.add('$subServiceTitle - ${subDetails.join('; ')}');
        }
      }
    }

    addDetail('Service type', widget.currentServiceType);
    addDetail('Budget', 'Rs. ${widget.currentBudget.toInt()}');
    addDetail('Shifts per day', widget.currentNumShifts.toString());

    final address = _addressController.text.trim();
    if (address.isNotEmpty) {
      details.add('Address: $address');
    }

    if (widget.maidId != null && widget.maidId!.isNotEmpty) {
      details.add('Maid ID: ${widget.maidId}');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
      details.add('Contact: ${user.phoneNumber}');
    }

    return details.isEmpty ? null : details.join('; ');
  }

  String? _formatPreferredTimeSlotForWhatsApp() {
    final parts = <String>[];

    if (widget.currentServiceType != null &&
        widget.currentServiceType!.isNotEmpty) {
      parts.add(widget.currentServiceType!);
    }

    if (widget.currentSelectedDays.isNotEmpty) {
      parts.add(widget.currentSelectedDays.join(', '));
    }

    if (widget.currentSelectedShiftTimes.isNotEmpty) {
      parts.add(widget.currentSelectedShiftTimes.join(', '));
    }

    return parts.isEmpty ? null : parts.join(' | ');
  }

  Future<void> _openSupportWhatsApp(String messageText) async {
    final message = Uri.encodeComponent(messageText);
    final appUri = Uri.parse(
      'whatsapp://send?phone=$_supportWhatsAppNumber&text=$message',
    );
    final webUri = Uri.parse(
      'https://wa.me/$_supportWhatsAppNumber?text=$message',
    );

    try {
      final openedApp = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) return;

      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        _showMessage('Could not open WhatsApp.');
      }
    } catch (_) {
      if (!mounted) return;
      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedWeb && mounted) {
        _showMessage('Could not open WhatsApp.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      // UPDATED: Body structure changed to prevent button overlap
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
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

                  const SizedBox(height: 15),
                  _buildConfirmationRow(
                    'Pricing',
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
                      widget.currentSelectedDays.join(', '),
                    ),
                    _buildConfirmationRow(
                      'Time Slots',
                      widget.currentSelectedShiftTimes.join(', '),
                    ),
                  ],
                  _buildConfirmationRow(
                    'Shifts per day',
                    '${widget.currentNumShifts}',
                  ),
                  if (widget.serviceTitle == 'All-rounder' &&
                      widget.allRounderSubServiceData != null)
                    ...widget.allRounderSubServiceData!.entries.map((entry) {
                      final subServiceTitle = entry.key;
                      final subServiceData = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            '${subServiceTitle} Filters:',
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
                              subServiceData['currentHasWashingMachine'] == true
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
                  const SizedBox(height: 15),
                  Text(
                    'Address',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutralBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutralLightGray.withOpacity(0.5),
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
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText:
                                  'Society, wing, and flat number for this booking',
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: AppColors.neutralDarkGray,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          color: AppColors.primaryPurple,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // This Padding ensures the button is always visible and padded correctly
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingBooking ? null : _createBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: _isCreatingBooking
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'BOOK VIA WHATSAPP',
                        style: GoogleFonts.poppins(
                          fontSize: AppTextStyles.buttonText.fontSize,
                          color: AppColors.neutralWhite,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for confirmation page rows
  Widget _buildConfirmationRow(String label, String value) {
    if (value.isEmpty || value == 'N/A' || value.trim() == '') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutralBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.neutralBlack,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: value.split(', ').map((item) {
                if (item.trim().isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryPurple,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
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
