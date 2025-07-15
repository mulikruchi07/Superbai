import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for GoogleFonts
import 'package:superbai/theme.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:superbai/confirmation_screen.dart'; // Import the ConfirmationScreen
import 'package:superbai/find_maid_screen.dart'; // Corrected import to FindMaidScreen
import 'package:superbai/booking_screen.dart'; // Import the BookingScreen
import 'package:superbai/bill_screen.dart'; // Import the new BillScreen
import 'package:superbai/account_screen.dart'; // Import the new AccountScreen

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentLocation = 'Fetching location...';
  int _selectedNavbarIndex = 0; // Default to 'Home' tab in navbar (index 0)

  // --- State variables for service selection modals (copied from SelectServiceScreen) ---
  String? _currentSelectedAreaOption;
  Set<String> _currentSelectedAdditionalServices = {};
  String? _currentSelectedMealType;
  Set<String> _currentSelectedMeals = {};
  Set<String> _currentSelectedCookingStyles = {};
  int _currentSelectedPeopleCount = 1; // For Laundry/Babysitter initial
  bool? _currentHasWashingMachine;
  Set<String> _currentSelectedLaundryAdditional = {};
  Set<String> _currentSelectedTypeOfCare = {};
  String? _currentSelectedHoursOfCare;
  Set<String> _currentSelectedSpecialNeeds = {};
  Set<String> _currentSelectedChildAges = {};
  int _currentNumChildren = 1; // Default for babysitter
  Set<String> _currentSelectedActivities = {};
  Set<String> _currentSelectedAllRounderTypes = {};

  // States for the second modal (Budget/Shifts)
  double _currentBudget = 0; // Will be calculated dynamically
  int _currentNumShifts = 0; // Will be updated based on time slot selection
  Set<String> _currentSelectedShiftTimes =
      {}; // Changed to Set for multi-selection
  String? _currentServiceType; // Daily or Custom

  // For Daily service type
  Set<String> _selectedDailyTimeSlots =
      {}; // Changed to Set for multiple selections
  final List<String> _dailyTimeSlotsOptions = [
    '9:00 AM - 12:00 PM',
    '1:00 PM - 4:00 PM',
    '5:00 PM - 8:00 PM',
  ];

  // For Custom service type
  DateTime? _selectedCustomDate;
  TimeOfDay? _selectedCustomFromTime;
  TimeOfDay? _selectedCustomToTime;

  // Store the selected service title to pass to the confirmation screen
  String _selectedServiceTitle = '';

  // Keep track of the index of the current all-rounder sub-service being configured
  int _currentAllRounderServiceIndex = 0;
  List<String> _allRounderSelectedSubServices = [];

  // New: Store all selected sub-service data for All-rounder
  Map<String, Map<String, dynamic>> _allRounderSubServiceData = {};

  // Define the filters for each service (copied from SelectServiceScreen)
  final Map<String, List<Map<String, dynamic>>> _serviceFilters = {
    'Cleaning': [
      {
        'heading': 'Select the area you need cleaning',
        'type': 'single_select',
        'options': [
          '1RK',
          '1BHK',
          '2BHK',
          '3BHK',
          '4BHK',
          '5BHK and more',
        ], // Updated options
        'has_input': false, // Removed input box
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
        'heading':
            'Select the no. of meals', // Clarified heading for image context
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
      // Corrected from 'Elder-Care'
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
      // Corrected from 'Baby-Sitter'
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
      // Corrected from 'All-Rounder'
      {
        'heading': 'Select type(s)',
        'type': 'multi_select',
        'options': [
          'Cleaning',
          'Cooking',
          'Laundry', // Changed from 'Washing Clothes' to 'Laundry' to match other service titles
          'Elder-care', // Changed from 'Elderly care' to 'Elder-care'
          'Babysitter', // Changed from 'Baby Sitting' to 'Babysitter'
        ],
        'has_input': false,
      },
    ],
  };
  // --- End of state variables for service selection modals ---

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services are disabled.';
      });
      // Call openLocationSettings outside setState's direct callback
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      // Call openAppSettings from permission_handler
      await openAppSettings();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use geocoding to get human-readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String city = place.locality ?? ''; // City
        String subLocality = place.subLocality ?? ''; // Town/Area within city

        String locationString = '';
        if (subLocality.isNotEmpty) {
          locationString += '$subLocality';
        }
        if (city.isNotEmpty) {
          if (locationString.isNotEmpty) {
            locationString += ', ';
          }
          locationString += '$city';
        }

        setState(() {
          // Fallback to displaying Lat/Lon if City/Town is not found
          _currentLocation = locationString.isNotEmpty
              ? locationString
              : 'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)} (Address not found)';
        });
      } else {
        // If no placemarks are found, still show Lat/Lon
        setState(() {
          _currentLocation =
              'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)} (Address not found)';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Error fetching location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of services with their names and image paths
    final List<Map<String, String>> services = [
      {
        'name': 'Cleaning',
        'image': 'assets/dashboard_images/cleaning_icon.png',
      },
      {'name': 'Cooking', 'image': 'assets/dashboard_images/cooking_icon.jpg'},
      {'name': 'Laundry', 'image': 'assets/dashboard_images/laundry_icon.png'},
      {
        'name': 'Elder-care', // Corrected name
        'image': 'assets/dashboard_images/elder_care_icon.png',
      },
      {
        'name': 'Babysitter', // Corrected name
        'image': 'assets/dashboard_images/baby_sitter_icon.png',
      },
      {
        'name': 'All-rounder', // Corrected name
        'image': 'assets/dashboard_images/all_rounder_icon.png',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite, // Changed to white
        elevation: 0, // Removed elevation
        toolbarHeight: 70, // Increased height for location and icons
        // Removed the leading IconButton (back arrow)
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppColors.primaryPurple,
              size: 20,
            ), // Changed icon color
            const SizedBox(width: 8),
            Expanded(
              // Use Expanded to prevent overflow if location string is long
              child: Text(
                _currentLocation,
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.bodyText.fontSize,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.w500, // Poppins Medium
                ),
                overflow: TextOverflow.ellipsis, // Handle long text
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: AppColors.neutralBlack,
            ), // Search icon
            onPressed: () {
              // Navigate to the Find Maid Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FindMaidScreen()),
              );
            },
          ),
          const SizedBox(width: 10), // Padding on the right
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner Image
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Less rounded corners
                child: Image.asset(
                  'assets/dashboard_images/banner.png', // Changed to .png
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height:
                      MediaQuery.of(context).size.height *
                      0.25, // Responsive height
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height:
                          MediaQuery.of(context).size.height *
                          0.25, // Responsive height for placeholder
                      color: AppColors.neutralMediumGray,
                      child: Center(
                        child: Text(
                          'Banner Image\nPlaceholder',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.neutralWhite,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Services',
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.heading4.fontSize,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.w500, // Poppins Medium
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable grid scrolling
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns as per UI
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio:
                      0.9, // Adjusted aspect ratio for card sizing
                ),
                itemCount: services.length, // Use services.length
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(
                    context,
                    service['name']!,
                    () {
                      // Original logic to show service details sheet
                      _selectedServiceTitle =
                          service['name']!; // Set the selected title
                      _currentAllRounderServiceIndex =
                          0; // Reset for new selection
                      _allRounderSelectedSubServices
                          .clear(); // Clear previous sub-services
                      _allRounderSubServiceData
                          .clear(); // Clear previous sub-service data
                      _showServiceDetailsSheet(context, service['name']!);
                    },
                    // Pass the image path to the build method
                    imagePath: service['image']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Maid's Tracker Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Maid\'s Tracker',
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.heading4.fontSize,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.w500, // Poppins Medium
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Text(
                'This week',
                style: AppTextStyles.subtext.copyWith(
                  color: AppColors.neutralDarkGray,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final List<String> daysOfWeek = [
                    'MON',
                    'TUE',
                    'WED',
                    'THR',
                    'FRI',
                    'SAT',
                    'SUN',
                  ];
                  final List<Color> statusColors = [
                    AppColors.emotionGreen, // MON
                    AppColors.emotionGreen, // TUE
                    AppColors.emotionGreen, // WED
                    AppColors.emotionOrangeRed, // THR
                    AppColors.neutralMediumGray, // FRI
                    AppColors.neutralMediumGray, // SAT
                    AppColors.neutralMediumGray, // SUN
                  ];
                  return Column(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColors[index],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        daysOfWeek[index],
                        style: GoogleFonts.poppins(
                          fontSize: AppTextStyles.bodyText.fontSize,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal, // Poppins Regular
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 30),

            // Referral Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Referral',
                style: GoogleFonts.poppins(
                  fontSize: AppTextStyles.heading4.fontSize,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.w500, // Poppins Medium
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Referral Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildReferralButton(
                      'Refer a Maid',
                      Icons.person_add, // Icon for referring a maid
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refer a Maid tapped!')),
                        );
                        // Implement navigation or action for Refer a Maid
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildReferralButton(
                      'Refer a Friend',
                      Icons.group_add, // Icon for referring a friend
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Refer a Friend tapped!'),
                          ),
                        );
                        // Implement navigation or action for Refer a Friend
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Combined Counts and Reviews Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Counts Section (Maids, Customers, Areas)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCountMetric('1500+', 'Maids'),
                        _buildCountMetric('5000+', 'Customers'),
                        _buildCountMetric('450+', 'Areas'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // User Reviews Section
                  // Removed "What our customers say" text
                  SizedBox(
                    height: 200, // Fixed height for the horizontal scroll
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      // Removed horizontal padding here as it's handled by the parent container
                      children: [
                        _buildReviewCard(
                          'Jane Doe',
                          'Username: is simply dummy text of the printing and typesetting industry. Lorem Ipsum has',
                          4, // 4 stars
                        ),
                        const SizedBox(width: 20),
                        _buildReviewCard(
                          'Sophie T',
                          'Username: is simply dummy text of the printing and typesetting industry. Lorem Ipsum has',
                          5, // 5 stars
                        ),
                        const SizedBox(width: 20),
                        // Add more review cards as needed
                        _buildReviewCard(
                          'John Smith',
                          'Great service! Highly recommend.',
                          4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Extra space at the bottom
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDarkGray,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ), // Poppins Medium
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
        ), // Poppins Regular
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        currentIndex:
            _selectedNavbarIndex, // Set current index for visual feedback
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedNavbarIndex == 0
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              color: _selectedNavbarIndex == 1
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt,
              color: _selectedNavbarIndex == 2
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _selectedNavbarIndex == 3
                  ? AppColors.primaryPurple
                  : AppColors.neutralDarkGray,
            ),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index; // Update selected index on tap
          });
          // Handle bottom navigation taps
          if (index == 0) {
            // Home
            // Already on Dashboard, do nothing or show snackbar
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Already on Home page')));
          } else if (index == 1) {
            // Booking
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingScreen()),
            );
          } else if (index == 2) {
            // Bill
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BillScreen()),
            );
          } else if (index == 3) {
            // Account
            Navigator.pushReplacement(
              // Navigate to AccountScreen
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
      ),
    );
  }

  // Updated _buildServiceCard to use Image.asset instead of IconData
  Widget _buildServiceCard(
    BuildContext context,
    String title,
    VoidCallback onTap, {
    required String imagePath,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: AppColors.primaryLightPurple.withOpacity(
            0.1,
          ), // Light transparent blue fill
          borderRadius: BorderRadius.circular(15), // Less rounded corners
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralMediumGray.withOpacity(
                0.1,
              ), // Softer shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 50, // Adjust image size as needed
              width: 50, // Adjust image size as needed
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  size: 50,
                  color: AppColors.neutralMediumGray,
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                // Use GoogleFonts directly for consistency
                fontSize: 12, // Smaller font size
                color: AppColors.neutralBlack, // Black text color
                fontWeight: FontWeight.normal, // Not bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Referral buttons
  Widget _buildReferralButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLightPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10), // Little curve
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralMediumGray.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align icon to the left
          children: [
            Icon(icon, size: 30, color: AppColors.neutralBlack), // Black icon
            const SizedBox(width: 8), // Space between icon and text
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.neutralBlack, // Black font color
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Count Metrics (Maids, Customers, Areas)
  Widget _buildCountMetric(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: AppColors.neutralBlack, // Black color
            fontWeight: FontWeight.normal, // Not bold
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.neutralBlack, // Black color
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Helper for User Review Cards
  Widget _buildReviewCard(String name, String reviewText, int stars) {
    return Container(
      width: 250, // Fixed width for each review card
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite, // White background
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumGray.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none, // Allows children to overflow
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Space for the overlapping image
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.w600, // SemiBold
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  reviewText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.neutralDarkGray,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 4, // Limit review text to 4 lines
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text overflows
                ),
              ),
            ],
          ),
          Positioned(
            top:
                -30, // Adjust this value to control how much of the circle is above the box
            left: 15, // Align with the left padding of the card
            child: Container(
              width: 60, // Size of the circular image
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLightPurple.withOpacity(
                  0.3,
                ), // Placeholder background
                border: Border.all(
                  color: AppColors.neutralWhite,
                  width: 3,
                ), // White border
              ),
              child: Center(
                child: Text(
                  name[0], // First letter of the name
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaidTypeCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumGray.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtext.copyWith(
              color: AppColors.neutralBlack,
            ),
          ),
        ],
      ),
    );
  }

  // --- Start of methods for service selection modals (copied from SelectServiceScreen) ---

  // Function to show the service details modal sheet
  void _showServiceDetailsSheet(BuildContext context, String serviceTitle) {
    // Reset selections when showing a new sheet, unless it's a sub-service modal in all-rounder flow
    if (!(_allRounderSelectedSubServices.isNotEmpty &&
        serviceTitle != 'All-rounder')) {
      setState(() {
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

        // Reset states for the second modal
        _currentBudget = 0; // Reset budget
        _currentNumShifts = 0; // Reset shifts
        _selectedDailyTimeSlots.clear(); // Reset daily time slots
        _selectedCustomDate = null; // Reset custom date
        _selectedCustomFromTime = null; // Reset custom from time
        _selectedCustomToTime = null; // Reset custom to time
        _currentServiceType = null;
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the modal to take full height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30.0),
        ), // Curved top corners
      ),
      backgroundColor: AppColors.neutralWhite, // Set background to white
      builder: (context) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage state inside modal
          builder: (BuildContext context, StateSetter modalSetState) {
            List<Map<String, dynamic>>? filters;
            String currentModalServiceTitle = serviceTitle;

            // Determine which filters to show based on serviceTitle and all-rounder flow
            if (serviceTitle == 'All-rounder' &&
                _allRounderSelectedSubServices.isNotEmpty) {
              currentModalServiceTitle =
                  _allRounderSelectedSubServices[_currentAllRounderServiceIndex];
              filters = _serviceFilters[currentModalServiceTitle];
            } else {
              filters = _serviceFilters[serviceTitle];
            }

            return PopScope(
              canPop: false, // Prevent default pop
              onPopInvoked: (didPop) {
                if (didPop) return; // If system already popped, do nothing
                if (serviceTitle == 'All-rounder' &&
                    _currentAllRounderServiceIndex > 0) {
                  // If it's an all-rounder sub-service modal and not the first one, go back to previous sub-service
                  modalSetState(() {
                    _currentAllRounderServiceIndex--;
                    // Restore previous sub-service data
                    final previousSubService =
                        _allRounderSelectedSubServices[_currentAllRounderServiceIndex];
                    final previousData =
                        _allRounderSubServiceData[previousSubService];
                    if (previousData != null) {
                      _currentSelectedAreaOption =
                          previousData['currentSelectedAreaOption'];
                      _currentSelectedAdditionalServices = Set<String>.from(
                        previousData['currentSelectedAdditionalServices'],
                      );
                      _currentSelectedMealType =
                          previousData['currentSelectedMealType'];
                      _currentSelectedMeals = Set<String>.from(
                        previousData['currentSelectedMeals'],
                      );
                      _currentSelectedCookingStyles = Set<String>.from(
                        previousData['currentSelectedCookingStyles'],
                      );
                      _currentSelectedPeopleCount =
                          previousData['currentSelectedPeopleCount'];
                      _currentHasWashingMachine =
                          previousData['currentHasWashingMachine'];
                      _currentSelectedLaundryAdditional = Set<String>.from(
                        previousData['currentSelectedLaundryAdditional'],
                      );
                      _currentSelectedTypeOfCare = Set<String>.from(
                        previousData['currentSelectedTypeOfCare'],
                      );
                      _currentSelectedHoursOfCare =
                          previousData['currentSelectedHoursOfCare'];
                      _currentSelectedSpecialNeeds = Set<String>.from(
                        previousData['currentSelectedSpecialNeeds'],
                      );
                      _currentSelectedChildAges = Set<String>.from(
                        previousData['currentSelectedChildAges'],
                      );
                      _currentNumChildren = previousData['currentNumChildren'];
                      _currentSelectedActivities = Set<String>.from(
                        previousData['currentSelectedActivities'],
                      );
                    }
                  });
                  // Re-show the previous sub-service modal by popping the current one.
                  // The previous _showServiceDetailsSheet call will rebuild with the updated index.
                  Navigator.pop(context);
                } else {
                  // Otherwise, pop this modal
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(
                    context,
                  ).viewInsets.bottom, // Adjust for keyboard
                ),
                child: Container(
                  height:
                      MediaQuery.of(context).size.height *
                      0.75, // Approx 75% of screen height
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle/Drag Indicator
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
                      // Back button for the current modal
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.neutralBlack,
                          ),
                          onPressed: () {
                            if (serviceTitle == 'All-rounder' &&
                                _currentAllRounderServiceIndex > 0) {
                              // If it's an all-rounder sub-service modal and not the first one, go back to previous sub-service
                              modalSetState(() {
                                _currentAllRounderServiceIndex--;
                                // Restore previous sub-service data
                                final previousSubService =
                                    _allRounderSelectedSubServices[_currentAllRounderServiceIndex];
                                final previousData =
                                    _allRounderSubServiceData[previousSubService];
                                if (previousData != null) {
                                  _currentSelectedAreaOption =
                                      previousData['currentSelectedAreaOption'];
                                  _currentSelectedAdditionalServices =
                                      Set<String>.from(
                                        previousData['currentSelectedAdditionalServices'],
                                      );
                                  _currentSelectedMealType =
                                      previousData['currentSelectedMealType'];
                                  _currentSelectedMeals = Set<String>.from(
                                    previousData['currentSelectedMeals'],
                                  );
                                  _currentSelectedCookingStyles = Set<String>.from(
                                    previousData['currentSelectedCookingStyles'],
                                  );
                                  _currentSelectedPeopleCount =
                                      previousData['currentSelectedPeopleCount'];
                                  _currentHasWashingMachine =
                                      previousData['currentHasWashingMachine'];
                                  _currentSelectedLaundryAdditional =
                                      Set<String>.from(
                                        previousData['currentSelectedLaundryAdditional'],
                                      );
                                  _currentSelectedTypeOfCare = Set<String>.from(
                                    previousData['currentSelectedTypeOfCare'],
                                  );
                                  _currentSelectedHoursOfCare =
                                      previousData['currentSelectedHoursOfCare'];
                                  _currentSelectedSpecialNeeds = Set<String>.from(
                                    previousData['currentSelectedSpecialNeeds'],
                                  );
                                  _currentSelectedChildAges = Set<String>.from(
                                    previousData['currentSelectedChildAges'],
                                  );
                                  _currentNumChildren =
                                      previousData['currentNumChildren'];
                                  _currentSelectedActivities = Set<String>.from(
                                    previousData['currentSelectedActivities'],
                                  );
                                }
                              });
                              // Re-show the previous sub-service modal by popping the current one.
                              // The previous _showServiceDetailsSheet call will rebuild with the updated index.
                              Navigator.pop(context);
                            } else {
                              // Otherwise, pop this modal
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      Text(
                        currentModalServiceTitle
                            .toUpperCase(), // Service Title in all caps
                        style: GoogleFonts.poppins(
                          // Poppins SemiBold or Bold
                          fontSize:
                              AppTextStyles.heading4.fontSize, // Adjusted size
                          fontWeight: FontWeight.w600, // SemiBold
                          color: AppColors.neutralBlack,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        // Use Expanded to make content scrollable if it overflows
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (filters != null)
                                ...filters.map((filterSection) {
                                  // Explicitly convert to List<String> to prevent TypeError
                                  final List<String> currentOptions =
                                      List<String>.from(
                                        filterSection['options']
                                            as List<dynamic>,
                                      );

                                  return _buildFilterSection(
                                    modalSetState,
                                    filterSection['heading'] as String,
                                    filterSection['type'] as String,
                                    currentOptions, // Use the converted list
                                    filterSection['has_input'] as bool,
                                    filterSection['input_hint'] as String?,
                                    currentModalServiceTitle, // Pass serviceTitle to manage specific states
                                  );
                                }).toList(),
                              const SizedBox(
                                height: 20,
                              ), // Spacing before the next button if content is short
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Capture data for the current sub-service if it's an all-rounder flow
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
                                    'currentSelectedTypeOfCare':
                                        Set<String>.from(
                                          _currentSelectedTypeOfCare,
                                        ),
                                    'currentSelectedHoursOfCare':
                                        _currentSelectedHoursOfCare,
                                    'currentSelectedSpecialNeeds':
                                        Set<String>.from(
                                          _currentSelectedSpecialNeeds,
                                        ),
                                    'currentSelectedChildAges':
                                        Set<String>.from(
                                          _currentSelectedChildAges,
                                        ),
                                    'currentNumChildren': _currentNumChildren,
                                    'currentSelectedActivities':
                                        Set<String>.from(
                                          _currentSelectedActivities,
                                        ),
                                  };
                            }

                            // Handle the initial 'All-rounder' selection
                            if (serviceTitle == 'All-rounder' &&
                                _allRounderSelectedSubServices.isEmpty) {
                              // Capture the selected sub-services from the 'All-rounder' filter
                              _allRounderSelectedSubServices =
                                  _currentSelectedAllRounderTypes.toList();

                              // If no sub-services were selected, proceed to the second modal
                              if (_allRounderSelectedSubServices.isEmpty) {
                                // Open the next modal on top without popping the current one
                                _showBudgetShiftModal(context);
                                return;
                              } else {
                                // Selected sub-services, open the first one
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  setState(() {
                                    // Use setState to ensure the main widget state updates
                                    _currentAllRounderServiceIndex =
                                        0; // Start from the first sub-service
                                  });
                                  // Open the next modal on top without popping the current one
                                  _showServiceDetailsSheet(
                                    context,
                                    _allRounderSelectedSubServices[_currentAllRounderServiceIndex],
                                  );
                                });
                                return; // Important to return after scheduling the next modal
                              }
                            }

                            // Handle subsequent sub-service modals in the 'All-rounder' flow
                            if (_allRounderSelectedSubServices.isNotEmpty &&
                                _currentAllRounderServiceIndex <
                                    _allRounderSelectedSubServices.length - 1) {
                              setState(() {
                                _currentAllRounderServiceIndex++;
                              });
                              // Open the next modal on top without popping the current one
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showServiceDetailsSheet(
                                  context,
                                  _allRounderSelectedSubServices[_currentAllRounderServiceIndex],
                                );
                              });
                              return; // Important to return after scheduling the next modal
                            }

                            // If it's the last sub-service or a single service, proceed to the second modal
                            // Open the next modal on top without popping the current one
                            _showBudgetShiftModal(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ), // Curved edges for the button
                            ),
                          ),
                          child: Text(
                            'NEXT',
                            style: GoogleFonts.poppins(
                              // Poppins Medium or SemiBold
                              fontSize: AppTextStyles.buttonText.fontSize,
                              color: AppColors.neutralWhite,
                              fontWeight: FontWeight.w500, // Medium weight
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

  // Helper to build a filter section with heading and options
  Widget _buildFilterSection(
    StateSetter modalSetState,
    String heading,
    String type,
    List<String> options, // Now guaranteed to be List<String>
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
            // Poppins Medium
            fontSize: 14, // Smaller font size
            fontWeight: FontWeight.w500, // Medium
            color: AppColors.neutralDarkGray,
          ),
        ),
        const SizedBox(height: 10),
        if (type ==
            'number_stepper') // Special handling for Babysitter children count
          _buildNumberStepperInput(modalSetState)
        else
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: [
              ...options.map((option) {
                bool isSelected = false;
                // Determine selection based on current context (main service or all-rounder sub-service)
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
                  // Corrected serviceTitle check
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
                  // Corrected serviceTitle check
                  if (type == 'multi_select' && heading == 'Child\'s Age') {
                    isSelected = _currentSelectedChildAges.contains(option);
                  } else if (type == 'multi_select' &&
                      heading == 'Activities') {
                    isSelected = _currentSelectedActivities.contains(option);
                  }
                } else if (serviceTitle == 'All-rounder') {
                  // Corrected serviceTitle check
                  if (type == 'multi_select') {
                    isSelected = _currentSelectedAllRounderTypes.contains(
                      option,
                    );
                  }
                }

                return _buildOptionButton(option, isSelected, () {
                  modalSetState(() {
                    // Update state based on current context (main service or all-rounder sub-service)
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
                            int.tryParse(option) ??
                            _currentSelectedPeopleCount; // Handle potential non-numeric option
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
                      // Corrected serviceTitle check
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
                      // Corrected serviceTitle check
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
                    } else if (serviceTitle == 'All-rounder') {
                      // Corrected serviceTitle check
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
        const SizedBox(height: 20), // Spacing between sections
      ],
    );
  }

  // Helper widget to build an option button (for areas and additional services)
  Widget _buildOptionButton(String text, bool isSelected, VoidCallback onTap) {
    Color borderColor = AppColors.neutralMediumGray;
    Color fillColor = AppColors.neutralWhite;
    Color textColor = AppColors.neutralBlack;

    if (text == 'Veg') {
      borderColor = AppColors.emotionGreen; // Thin green outline
      fillColor = isSelected
          ? AppColors.emotionGreen.withOpacity(0.1)
          : Colors
                .transparent; // Light transparent green fill, transparent when not selected
      textColor = AppColors.emotionGreen; // Green text
    } else if (text == 'Non-Veg') {
      borderColor = AppColors.emotionOrangeRed; // Thin red outline
      fillColor = isSelected
          ? AppColors.emotionOrangeRed.withOpacity(0.1)
          : Colors
                .transparent; // Light transparent red fill, transparent when not selected
      textColor = AppColors.emotionOrangeRed; // Red text
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
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ), // Smaller padding
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(
            20,
          ), // More curved edges for filter buttons
          border: Border.all(
            color: borderColor,
            width: 1.5, // Slightly thinner border for options
          ),
        ),
        child: Text(
          text, // Keep original case if it's not strictly all caps in UI
          style: GoogleFonts.poppins(
            // Poppins Regular for options
            fontSize: 13, // Smaller font size
            color: textColor, // Text color changes with selection
            fontWeight: FontWeight.normal, // Regular weight
          ),
        ),
      ),
    );
  }

  // Helper for text input options
  Widget _buildTextFieldOption(
    String hint,
    String serviceTitle,
    String heading,
    StateSetter modalSetState,
  ) {
    TextEditingController controller =
        TextEditingController(); // Local controller for this field
    return SizedBox(
      width: 120, // Adjust width as needed for the "Enter Area" type fields
      child: TextField(
        controller: controller,
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
          ), // Smaller padding
        ),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.neutralBlack),
        onChanged: (value) {
          // You might want to store this value in the state if needed later
          // For now, just a basic example.
        },
      ),
    );
  }

  // Helper for number stepper input (Babysitter's No of Children)
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
                if (_currentNumChildren < 99)
                  _currentNumChildren++; // Max limit for children
              });
            },
            child: Icon(Icons.add, size: 20, color: AppColors.primaryPurple),
          ),
        ],
      ),
    );
  }

  // Helper to format TimeOfDay for display
  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select Time';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper to format DateTime for display
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Function to show the date picker
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
    if (picked != null && picked != _selectedCustomDate) {
      modalSetState(() {
        _selectedCustomDate = picked;
      });
    }
  }

  // Helper to show the time picker
  Future<void> _selectTime(
    BuildContext context,
    StateSetter modalSetState,
    bool isFromTime,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      modalSetState(() {
        if (isFromTime) {
          _selectedCustomFromTime = picked;
        } else {
          _selectedCustomToTime = picked;
        }
      });
    }
  }

  // Helper for "Service Type" radio-style options
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
          borderRadius: BorderRadius.circular(12), // Rounded edges matching UI
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
                fontWeight: FontWeight.normal, // Poppins Regular
              ),
            ),
            // Custom radio button appearance
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

  // Second Modal for Budget and Shifts
  void _showBudgetShiftModal(BuildContext context) {
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
              // Use PopScope to control back button behavior
              canPop: false, // Prevent default pop
              onPopInvoked: (didPop) {
                if (didPop) return; // If system already popped, do nothing
                Navigator.pop(context); // Pop this modal
                // The first modal is still on the stack below, so it will be revealed
              },
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  height:
                      MediaQuery.of(context).size.height *
                      0.75, // Adjust height as needed
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle/Drag Indicator
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
                      // Back button for the second modal
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.neutralBlack,
                          ),
                          onPressed: () {
                            Navigator.pop(
                              context,
                            ); // This will pop the current modal
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          // Kept SingleChildScrollView to allow for responsiveness across various screen sizes
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
                              // Custom "Service type" filter boxes
                              _buildServiceTypeOption(
                                'Daily',
                                _currentServiceType == 'Daily',
                                () => modalSetState(() {
                                  _currentServiceType = 'Daily';
                                  _currentNumShifts =
                                      0; // Reset shifts for daily
                                  _selectedDailyTimeSlots
                                      .clear(); // Clear selected daily time slots
                                  _selectedCustomDate =
                                      null; // Clear custom date if switching
                                  _selectedCustomFromTime =
                                      null; // Clear custom times if switching
                                  _selectedCustomToTime = null;
                                }),
                              ),
                              const SizedBox(height: 10),
                              // Daily Time Slots boxes
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
                                      children: _dailyTimeSlotsOptions.map((
                                        slot,
                                      ) {
                                        final isSelected =
                                            _selectedDailyTimeSlots.contains(
                                              slot,
                                            );
                                        return GestureDetector(
                                          onTap: () {
                                            modalSetState(() {
                                              if (isSelected) {
                                                _selectedDailyTimeSlots.remove(
                                                  slot,
                                                );
                                              } else {
                                                _selectedDailyTimeSlots.add(
                                                  slot,
                                                );
                                              }
                                              _currentNumShifts =
                                                  _selectedDailyTimeSlots
                                                      .length;
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
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              const SizedBox(height: 10),
                              _buildServiceTypeOption(
                                'Custom',
                                _currentServiceType == 'Custom',
                                () => modalSetState(() {
                                  _currentServiceType = 'Custom';
                                  _currentNumShifts =
                                      0; // Reset shifts for custom
                                  _selectedDailyTimeSlots
                                      .clear(); // Clear daily time slots if switching
                                }),
                              ),
                              if (_currentServiceType == 'Custom')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ), // Adjusted spacing
                                    // Date Picker
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
                                    const SizedBox(height: 20),
                                    // From and To Time Input Boxes
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _selectTime(
                                              context,
                                              modalSetState,
                                              true,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 15,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.neutralWhite,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors
                                                      .neutralMediumGray,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'From',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .neutralDarkGray,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    _formatTime(
                                                      _selectedCustomFromTime,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      color: AppColors
                                                          .neutralBlack,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => _selectTime(
                                              context,
                                              modalSetState,
                                              false,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 15,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.neutralWhite,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors
                                                      .neutralMediumGray,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'To',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .neutralDarkGray,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    _formatTime(
                                                      _selectedCustomToTime,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      color: AppColors
                                                          .neutralBlack,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Validation logic
                            String? errorMessage;
                            if (_currentServiceType == null) {
                              errorMessage =
                                  'Please select a service type (Daily or Custom).';
                            } else if (_currentServiceType == 'Daily') {
                              if (_selectedDailyTimeSlots.isEmpty) {
                                errorMessage =
                                    'Please select at least one time slot for Daily service.';
                              }
                            } else if (_currentServiceType == 'Custom') {
                              if (_selectedCustomDate == null ||
                                  _selectedCustomFromTime == null ||
                                  _selectedCustomToTime == null) {
                                errorMessage =
                                    'Please select a date, and both From and To times for Custom service.';
                              }
                            }

                            if (errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return; // Prevent navigation
                            }

                            // Calculate fixed budget before navigating
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
                                  currentBudget:
                                      _currentBudget, // Pass calculated budget
                                  currentNumShifts:
                                      _currentNumShifts, // Pass updated shifts
                                  // For daily, pass selected time slot as a list with one element
                                  currentSelectedShiftTimes:
                                      _currentServiceType == 'Daily'
                                      ? _selectedDailyTimeSlots
                                            .toSet() // Pass the set directly
                                      : <String>{}.toSet(), // Ensure it's a Set
                                  currentServiceType: _currentServiceType,
                                  currentSelectedDays:
                                      _currentServiceType == 'Custom' &&
                                          _selectedCustomDate != null
                                      ? {_formatDate(_selectedCustomDate)}
                                            .toSet() // Pass selected custom date as a set
                                      : <String>{}.toSet(), // Ensure it's a Set
                                  // Pass custom from/to times
                                  customFromTime: _formatTime(
                                    _selectedCustomFromTime,
                                  ),
                                  customToTime: _formatTime(
                                    _selectedCustomToTime,
                                  ),
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

  // Helper method to calculate fixed budget based on selected services and sub-services
  double _calculateFixedBudget() {
    double baseBudget = 0;

    // Base prices for main services
    switch (_selectedServiceTitle) {
      case 'Cleaning':
        baseBudget = 1500; // Example base
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
        baseBudget = 3000; // Example base
        if (_currentSelectedMeals.contains('Breakfast')) baseBudget += 200;
        if (_currentSelectedMeals.contains('Lunch')) baseBudget += 300;
        if (_currentSelectedMeals.contains('Dinner')) baseBudget += 250;
        if (_currentSelectedMealType == 'Non-Veg')
          baseBudget += 300; // Extra for non-veg
        baseBudget +=
            (_currentSelectedPeopleCount - 1) * 100; // Per person cost
        break;
      case 'Laundry':
        baseBudget = 1000; // Example base
        baseBudget +=
            (_currentSelectedPeopleCount - 1) * 150; // Per person cost
        if (_currentHasWashingMachine == false)
          baseBudget += 250; // Extra for manual wash
        if (_currentSelectedLaundryAdditional.contains('Folding'))
          baseBudget += 50;
        if (_currentSelectedLaundryAdditional.contains('Ironing'))
          baseBudget += 100;
        break;
      case 'Elder-care':
        baseBudget = 5000; // Example base
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
        baseBudget = 4000; // Example base
        baseBudget += (_currentNumChildren - 1) * 400; // Per child cost
        if (_currentSelectedChildAges.contains('Infants (0-1 years)'))
          baseBudget += 300;
        if (_currentSelectedActivities.contains('School pick & drop'))
          baseBudget += 200;
        break;
      case 'All-rounder':
        baseBudget = 6000; // Base for all-rounder
        // Iterate through the stored sub-service data to calculate budget
        _allRounderSubServiceData.forEach((subServiceTitle, data) {
          switch (subServiceTitle) {
            case 'Cleaning':
              baseBudget += 500;
              // Add specific cleaning sub-service costs if needed from 'data'
              break;
            case 'Cooking':
              baseBudget += 1000;
              // Add specific cooking sub-service costs if needed from 'data'
              break;
            case 'Laundry':
              baseBudget += 300;
              // Add specific laundry sub-service costs if needed from 'data'
              break;
            case 'Elder-care':
              baseBudget += 1500;
              // Add specific elder-care sub-service costs if needed from 'data'
              break;
            case 'Babysitter':
              baseBudget += 1200;
              // Add specific babysitter sub-service costs if needed from 'data'
              break;
          }
        });
        break;
    }

    // Add a small increment for custom service type if a date is selected, as it implies more specific scheduling
    if (_currentServiceType == 'Custom' && _selectedCustomDate != null) {
      baseBudget += 100; // Small flat fee for custom scheduling
    }

    return baseBudget;
  }

  // New method to navigate to ConfirmationScreen (integrated directly into onPressed)
  // void _navigateToConfirmationScreen() {
  //   _currentBudget =
  //       _calculateFixedBudget(); // Ensure budget is calculated before navigation

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ConfirmationScreen(
  //         serviceTitle: _selectedServiceTitle,
  //         currentSelectedAreaOption: _currentSelectedAreaOption,
  //         currentSelectedAdditionalServices: _currentSelectedAdditionalServices,
  //         currentSelectedMealType: _currentSelectedMealType,
  //         currentSelectedMeals: _currentSelectedMeals,
  //         currentSelectedCookingStyles: _currentSelectedCookingStyles,
  //         currentSelectedPeopleCount: _currentSelectedPeopleCount,
  //         currentHasWashingMachine: _currentHasWashingMachine,
  //         currentSelectedLaundryAdditional: _currentSelectedLaundryAdditional,
  //         currentSelectedTypeOfCare: _currentSelectedTypeOfCare,
  //         currentSelectedHoursOfCare: _currentSelectedHoursOfCare,
  //         currentSelectedSpecialNeeds: _currentSelectedSpecialNeeds,
  //         currentSelectedChildAges: _currentSelectedChildAges,
  //         currentNumChildren: _currentNumChildren,
  //         currentSelectedActivities: _currentSelectedActivities,
  //         currentSelectedAllRounderTypes: _currentSelectedAllRounderTypes,
  //         currentBudget: _currentBudget, // Pass calculated budget
  //         currentNumShifts: _currentNumShifts, // Pass updated shifts
  //         // For daily, pass selected time slot as a list with one element
  //         currentSelectedShiftTimes: _currentServiceType == 'Daily'
  //             ? _selectedDailyTimeSlots
  //                   .toSet() // Pass the set directly
  //             : <String>{}.toSet(), // Ensure it's a Set
  //         currentServiceType: _currentServiceType,
  //         currentSelectedDays:
  //             _currentServiceType == 'Custom' && _selectedCustomDate != null
  //             ? {_formatDate(_selectedCustomDate)}
  //                   .toSet() // Pass selected custom date as a set
  //             : <String>{}.toSet(), // Ensure it's a Set
  //         // Pass custom from/to times
  //         customFromTime: _formatTime(_selectedCustomFromTime),
  //         customToTime: _formatTime(_selectedCustomToTime),
  //         allRounderSubServiceData:
  //             _selectedServiceTitle == 'All-rounder'
  //             ? _allRounderSubServiceData
  //             : null,
  //       ),
  //     ),
  //   );
  // }

  // --- End of methods for service selection modals ---
}
