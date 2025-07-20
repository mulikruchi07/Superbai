import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/account_screen.dart'; // For back navigation
import 'package:package_info_plus/package_info_plus.dart'; // For app info, if needed for WhatsApp/Message
import 'package:url_launcher/url_launcher.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/complaint_screen.dart';

// --- CustomerCareScreen Class ---
class CustomerCareScreen extends StatefulWidget {
  const CustomerCareScreen({super.key});

  @override
  State<CustomerCareScreen> createState() => _CustomerCareScreenState();
}

class _CustomerCareScreenState extends State<CustomerCareScreen> {
  bool _showFloatingButtons =
      false; // State to manage visibility of additional buttons

  // Function to launch WhatsApp
  Future<void> _launchWhatsApp() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening WhatsApp...')));
    final Uri whatsappUri = Uri.parse(
      'whatsapp://send?phone=+919876543210',
    ); // Replace with actual number
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('WhatsApp not installed.')));
    }
  }

  // Function to launch SMS (Chat)
  Future<void> _launchSms() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening Messages...')));
    final Uri smsUri = Uri.parse(
      'sms:+919876543210?body=Hello',
    ); // Replace with actual number
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('SMS app not available.')));
    }
  }

  // Function to make a phone call
  Future<void> _makePhoneCall() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calling...')));
    final Uri telUri = Uri.parse(
      'tel:+919876543210',
    ); // Replace with actual number
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer.')),
      );
    }
  }

  // Function to show the "Still Need Help?" slider (modal bottom sheet)
  void _showStillNeedHelpSlider() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.neutralWhite, // White background for the slider
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25.0),
            ), // Rounded top corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              Container(
                // Drag indicator
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.neutralMediumGray,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildContactOption(
                    iconWidget: Image.asset(
                      // Using Image.asset for call icon
                      'assets/call_icon.png', // Assuming you'll add this asset
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.phone,
                          size: 30,
                          color: AppColors.primaryPurple,
                        ); // Fallback icon
                      },
                    ),
                    text: 'Call',
                    color: AppColors
                        .primaryPurple, // Color for background circle if needed
                    onTap: _makePhoneCall,
                  ),
                  _buildContactOption(
                    iconWidget: Image.asset(
                      // Using Image.asset for whatsapp icon
                      'assets/whatsapp_icon.png',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.chat,
                          size: 30,
                          color: Colors.green,
                        ); // Fallback icon (Icons.chat as whatsapp is not direct)
                      },
                    ),
                    text: 'Whatsapp',
                    color: Colors.green,
                    onTap: _launchWhatsApp,
                  ),
                  _buildContactOption(
                    iconWidget: Image.asset(
                      // Using Image.asset for message icon
                      'assets/message_icon.png',
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.message,
                          size: 30,
                          color: AppColors.primaryPurple,
                        ); // Fallback icon
                      },
                    ),
                    text: 'Chat',
                    color: AppColors.primaryPurple,
                    onTap: _launchSms,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build contact options within the slider
  Widget _buildContactOption({
    required Widget iconWidget, // Changed to accept a Widget for icon
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30, // Icon background circle size
            backgroundColor: color.withOpacity(
              0.1,
            ), // Light transparent background
            child: iconWidget, // Use the passed widget directly
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12, // Small font size
              color: Colors.black,
              fontWeight: FontWeight.normal,
            ),
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
          onPressed: () {
            Navigator.pop(context); // Go back to AccountScreen
          },
        ),
        title: Text(
          'Customer care',
          style: GoogleFonts.poppins(
            fontSize: 18, // Header font size
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        // Use a Stack for the entire body to layer content and floating buttons
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 0.0,
              vertical: 0.0,
            ), // Overall padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Maid'),
                _buildQuestionItem('What services do the maids offer?', () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FAQAnswerScreen(
                            screenTitle: 'Maid Services',
                            contentText:
                                'Our maids offer a variety of services including cleaning, cooking, laundry, elder-care, and babysitting. You can select specific services and customize them to your needs when booking.',
                            showStillNeedHelp:
                                _showStillNeedHelpSlider, // Pass the function
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Start from right
                            const end = Offset.zero; // End at current position
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                }),
                _buildQuestionItem(
                  'How can I reschedule or cancel a booking?',
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FAQAnswerScreen(
                              screenTitle: 'Reschedule/Cancel Booking',
                              contentText:
                                  'To reschedule or cancel a booking, go to the "Booking" tab in the bottom navigation bar. Select the active booking you wish to change, and you will find options to "Reschedule" or "Cancel" the service.',
                              showStillNeedHelp:
                                  _showStillNeedHelpSlider, // Pass the function
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),

                _buildSectionHeader('My booking'),
                _buildQuestionItem('How can I modify an existing booking?', () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FAQAnswerScreen(
                            screenTitle: 'Modify Booking',
                            contentText:
                                'To modify an existing booking, navigate to the "Booking" tab. Under "Active Booking," tap on the booking you want to modify. You can then adjust details like timing or specific service requirements.',
                            showStillNeedHelp:
                                _showStillNeedHelpSlider, // Pass the function
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                }),
                _buildQuestionItem(
                  'How can I track the progress of my maid?',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tracking feature not yet implemented.'),
                      ),
                    );
                  },
                ),

                _buildSectionHeader('Payment'),
                _buildQuestionItem('What is the payment process for maid ?', () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FAQAnswerScreen(
                            screenTitle: 'Payment Process',
                            contentText:
                                'Payments are processed securely through the app. You can pay via various methods including credit/debit cards and mobile wallets. Your bill will be generated monthly.',
                            showStillNeedHelp:
                                _showStillNeedHelpSlider, // Pass the function
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                }),
                _buildQuestionItem('Is my payment information secure?', () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          FAQAnswerScreen(
                            screenTitle: 'Payment Security',
                            contentText:
                                'Yes, your payment information is highly secure. We use industry-standard encryption and security protocols to protect your data. Your details are never shared with third parties.',
                            showStillNeedHelp:
                                _showStillNeedHelpSlider, // Pass the function
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                    ),
                  );
                }),

                _buildSectionHeader('Complaint'),
                _buildQuestionItem(
                  'I was charged incorrectly for my service.',
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FAQAnswerScreen(
                              screenTitle: 'Incorrect Charge Complaint',
                              contentText:
                                  'If you were charged incorrectly, go to the "Account" tab, then "Customer Care," and select "File a Complaint." Choose "Incorrect Charge" as the reason and provide details. Our team will review and assist you.',
                              showStillNeedHelp:
                                  _showStillNeedHelpSlider, // Pass the function
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),
                _buildQuestionItem(
                  'Not satisfied with the quality of the service.',
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FAQAnswerScreen(
                              screenTitle: 'Service Quality Complaint',
                              contentText:
                                  'If you are not satisfied with service quality, go to the "Account" tab, then "Customer Care," and select "File a Complaint." Choose "Service Quality" as the reason and describe the issue. We will investigate and take appropriate action.',
                              showStillNeedHelp:
                                  _showStillNeedHelpSlider, // Pass the function
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),

                _buildSectionHeader('Referrals'),
                _buildQuestionItem(
                  'How does the maid referral program work?',
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FAQAnswerScreen(
                              screenTitle: 'Referral Program',
                              contentText:
                                  'Our referral program allows you to earn rewards by inviting friends or referring maids to our platform. Once they complete their first service, you receive a bonus!',
                              showStillNeedHelp:
                                  _showStillNeedHelpSlider, // Pass the function
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),
                _buildQuestionItem(
                  'Benefits of referring maids through the app?',
                  () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FAQAnswerScreen(
                              screenTitle: 'Referral Benefits',
                              contentText:
                                  'Benefits include cash bonuses, service discounts, and priority access to new features. It\'s a great way to save money and help others find reliable maid services.',
                              showStillNeedHelp:
                                  _showStillNeedHelpSlider, // Pass the function
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20), // Adjusted spacing
              ],
            ),
          ),
          // Floating Action Buttons (reduced size)
          Positioned(
            bottom: 20.0,
            right: 20.0, // Changed from right to right
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // WhatsApp Icon
                AnimatedOpacity(
                  opacity: _showFloatingButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      _showFloatingButtons ? 0.0 : 120.0,
                    ), // Reduced animation distance
                    child: GestureDetector(
                      onTap: _launchWhatsApp,
                      child: Container(
                        width: 50, // Reduced size
                        height: 50, // Reduced size
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/whatsapp_icon.png', // WhatsApp image asset
                          width: 30, // Reduced icon size
                          height: 30, // Reduced icon size
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.chat, // Fallback icon changed to Icons.chat
                              color: Colors.green,
                              size: 30, // Reduced fallback icon size
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Reduced space between buttons
                // Message Icon
                AnimatedOpacity(
                  opacity: _showFloatingButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      _showFloatingButtons ? 0.0 : 60.0,
                    ), // Reduced animation distance
                    child: GestureDetector(
                      onTap: _launchSms,
                      child: Container(
                        width: 50, // Reduced size
                        height: 50, // Reduced size
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/message_icon.png', // Message image asset
                          width: 30, // Reduced icon size
                          height: 30, // Reduced icon size
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.message,
                              color: AppColors.primaryPurple,
                              size: 30, // Reduced fallback icon size
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8), // Reduced space between buttons
                // Main Toggle Button (Chat or Close)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFloatingButtons = !_showFloatingButtons;
                    });
                  },
                  child: Container(
                    width: 50, // Reduced size
                    height: 50, // Reduced size
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      _showFloatingButtons
                          ? 'assets/close_icon.png'
                          : 'assets/chat_icon.png',
                      width: 30, // Reduced icon size
                      height: 30, // Reduced icon size
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _showFloatingButtons ? Icons.close : Icons.chat,
                          color: AppColors.primaryPurple,
                          size: 30, // Reduced fallback icon size
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build section headers
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      color: AppColors.neutralDarkGray.withOpacity(0.2),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.neutralBlack,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Helper widget to build individual question items
  Widget _buildQuestionItem(String question, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          // No border to remove lines between list elements
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                question,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.neutralBlack,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.neutralDarkGray,
            ),
          ],
        ),
      ),
    );
  }
}

// --- FAQAnswerScreen Class (now in the same file) ---
class FAQAnswerScreen extends StatelessWidget {
  final String screenTitle;
  final String contentText;
  final VoidCallback?
  showStillNeedHelp; // Callback for the "Still Need Help?" button

  const FAQAnswerScreen({
    super.key,
    required this.screenTitle,
    required this.contentText,
    this.showStillNeedHelp, // Initialize the callback
  });

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
            Navigator.pop(context);
          },
        ),
        title: Text(
          screenTitle,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.neutralWhite,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contentText,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: AppColors.neutralBlack,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 40), // Add some space below the content
            if (showStillNeedHelp !=
                null) // Conditionally show the button if the callback is provided
              SizedBox(
                // Added SizedBox to make the button full width
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: showStillNeedHelp, // Call the passed function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Still Need Help?',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.neutralWhite,
                      fontWeight: FontWeight.bold,
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
