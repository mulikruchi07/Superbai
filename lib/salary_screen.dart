import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and AppTextStyles are defined here
import 'package:superbai/time_slot_screen.dart'; // Import TimeSlotScreen for back navigation
import 'package:superbai/maid_linking_screen.dart'; // Import MaidLinkingScreen

class SalaryScreen extends StatefulWidget {
  final Map<String, dynamic>? routeArguments;

  const SalaryScreen({super.key, this.routeArguments});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  // A global key that uniquely identifies the Form widget and allows validation.
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  DateTime? _selectedDateOfPayment; // State variable for the selected date
  bool _dateHasError = false; // State to track date validation error
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final arguments = widget.routeArguments;
      if (arguments != null) {
        _amountController.text = arguments['salary'] ?? '';
        _remarkController.text = arguments['remark'] ?? '';
        final dateString = arguments['dateOfPayment'];
        if (dateString != null && dateString != 'Select Date') {
          try {
            final dateParts = dateString.split('/');
            if (dateParts.length == 3) {
              final day = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final year = int.parse(dateParts[2]);
              _selectedDateOfPayment = DateTime(year, month, day);
            }
          } catch (e) {
            // Could not parse date, leave it as null
            _selectedDateOfPayment = null;
          }
        }
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfPayment ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryPurple, // Header background color
              onPrimary: AppColors.neutralWhite, // Header text color
              onSurface: AppColors.neutralBlack, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfPayment) {
      setState(() {
        _selectedDateOfPayment = picked;
        _dateHasError = false; // Reset error when a date is picked
      });
    }
  }

  // Helper to format DateTime for display
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Function to handle form submission
  void _submitForm() {
    // First, validate the TextFormField
    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    // Then, validate the custom date picker
    setState(() {
      _dateHasError = _selectedDateOfPayment == null;
    });

    if (isFormValid && !_dateHasError) {
      // Create a mutable copy of maidData and add salary/remark
      Map<String, dynamic> updatedMaidData = {};

      // Pass along all previous arguments
      updatedMaidData.addAll(widget.routeArguments ?? {});

      // Add the new details from this screen
      updatedMaidData['salary'] = _amountController.text;
      updatedMaidData['remark'] = _remarkController.text;
      updatedMaidData['dateOfPayment'] = _formatDate(_selectedDateOfPayment);

      // Navigate to MaidLinkingScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaidLinkingScreen(maidData: updatedMaidData),
        ),
      );
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
            Navigator.of(context).pop();
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Mention the salary you pay:',
            style: GoogleFonts.poppins(
              fontSize: 18, // Base font size
              color: AppColors.neutralWhite,
              fontWeight: FontWeight.normal,
            ),
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
                  '3/3', // Page indicator
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 20.0),
                  children: [
                    Text(
                      'Enter amount*',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Like: 2000Rs. /month',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralMediumGray,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.neutralMediumGray,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.neutralMediumGray,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primaryPurple,
                            width: 1.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date of Payment Input
                    Text(
                      'Date of Payment*',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neutralWhite,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _dateHasError
                                    ? Colors.redAccent
                                    : AppColors.neutralMediumGray,
                                width: _dateHasError ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(_selectedDateOfPayment),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: _selectedDateOfPayment == null
                                        ? AppColors.neutralMediumGray
                                        : AppColors.neutralBlack,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: AppColors.neutralMediumGray,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_dateHasError)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                              top: 8.0,
                            ),
                            child: Text(
                              'Please select a date of payment',
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Remark',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _remarkController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Write about any change you want in maid\'s behavior, work style ,etc',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.neutralMediumGray,
                          fontWeight: FontWeight.normal,
                        ),
                        filled: true,
                        fillColor: AppColors.neutralWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.neutralMediumGray,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.neutralMediumGray,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primaryPurple,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.neutralBlack,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Confirm & Connect Button
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 50.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      'CONFIRM & CONNECT',
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
      ),
    );
  }
}
