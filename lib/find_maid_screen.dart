// find_maid_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for GoogleFonts
import 'package:superbai/theme.dart';
import 'package:superbai/maid_details_screen.dart'; // Import the maid details screen

// The main "Find Maid" screen, which now starts with "Search Your Maid"
class FindMaidScreen extends StatefulWidget {
  const FindMaidScreen({super.key});

  @override
  State<FindMaidScreen> createState() => _FindMaidScreenState();
}

class _FindMaidScreenState extends State<FindMaidScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy data for maid list
  // IMPORTANT: Changed to dynamic to accommodate boolean 'isVerified'
  final List<Map<String, dynamic>> _maids = [
    {
      'name': 'Rani Obey',
      'role': 'Babysitter',
      'code': '9641',
      'gender': 'Female',
      'age': '22',
      'experience': '5+',
      'location': 'Bhandup',
      'isVerified': true, // Added isVerified
    },
    {
      'name': 'Marci Senter',
      'role': 'Elder care',
      'code': '8765',
      'gender': 'Female',
      'age': '30',
      'experience': '8+',
      'location': 'Andheri',
      'isVerified': false, // Added isVerified
    },
    {
      'name': 'Maryland Winkles',
      'role': 'All-rounder',
      'code': '1234',
      'gender': 'Female',
      'age': '25',
      'experience': '3+',
      'location': 'Dadar',
      'isVerified': true, // Added isVerified
    },
    {
      'name': 'Francene Vandyne',
      'role': 'Cleaner',
      'code': '1234',
      'gender': 'Female',
      'age': '25',
      'experience': '3+',
      'location': 'Dadar',
      'isVerified': false, // Added isVerified
    },
    {
      'name': 'Chieko Chute',
      'role': 'Cook',
      'code': '5678',
      'gender': 'Female',
      'age': '40',
      'experience': '10+',
      'location': 'Chembur',
      'isVerified': true, // Added isVerified
    },
    {
      'name': 'Lauralae Quintero',
      'role': 'Washing Clothes',
      'code': '9012',
      'gender': 'Female',
      'age': '35',
      'experience': '7+',
      'location': 'Borivali',
      'isVerified': false, // Added isVerified
    },
    {
      'name': 'Marielle Wigington',
      'role': 'Cleaner',
      'code': '3456',
      'gender': 'Female',
      'age': '28',
      'experience': '4+',
      'location': 'Ghatkopar',
      'isVerified': true, // Added isVerified
    },
    {
      'name': 'John Doe',
      'role': 'Gardener',
      'code': '7890',
      'gender': 'Male',
      'age': '45',
      'experience': '12+',
      'location': 'Worli',
      'isVerified': false, // Added isVerified
    },
    {
      'name': 'Jane Smith',
      'role': 'Housekeeper',
      'code': '2345',
      'gender': 'Female',
      'age': '32',
      'experience': '6+',
      'location': 'Powai',
      'isVerified': true, // Added isVerified
    },
    {
      'name': 'Emily White',
      'role': 'Child Caretaker',
      'code': '6789',
      'gender': 'Female',
      'age': '27',
      'experience': '2+',
      'location': 'Thane',
      'isVerified': false, // Added isVerified
    },
  ];

  // IMPORTANT: Changed to dynamic
  List<Map<String, dynamic>> _filteredMaids = [];

  @override
  void initState() {
    super.initState();
    _filteredMaids = _maids; // Initialize with all maids
    _searchController.addListener(_filterMaids);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMaids);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMaids() {
    setState(() {
      _filteredMaids = _maids.where((maid) {
        final query = _searchController.text.toLowerCase();
        return maid['name']!.toLowerCase().contains(query) ||
            maid['role']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Helper to get an icon based on the maid's role
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'babysitter':
        return Icons.child_care_outlined;
      case 'elder care':
        return Icons.elderly_outlined;
      case 'all-rounder':
        return Icons.widgets_outlined;
      case 'cleaner':
        return Icons.cleaning_services_outlined;
      case 'cook':
        return Icons.restaurant_menu_outlined;
      case 'washing clothes':
        return Icons.local_laundry_service_outlined;
      case 'gardener':
        return Icons.grass_outlined;
      case 'housekeeper':
        return Icons.house_outlined;
      case 'child caretaker':
        return Icons.face_outlined;
      default:
        return Icons.person_outline; // Default icon
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
            // Navigate back to the previous screen (e.g., DashboardScreen)
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Search Your Maid',
          style: GoogleFonts.poppins(
            // Using GoogleFonts directly
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal, // Not bold
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.neutralMediumGray,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.neutralDarkGray,
                ), // Changed to profile icon
                suffixIcon: Icon(
                  Icons.fullscreen,
                  color: AppColors.neutralDarkGray,
                ), // Added expand icon
                filled: true,
                fillColor: AppColors.neutralLightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Less curved edges
                  borderSide: BorderSide(
                    color: AppColors.neutralDarkGray,
                    width: 1.0,
                  ), // Thin dark grey outline
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Less curved edges
                  borderSide: BorderSide(
                    color: AppColors.neutralDarkGray,
                    width: 1.0,
                  ), // Thin dark grey outline
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // Less curved edges
                  borderSide: BorderSide(
                    color: AppColors.primaryPurple,
                    width: 2.0,
                  ),
                ),
              ),
              style: GoogleFonts.poppins(
                color: AppColors.neutralBlack,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMaids.length,
              itemBuilder: (context, index) {
                final maid = _filteredMaids[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 20.0,
                  ), // Keep horizontal padding
                  child: Row(
                    // Use Row to align elements and control tap area
                    children: [
                      // Profession Icon (white fill, purple transparent outline, black icon)
                      Container(
                        width: 45, // Slightly larger for better visual
                        height: 45, // Slightly larger
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.neutralWhite, // Filled white
                          border: Border.all(
                            color: AppColors.primaryPurple.withOpacity(
                              0.3,
                            ), // Purple transparent outline
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getRoleIcon(maid['role']!), // Role-specific icon
                            color: AppColors.neutralBlack, // Black icon color
                            size: 24, // Icon size within the circle
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ), // Spacing between icon and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              maid['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14, // Smaller font size
                                color: AppColors.neutralBlack,
                                fontWeight: FontWeight.normal, // Not bold
                              ),
                            ),
                            Text(
                              maid['role']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12, // Smaller font size
                                color: AppColors.neutralDarkGray,
                                fontWeight: FontWeight.normal, // Not bold
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Custom + button (smaller)
                      GestureDetector(
                        // Only + button is tappable
                        onTap: () {
                          // Navigate to the MaidDetailsScreen, passing the maid's data
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  MaidDetailsScreen(maidData: maid),
                            ),
                          );
                        },
                        child: Container(
                          width: 30, // Smaller size of the circular background
                          height: 30, // Smaller size of the circular background
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryLightPurple.withOpacity(
                              0.2,
                            ), // Light transparent blue
                          ),
                          child: Icon(
                            Icons.add,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ), // Purple + sign, smaller size
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// The new "Maid Unique Code" screen with tabs (Scan QR / Enter Code) - kept for structural completeness as it was part of previous requests
class MaidUniqueCodeScreen extends StatefulWidget {
  const MaidUniqueCodeScreen({super.key});

  @override
  State<MaidUniqueCodeScreen> createState() => _MaidUniqueCodeScreenState();
}

class _MaidUniqueCodeScreenState extends State<MaidUniqueCodeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 0 for Scan QR, 1 for Enter Code

  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final FocusNode _firstCodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    _firstCodeFocusNode.dispose();
    super.dispose();
  }

  // Helper function to navigate away from this screen (e.g., back to search)
  void _navigateAway() {
    Navigator.pop(context); // Pop back to MaidSearchAndCodeScreen
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
            // Navigate back to the MaidSearchAndCodeScreen
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Maid Unique Code',
          style: AppTextStyles.heading4.copyWith(color: AppColors.neutralWhite),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryPurple, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedIndex == 0
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Scan QR',
                          style: AppTextStyles.buttonText.copyWith(
                            color: _selectedIndex == 0
                                ? AppColors.neutralWhite
                                : AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedIndex == 1
                              ? AppColors.primaryPurple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Enter Code',
                          style: AppTextStyles.buttonText.copyWith(
                            color: _selectedIndex == 1
                                ? AppColors.neutralWhite
                                : AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [_buildScanQRTab(), _buildEnterCodeTab()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _navigateAway, // Modified to pop back or handle as needed
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'CONTINUE',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.bold,
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

  Widget _buildScanQRTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.neutralLightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryPurple, width: 3),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Camera Feed Placeholder',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.neutralDarkGray,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                        left: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                        right: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                        left: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                        right: BorderSide(
                          color: AppColors.primaryPurple,
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.neutralDarkGray,
              fontSize: 14,
            ), // Using GoogleFonts directly
          ),
        ],
      ),
    );
  }

  Widget _buildEnterCodeTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: 60,
                child: TextField(
                  controller: _codeControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: GoogleFonts.poppins(
                    color: AppColors.neutralBlack,
                    fontSize: 24,
                  ), // Using GoogleFonts directly
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: AppColors.neutralLightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.neutralMediumGray,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    if (value.length == 1 &&
                        index < _codeControllers.length - 1) {
                      FocusScope.of(context).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                  focusNode: index == 0 ? _firstCodeFocusNode : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text(
            'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.neutralDarkGray,
              fontSize: 14,
            ), // Using GoogleFonts directly
          ),
        ],
      ),
    );
  }
}
