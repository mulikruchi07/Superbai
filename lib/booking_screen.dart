import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Ensure this path is correct
import 'package:superbai/dashboard_screen.dart'; // Import DashboardScreen
import 'package:superbai/complaint_screen.dart'; // Import the new ComplaintScreen
import 'package:superbai/bill_screen.dart'; // Import the new BillScreen
import 'package:superbai/account_screen.dart'; // Import the new AccountScreen

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedNavbarIndex = 1; // Default to 'Booking' tab in navbar (index 1)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to update UI if necessary, e.g., for 'Get a Backup Maid'
    _tabController.addListener(() {
      setState(() {
        // This setState is crucial for the custom tab bar's colors to update
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            // Navigate back to DashboardScreen and remove all previous routes
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // This condition removes all previous routes
            );
          },
        ),
        title: Text(
          'My Booking',
          style: GoogleFonts.poppins(
            fontSize: 18, // Smaller font size
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal, // Poppins Regular (not bold)
          ),
        ),
        centerTitle: false, // Align title to the left
      ),
      body: Column(
        children: [
          // Custom Tab Bar (Daily/Instant)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0), // No vertical padding
            child: Column( // Use a Column to stack the tabs and the horizontal line
              children: [
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.neutralWhite, // White background
                    borderRadius: BorderRadius.circular(12),
                    // Removed border around the container as per request
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabController.index = 0;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Always transparent background
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Daily',
                              style: GoogleFonts.poppins(
                                fontSize: AppTextStyles.bodyText.fontSize,
                                fontWeight: FontWeight.w500, // Poppins Medium
                                color: _tabController.index == 0 ? AppColors.primaryPurple : AppColors.neutralDarkGray, // Purple text when selected, else grey
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Small vertical line between words
                      Container(
                        width: 1, // Thickness of the line
                        height: 25, // Height of the line
                        color: AppColors.neutralMediumGray, // Color of the line
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _tabController.index = 1;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Always transparent background
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Instant',
                              style: GoogleFonts.poppins(
                                fontSize: AppTextStyles.bodyText.fontSize,
                                fontWeight: FontWeight.w500, // Poppins Medium
                                color: _tabController.index == 1 ? AppColors.primaryPurple : AppColors.neutralDarkGray, // Purple text when selected, else grey
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Full thin gray line horizontally below daily and instant button
                Container(
                  height: 1, // Thickness of the line
                  color: AppColors.neutralMediumGray, // Color of the line
                  margin: const EdgeInsets.only(top: 0), // No gap from above
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDailyBookingTab(),
                _buildInstantBookingTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDarkGray,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500), // Poppins Medium
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal), // Poppins Regular
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        currentIndex: _selectedNavbarIndex, // Set current index for visual feedback
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: _selectedNavbarIndex == 0 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: _selectedNavbarIndex == 1 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt, color: _selectedNavbarIndex == 2 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Bill',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedNavbarIndex == 3 ? AppColors.primaryPurple : AppColors.neutralDarkGray),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedNavbarIndex = index; // Update selected index on tap
          });
          // Handle bottom navigation taps
          if (index == 0) { // Home
            Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil for home
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false, // Clear all previous routes
            );
          } else if (index == 1) { // Booking
            // Already on BookingScreen, do nothing or show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Already on Booking page')),
            );
          } else if (index == 2) { // Bill
            Navigator.pushReplacement( // Use pushReplacement to avoid stacking
              context,
              MaterialPageRoute(builder: (context) => const BillScreen()),
            );
          } else if (index == 3) { // Account
            Navigator.pushReplacement( // Navigate to AccountScreen
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDailyBookingTab() {
    // Dummy Data for Previous Bookings
    final List<Map<String, String>> previousBookings = [
      {'name': 'Sophie T', 'role': 'House Maid', 'rating': '4.5', 'date': '21 Aug 23', 'duration': '2 months'},
      {'name': 'Jane Doe', 'role': 'Cook', 'rating': '4.0', 'date': '05 May 23', 'duration': '8 months'},
      {'name': 'Marci Senter', 'role': 'Elder care', 'rating': '4.8', 'date': '10 Mar 23', 'duration': '10 months'},
      {'name': 'Chieko Chute', 'role': 'Cleaner', 'rating': '4.2', 'date': '15 Jan 23', 'duration': '12 months'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Booking',
            style: GoogleFonts.poppins(
              fontSize: (AppTextStyles.heading4.fontSize ?? 20.0) - 2, // Reduced font size, safely unwrapped
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal, // Not bold
            ),
          ),
          const SizedBox(height: 15),
          // Active Booking Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15), // Slightly less curved
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralMediumGray.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture and ID with Stars
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 30, // Slightly smaller radius
                          backgroundColor: AppColors.neutralWhite,
                          backgroundImage: NetworkImage('https://placehold.co/100x100/FFFFFF/5D4EFF?text=JD'), // Placeholder image
                        ),
                        const SizedBox(height: 5), // Smaller gap
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star_rate_rounded,
                              color: starIndex < 4 ? AppColors.emotionYellow : AppColors.neutralWhite.withOpacity(0.5), // 4 stars filled
                              size: 16, // Slightly smaller stars
                            );
                          }),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: 3231',
                          style: GoogleFonts.poppins(
                            fontSize: (AppTextStyles.bodyText.fontSize ?? 14.0) + 2, // Safely unwrap fontSize, still a bit bigger
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal, // Poppins Regular
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15), // Reduced width
                    // Maid Details - Labels and Values side-by-side with aligned semicolons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRowAligned('Name', 'Jane Doe'),
                          _buildDetailRowAligned('Service', 'Cleaning'),
                          _buildDetailRowAligned('Contact', '9873724556'),
                          _buildDetailRowAligned('Salary', '2000/mon'),
                          _buildDetailRowAligned('Timing', '9am - 11am'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15), // Reduced height
                // Buttons - now using Wrap for responsiveness and individual sizing
                Wrap( // Changed to Wrap
                  spacing: 5.0, // Horizontal spacing between buttons
                  runSpacing: 5.0, // Vertical spacing between rows of buttons
                  alignment: WrapAlignment.center, // Center the buttons
                  children: [
                    _buildOutlineButton(context, 'Cancel', Icons.close),
                    _buildOutlineButton(context, 'Reschedule', Icons.calendar_today_outlined),
                    _buildOutlineButton(context, 'Replace', Icons.loop),
                  ],
                ),
              ],
            ),
          ),
          // No SizedBox above or below "File a Complaint"
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // Navigate to the ComplaintScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                );
              },
              icon: Icon(Icons.edit_note_outlined, color: AppColors.neutralBlack, size: 18), // Different icon, smaller size
              label: Text(
                'File a Complaint',
                style: GoogleFonts.poppins(
                  fontSize: 13, // Smaller font size
                  color: AppColors.neutralBlack, // Black color
                  fontWeight: FontWeight.normal, // Poppins Regular
                ),
              ),
            ),
          ),
          const SizedBox(height: 0), // No gap below File a Complaint
          // Get a Backup Maid Button
          SizedBox(
            width: double.infinity,
            height: 50, // Make it thinner
            child: ElevatedButton.icon(
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      backgroundColor: AppColors.neutralWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      title: Text(
                        'Confirm Action',
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      content: Text(
                        'Are you sure your maid is on holiday?',
                        style: GoogleFonts.poppins(
                          color: AppColors.neutralDarkGray,
                          fontSize: 14,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close the dialog
                          },
                          child: Text(
                            'No',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close the dialog
                            // Navigate to the Instant tab
                            _tabController.animateTo(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Navigating to Instant Booking for backup maid.')),
                            );
                          },
                          child: Text(
                            'Yes',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.group, color: AppColors.neutralWhite, size: 24), // Slightly smaller icon
              label: Row( // Use a Row for text and arrows
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get a Backup Maid',
                    style: GoogleFonts.poppins(
                      fontSize: 14, // Smaller font size
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.w500, // Poppins Medium
                      letterSpacing: 1.0, // Slightly less letter spacing
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced spacing
                  Icon(Icons.arrow_forward_ios, color: AppColors.neutralWhite, size: 14), // Smaller arrows
                  Icon(Icons.arrow_forward_ios, color: AppColors.neutralWhite, size: 14), // Smaller arrows
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 0), // Adjust padding for height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Fully curved
                ),
              ),
            ),
          ),
          const SizedBox(height: 25), // Reduced height
          Text(
            'Previous Bookings',
            style: GoogleFonts.poppins(
              fontSize: (AppTextStyles.heading4.fontSize ?? 20.0) - 2, // Reduced font size, safely unwrapped
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal, // Not bold
            ),
          ),
          const SizedBox(height: 15),
          // Previous Bookings List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: previousBookings.length,
            itemBuilder: (context, index) {
              final booking = previousBookings[index];
              return Padding( // Added padding for each list item
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 22, // Smaller radius
                    backgroundColor: AppColors.secondaryPastelPurple,
                    backgroundImage: NetworkImage('https://placehold.co/80x80/${AppColors.secondaryPastelPurple.toHex().substring(1)}/${AppColors.primaryPurple.toHex().substring(1)}?text=${booking['name']![0]}'),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13, // Smaller font size
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal, // Not bold
                        ),
                      ),
                      const SizedBox(height: 2), // Small gap
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          double rating = double.parse(booking['rating']!);
                          return Icon(
                            Icons.star_rate_rounded,
                            color: starIndex < rating.floor() ? AppColors.emotionYellow : AppColors.neutralMediumGray, // Fill stars based on rating
                            size: 12, // Smaller stars
                          );
                        }),
                      ),
                      Text(
                        booking['role']!, // Service provided below stars
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Smaller font
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        booking['date']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal, // Poppins Regular
                        ),
                      ),
                      Text(
                        booking['duration']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstantBookingTab() {
    // This tab is identical to Daily Booking tab but with different title and no specific buttons
    final List<Map<String, String>> previousBookings = [
      {'name': 'Sophie T', 'role': 'House Maid', 'rating': '4.5', 'date': '21 Aug 23', 'duration': '2 months'},
      {'name': 'Jane Doe', 'role': 'Cook', 'rating': '4.0', 'date': '05 May 23', 'duration': '8 months'},
      {'name': 'Marci Senter', 'role': 'Elder care', 'rating': '4.8', 'date': '10 Mar 23', 'duration': '10 months'},
      {'name': 'Chieko Chute', 'role': 'Cleaner', 'rating': '4.2', 'date': '15 Jan 23', 'duration': '12 months'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instant Booking', // Changed title
            style: GoogleFonts.poppins(
              fontSize: (AppTextStyles.heading4.fontSize ?? 20.0) - 2,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.neutralWhite,
                          backgroundImage: NetworkImage('https://placehold.co/100x100/FFFFFF/5D4EFF?text=JD'),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              Icons.star_rate_rounded,
                              color: starIndex < 4 ? AppColors.emotionYellow : AppColors.neutralWhite.withOpacity(0.5),
                              size: 16,
                            );
                          }),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: 3231',
                          style: GoogleFonts.poppins(
                            fontSize: (AppTextStyles.bodyText.fontSize ?? 14.0) + 2,
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRowAligned('Name', 'Jane Doe'),
                          _buildDetailRowAligned('Service', 'Cleaning'),
                          _buildDetailRowAligned('Contact', '9873724556'),
                          _buildDetailRowAligned('Salary', '2000/mon'),
                          _buildDetailRowAligned('Timing', '9am - 11am'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Wrap( // Changed to Wrap for responsiveness
                  spacing: 5.0, // Horizontal spacing between buttons
                  runSpacing: 5.0, // Vertical spacing between rows of buttons
                  alignment: WrapAlignment.center, // Center the buttons
                  children: [
                    _buildOutlineButton(context, 'Cancel', Icons.close),
                    _buildOutlineButton(context, 'Reschedule', Icons.calendar_today_outlined),
                    _buildOutlineButton(context, 'Replace', Icons.loop),
                  ],
                ),
              ],
            ),
          ),
          // Removed "File a Complaint" and "Get a Backup Maid" for Instant tab
          const SizedBox(height: 25),
          Text(
            'Previous Bookings',
            style: GoogleFonts.poppins(
              fontSize: (AppTextStyles.heading4.fontSize ?? 20.0) - 2,
              color: AppColors.neutralBlack,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: previousBookings.length,
            itemBuilder: (context, index) {
              final booking = previousBookings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.secondaryPastelPurple,
                    backgroundImage: NetworkImage('https://placehold.co/80x80/${AppColors.secondaryPastelPurple.toHex().substring(1)}/${AppColors.primaryPurple.toHex().substring(1)}?text=${booking['name']![0]}'),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.neutralBlack,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (starIndex) {
                          double rating = double.parse(booking['rating']!);
                          return Icon(
                            Icons.star_rate_rounded,
                            color: starIndex < rating.floor() ? AppColors.emotionYellow : AppColors.neutralMediumGray,
                            size: 12,
                          );
                        }),
                      ),
                      Text(
                        booking['role']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        booking['date']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        booking['duration']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.neutralDarkGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to build a detail row with aligned colons
  Widget _buildDetailRowAligned(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0), // Reduced vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        children: [
          // Use a fixed width for the label to align colons
          SizedBox(
            width: 70, // Adjusted fixed width for labels, find a balance
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: (AppTextStyles.bodyText.fontSize ?? 14.0) - 2, // Smaller font, safely unwrapped
                color: AppColors.neutralWhite,
                fontWeight: FontWeight.normal, // Poppins Regular for labels (not medium)
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: (AppTextStyles.bodyText.fontSize ?? 14.0) - 2, // Smaller font, safely unwrapped
              color: AppColors.neutralWhite,
              fontWeight: FontWeight.normal, // Poppins Regular
            ),
          ),
          Expanded( // Use Expanded for values
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: (AppTextStyles.bodyText.fontSize ?? 14.0) - 2, // Smaller font, safely unwrapped
                color: AppColors.neutralWhite,
                fontWeight: FontWeight.normal, // Poppins Regular for values
              ),
              overflow: TextOverflow.ellipsis, // Truncate long text
              maxLines: 1, // Ensure it doesn't wrap to next line if it's too long
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context, String text, IconData icon) {
    // Removed Padding from here, Wrap handles spacing.
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$text clicked')),
        );
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.neutralWhite, // Filled with white
        side: BorderSide(color: AppColors.primaryPurple, width: 1), // Light blue thin outline
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Completely curved edges
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Increased vertical padding
        minimumSize: Size.zero, // Important to allow button to shrink to text size
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
      ),
      icon: Icon(icon, color: AppColors.neutralBlack, size: 18), // Icon color to black, smaller size
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10, // Reduced font size
          color: AppColors.neutralBlack, // Text color to black
          fontWeight: FontWeight.w500, // Poppins Medium
        ),
      ),
    );
  }
}
