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
      }
      _isInitialized = true;
    }
  }

  void _updateShiftTimesList() {
    if (_selectedShiftSlots.length < _numberOfShifts) {
      setState(() {
        while (_selectedShiftSlots.length < _numberOfShifts) {
          _selectedShiftSlots.add(null);
        }
      });
    } else if (_selectedShiftSlots.length > _numberOfShifts) {
      setState(() {
        while (_selectedShiftSlots.length > _numberOfShifts) {
          _selectedShiftSlots.removeLast();
        }
      });
    }
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        color: AppColors.neutralMediumGray,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: AppColors.neutralWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.neutralMediumGray, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
    );
  }

  Widget _buildTimeSlotDropdown(int index) {
    final List<String> availableForThisDropdown = _availableTimeSlots.where((
      slot,
    ) {
      bool isSelectedByOther = false;
      for (int i = 0; i < _selectedShiftSlots.length; i++) {
        if (i != index && _selectedShiftSlots[i] == slot) {
          isSelectedByOther = true;
          break;
        }
      }
      return !isSelectedByOther;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shift ${index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralDarkGray,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Select a Time Slot'),
            value: _selectedShiftSlots[index],
            hint: Text(
              'Select a Time Slot',
              style: GoogleFonts.poppins(color: AppColors.neutralMediumGray),
            ),
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedShiftSlots[index] = newValue;
              });
            },
            items: availableForThisDropdown.map<DropdownMenuItem<String>>((
              String value,
            ) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppColors.neutralBlack,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select your time-slot:',
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
                  ...List.generate(
                    _numberOfShifts,
                    (index) => _buildTimeSlotDropdown(index),
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
                          fontWeight: FontWeight.w500,
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
                                setState(() {
                                  if (_numberOfShifts > 1) {
                                    _numberOfShifts--;
                                    _updateShiftTimesList();
                                  }
                                });
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
              padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    bool allSlotsSelected = !_selectedShiftSlots.any(
                      (slot) => slot == null,
                    );

                    if (allSlotsSelected) {
                      final arguments = {
                        ...(_routeArguments ?? {}),
                        'selectedShiftTimes': _selectedShiftSlots,
                        'numberOfShifts': _numberOfShifts,
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SalaryScreen(routeArguments: arguments),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a time slot for all shifts.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
