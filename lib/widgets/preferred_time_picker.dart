import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';

/// Branded bottom-sheet time picker with quick presets and scroll wheels.
class SuperbaiTimePicker {
  SuperbaiTimePicker._();

  static const int minuteInterval = 15;

  static const List<TimeOfDay> presets = [
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
  ];

  static Future<TimeOfDay?> show(
    BuildContext context, {
    TimeOfDay? initialTime,
    String title = 'Select preferred time',
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimePickerSheet(
        initialTime: snapToMinuteInterval(initialTime ?? TimeOfDay.now()),
        title: title,
      ),
    );
  }

  static String format(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static TimeOfDay snapToMinuteInterval(TimeOfDay time) {
    final totalMinutes = time.hour * 60 + time.minute;
    final snappedMinutes =
        ((totalMinutes / minuteInterval).round() * minuteInterval) %
        (24 * 60);
    return TimeOfDay(
      hour: snappedMinutes ~/ 60,
      minute: snappedMinutes % 60,
    );
  }

  static DateTime _toDateTime(TimeOfDay time) {
    final snapped = snapToMinuteInterval(time);
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      snapped.hour,
      snapped.minute,
    );
  }

  static TimeOfDay _fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}

class PreferredTimeField extends StatelessWidget {
  const PreferredTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.hasError = false,
    this.placeholder = 'Choose a time',
    this.sheetTitle = 'Select preferred time',
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onChanged;
  final bool hasError;
  final String placeholder;
  final String sheetTitle;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final borderColor = hasError
        ? AppColors.emotionOrangeRed
        : hasValue
        ? AppColors.primaryPurple.withOpacity(0.45)
        : AppColors.neutralMediumGray;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await SuperbaiTimePicker.show(
            context,
            initialTime: value,
            title: sheetTitle,
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: hasValue
                ? AppColors.primaryPurple.withOpacity(0.06)
                : AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: hasValue ? 1.5 : 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasValue
                      ? AppColors.primaryPurple
                      : AppColors.neutralLightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 22,
                  color: hasValue
                      ? AppColors.neutralWhite
                      : AppColors.neutralDarkGray,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasValue ? 'Preferred time' : placeholder,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasValue
                            ? AppColors.primaryPurple
                            : AppColors.neutralDarkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue
                          ? SuperbaiTimePicker.format(value!)
                          : 'Tap to set your start time',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hasValue
                            ? AppColors.neutralBlack
                            : AppColors.neutralMediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: hasValue
                    ? AppColors.primaryPurple
                    : AppColors.neutralDarkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({
    required this.initialTime,
    required this.title,
  });

  final TimeOfDay initialTime;
  final String title;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = SuperbaiTimePicker._toDateTime(widget.initialTime);
  }

  void _applyPreset(TimeOfDay preset) {
    setState(() {
      _selectedDateTime = SuperbaiTimePicker._toDateTime(preset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.neutralMediumGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.neutralDarkGray,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick picks',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SuperbaiTimePicker.presets.map((preset) {
                  final isSelected = _selectedDateTime.hour == preset.hour &&
                      _selectedDateTime.minute == preset.minute;
                  return ChoiceChip(
                    label: Text(SuperbaiTimePicker.format(preset)),
                    selected: isSelected,
                    onSelected: (_) => _applyPreset(preset),
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
                }).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                height: 1,
                color: AppColors.neutralLightGray,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 210,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralBlack,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: _selectedDateTime,
                    minuteInterval: SuperbaiTimePicker.minuteInterval,
                    use24hFormat: false,
                    onDateTimeChanged: (value) {
                      setState(() => _selectedDateTime = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      SuperbaiTimePicker._fromDateTime(_selectedDateTime),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: AppColors.neutralWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm ${SuperbaiTimePicker.format(SuperbaiTimePicker._fromDateTime(_selectedDateTime))}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
