import 'package:flutter/material.dart';
import 'package:superbai/salary_screen.dart';
import 'package:superbai/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeSlotScreen extends StatefulWidget {
  const TimeSlotScreen({super.key});

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  int _numberOfShifts = 1;
  final List<String?> _selectedShiftSlots = [null];
  Map<String, dynamic>? _routeArguments;
  bool _isInitialized = false;

  // NEW: List to track validation state for each dropdown
  List<bool> _showErrorBorder = [false];

  final List<String> _availableTimeSlots = [
    '07:00 - 08:00',
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _routeArguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (_routeArguments != null) {
        setState(() {
          _numberOfShifts = _routeArguments?['numberOfShifts'] ?? 1;
          final slots = _routeArguments?['selectedShiftTimes'] as List?;
          if (slots != null) {
            _selectedShiftSlots.clear();
            _selectedShiftSlots.addAll(List<String?>.from(slots));
          }
          _updateShiftTimesList();
        });
      } else {
        _updateShiftTimesList(); // Ensure error list is initialized even with no args
      }
      _isInitialized = true;
    }
  }

  void _updateShiftTimesList() {
    // Keep the list of selected slots in sync with the number of shifts
    while (_selectedShiftSlots.length < _numberOfShifts) {
      _selectedShiftSlots.add(null);
    }
    while (_selectedShiftSlots.length > _numberOfShifts) {
      _selectedShiftSlots.removeLast();
    }

    // NEW: Keep the error tracking list in sync as well
    setState(() {
      _showErrorBorder = List.generate(_numberOfShifts, (_) => false);
    });
  }

  bool _isSlotTakenByOtherShift(int shiftIndex, String slot) {
    for (int i = 0; i < _selectedShiftSlots.length; i++) {
      if (i != shiftIndex && _selectedShiftSlots[i] == slot) {
        return true;
      }
    }
    return false;
  }

  Widget _buildTimeSlotSelector(int index) {
    final hasError =
        _showErrorBorder.length > index ? _showErrorBorder[index] : false;
    final selectedSlot = _selectedShiftSlots.length > index
        ? _selectedShiftSlots[index]
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Shift ${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralBlack,
                ),
              ),
              if (selectedSlot != null) ...[
                const Spacer(),
                Text(
                  selectedSlot,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableTimeSlots.map((slot) {
              final isSelected = selectedSlot == slot;
              final isDisabled = _isSlotTakenByOtherShift(index, slot);

              return Opacity(
                opacity: isDisabled ? 0.4 : 1,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isDisabled
                        ? null
                        : () {
                            setState(() {
                              if (_selectedShiftSlots.length > index) {
                                _selectedShiftSlots[index] = slot;
                                if (_showErrorBorder[index]) {
                                  _showErrorBorder[index] = false;
                                }
                              }
                            });
                          },
                    child: Ink(
                      width: 148,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.neutralLightGray,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasError && !isSelected
                              ? AppColors.emotionOrangeRed
                              : isSelected
                              ? AppColors.primaryPurple
                              : AppColors.neutralMediumGray,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slot.split(' - ').first,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.neutralWhite
                                  : AppColors.neutralBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'to ${slot.split(' - ').last}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.neutralWhite.withOpacity(0.85)
                                  : AppColors.neutralDarkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select a time slot for shift ${index + 1}.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.emotionOrangeRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _validateAndProceed() {
    bool allSlotsSelected = true;
    final newErrorStates = List.generate(_numberOfShifts, (_) => false);

    for (int i = 0; i < _selectedShiftSlots.length; i++) {
      if (_selectedShiftSlots[i] == null) {
        allSlotsSelected = false;
        newErrorStates[i] = true; // Mark this dropdown as having an error
      }
    }

    // Update the UI to show red borders if there are errors
    setState(() {
      _showErrorBorder = newErrorStates;
    });

    if (allSlotsSelected) {
      final arguments = {
        ...(_routeArguments ?? {}),
        'selectedShiftTimes': _selectedShiftSlots,
        'numberOfShifts': _numberOfShifts,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalaryScreen(routeArguments: arguments),
        ),
      );
    }
    // REMOVED: The else block with the ScaffoldMessenger is no longer needed.
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose time slots',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.w500,
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
              ),
              child: Center(
                child: Text(
                  '2/3',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20.0),
                children: [
                  Text(
                    'Pick one slot per shift. Each slot is a 1-hour window.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.neutralDarkGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    _numberOfShifts,
                    (index) => _buildTimeSlotSelector(index),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select no. of shifts',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neutralWhite,
                          borderRadius: BorderRadius.circular(50.0),
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
                                if (_numberOfShifts > 1) {
                                  setState(() {
                                    _numberOfShifts--;
                                    _updateShiftTimesList();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.remove,
                                size: 20,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
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
                                  _updateShiftTimesList();
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
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 50.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // UPDATED: Calls the new validation function
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    'CONFIRM TIME SLOTS',
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
      ),
    );
  }
}
