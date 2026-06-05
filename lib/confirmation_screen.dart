import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final lines = <String>[
      'Hi SuperBai, I would like to book a service.',
      '',
      'Service: ${widget.serviceTitle}',
    ];

    void addLine(String label, String? value) {
      if (value == null || value.isEmpty || value == 'N/A') return;
      lines.add('$label: $value');
    }

    if (widget.serviceTitle == 'Cooking') {
      addLine('Meals', widget.currentSelectedMeals.join(', '));
      addLine('Type', widget.currentSelectedMealType);
      addLine('Style', widget.currentSelectedCookingStyles.join(', '));
      addLine('People', widget.currentSelectedPeopleCount.toString());
    } else if (widget.serviceTitle == 'Cleaning') {
      addLine('Area', widget.currentSelectedAreaOption);
      addLine('Additional', widget.currentSelectedAdditionalServices.join(', '));
    } else if (widget.serviceTitle == 'Laundry') {
      addLine('People', widget.currentSelectedPeopleCount.toString());
      addLine(
        'Washing Machine',
        widget.currentHasWashingMachine == true
            ? 'Yes'
            : (widget.currentHasWashingMachine == false ? 'No' : null),
      );
      addLine('Additional', widget.currentSelectedLaundryAdditional.join(', '));
    } else if (widget.serviceTitle == 'Elder-care') {
      addLine('Type of Care', widget.currentSelectedTypeOfCare.join(', '));
      addLine('Hours of Care', widget.currentSelectedHoursOfCare);
      addLine('Special Needs', widget.currentSelectedSpecialNeeds.join(', '));
    } else if (widget.serviceTitle == 'Babysitter') {
      addLine('No. of Children', widget.currentNumChildren.toString());
      addLine('Child\'s Age', widget.currentSelectedChildAges.join(', '));
      addLine('Activities', widget.currentSelectedActivities.join(', '));
    } else if (widget.serviceTitle == 'All-rounder') {
      addLine('Selected Types', widget.currentSelectedAllRounderTypes.join(', '));
    }

    addLine('Pricing', 'Rs. ${widget.currentBudget.toInt()}');
    addLine('Service Type', widget.currentServiceType);
    if (widget.currentServiceType == 'Daily') {
      addLine('Time Slots', widget.currentSelectedShiftTimes.join(', '));
    }
    if (widget.currentServiceType == 'Custom') {
      addLine('Date', widget.currentSelectedDays.join(', '));
      addLine('Time Slots', widget.currentSelectedShiftTimes.join(', '));
    }
    addLine('Shifts per day', widget.currentNumShifts.toString());

    if (widget.serviceTitle == 'All-rounder' &&
        widget.allRounderSubServiceData != null) {
      for (final entry in widget.allRounderSubServiceData!.entries) {
        final subServiceTitle = entry.key;
        final subServiceData = entry.value;
        lines.add('');
        lines.add('$subServiceTitle:');

        if (subServiceTitle == 'Cleaning') {
          addLine('  Area', subServiceData['currentSelectedAreaOption']);
          addLine(
            '  Additional',
            (subServiceData['currentSelectedAdditionalServices'] as Set<String>)
                .join(', '),
          );
        } else if (subServiceTitle == 'Cooking') {
          addLine(
            '  Meals',
            (subServiceData['currentSelectedMeals'] as Set<String>).join(', '),
          );
          addLine('  Type', subServiceData['currentSelectedMealType']);
          addLine(
            '  Style',
            (subServiceData['currentSelectedCookingStyles'] as Set<String>)
                .join(', '),
          );
          addLine(
            '  People',
            subServiceData['currentSelectedPeopleCount'].toString(),
          );
        } else if (subServiceTitle == 'Laundry') {
          addLine(
            '  People',
            subServiceData['currentSelectedPeopleCount'].toString(),
          );
          addLine(
            '  Washing Machine',
            subServiceData['currentHasWashingMachine'] == true
                ? 'Yes'
                : (subServiceData['currentHasWashingMachine'] == false
                      ? 'No'
                      : null),
          );
          addLine(
            '  Additional',
            (subServiceData['currentSelectedLaundryAdditional'] as Set<String>)
                .join(', '),
          );
        } else if (subServiceTitle == 'Elder-care') {
          addLine(
            '  Type of Care',
            (subServiceData['currentSelectedTypeOfCare'] as Set<String>)
                .join(', '),
          );
          addLine('  Hours of Care', subServiceData['currentSelectedHoursOfCare']);
          addLine(
            '  Special Needs',
            (subServiceData['currentSelectedSpecialNeeds'] as Set<String>)
                .join(', '),
          );
        } else if (subServiceTitle == 'Babysitter') {
          addLine(
            '  No. of Children',
            subServiceData['currentNumChildren'].toString(),
          );
          addLine(
            '  Child\'s Age',
            (subServiceData['currentSelectedChildAges'] as Set<String>)
                .join(', '),
          );
          addLine(
            '  Activities',
            (subServiceData['currentSelectedActivities'] as Set<String>)
                .join(', '),
          );
        }
      }
    }

    addLine('Address', _addressController.text.trim());

    if (widget.maidId != null && widget.maidId!.isNotEmpty) {
      addLine('Maid ID', widget.maidId);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
      addLine('Contact', user.phoneNumber);
    }

    return lines.join('\n');
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
