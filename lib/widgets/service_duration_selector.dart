import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/widgets/preferred_time_picker.dart';

/// Builds an hour-wise slot string e.g. `9:00 AM - 1:00 PM`.
String formatHourwiseTimeSlot(TimeOfDay start, int durationHours) {
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = startMinutes + durationHours * 60;
  final end = TimeOfDay(
    hour: (endMinutes ~/ 60) % 24,
    minute: endMinutes % 60,
  );
  return '${SuperbaiTimePicker.format(start)} - ${SuperbaiTimePicker.format(end)}';
}

class ServiceDurationSelector extends StatelessWidget {
  const ServiceDurationSelector({
    super.key,
    required this.hours,
    required this.onChanged,
    this.minHours = 1,
    this.maxHours = 8,
  });

  final int hours;
  final ValueChanged<int> onChanged;
  final int minHours;
  final int maxHours;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutralDarkGray,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(maxHours - minHours + 1, (index) {
            final value = minHours + index;
            final isSelected = hours == value;
            return ChoiceChip(
              label: Text('$value hr${value == 1 ? '' : 's'}'),
              selected: isSelected,
              onSelected: (_) => onChanged(value),
              labelStyle: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.neutralWhite
                    : AppColors.neutralBlack,
              ),
              selectedColor: AppColors.primaryPurple,
              backgroundColor: AppColors.neutralLightGray,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryPurple
                    : AppColors.neutralMediumGray,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }
}
