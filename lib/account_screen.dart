import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/bill_screen.dart';
import 'package:superbai/customer_care_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:superbai/models/user_profile.dart';
import 'package:superbai/repositories/user_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superbai/data/whatsapp_messages.dart';
import 'EditProfileScreen.dart';
import 'ReferMaidScreen.dart';
import 'TermsAndConditionsScreen.dart';
import 'mobile_number_screen.dart'; // Import for logout navigation

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedNavbarIndex = 3; // Default to 'Account' tab
  String _userName = 'Loading...';
  String _userAddress = 'Loading address...';
  bool _isDeletingAccount = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  static const String _supportWhatsAppNumber = '919819293826';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetches the logged-in user's full name from Firestore.
  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final profile = await _userRepository.getProfileForAuthUser(user);

        if (mounted) {
          setState(() {
            if (profile != null) {
              _userName = profile.name.isNotEmpty ? profile.name : 'No Name';
              _userAddress = _formatUserAddress(profile);
            } else {
              _userName = 'No Name';
              _userAddress = 'Address not added yet';
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _userName = 'Error';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching user data: $e')),
          );
        }
      }
    }
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MobileNumberScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Handles the user logout process.
  Future<void> _logout() async {
    await _auth.signOut();
    await _goToLogin();
  }

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showMessage('You are not signed in.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete account?', style: GoogleFonts.poppins()),
        content: Text(
          'This permanently deletes your profile, bookings, payments, '
          'reviews, complaints, and related data from SuperBai. '
          'You will be signed out.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.emotionOrangeRed),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _userRepository.deleteAllUserDataForAuthUser(user);

      String? authNote;
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          authNote =
              'Account data deleted. Sign in again recently to remove the phone login from this device.';
        } else {
          authNote =
              'Account data deleted. Phone login could not be removed: ${e.message}';
        }
      } catch (e) {
        authNote = 'Account data deleted. Phone login could not be removed: $e';
      }

      await _auth.signOut();
      if (!mounted) return;
      if (authNote != null) {
        _showMessage(authNote);
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        if (!mounted) return;
      }
      await _goToLogin();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      _showMessage('Could not delete account data: $e');
    }
  }

  Future<void> _openComplaintWhatsAppChat() async {
    final message = Uri.encodeComponent(WhatsAppMessages.complaint());
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

  String _formatUserAddress(UserProfile profile) {
    final parts = <String>[];
    if (profile.building.trim().isNotEmpty) {
      parts.add(profile.building.trim());
    }
    if (profile.pincode.trim().isNotEmpty) {
      parts.add('Flat ${profile.pincode.trim()}');
    }
    return parts.isEmpty ? 'Address not added yet' : parts.join(', ');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeletingAccount,
      child: Stack(
      children: [
        Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Column(
        children: [
          // Top Purple Section with Profile and Points
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              30,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.neutralWhite,
                      backgroundImage: const NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwh1EKt_AqF35M7LTejJXysIIKQ31zWt3fzlX5-F5DoUDrhOxfeySO5E_lgNeIuTrWJKM&usqp=CAU',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the fetched user name here
                        Text(
                          _userName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: AppColors.neutralWhite,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SuperBai member',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.neutralWhite.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        // Navigate to EditProfileScreen and wait for a result.
                        // If the profile was updated, refresh the user data.
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          _fetchUserData(); // Refresh user data if name was changed
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.neutralWhite,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildAccountOption(
                    icon: Icons.location_on_outlined,
                    text: 'My Address',
                    subtitle: _userAddress,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ).then((result) {
                        if (result == true && mounted) {
                          _fetchUserData();
                        }
                      });
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.redeem_outlined,
                    text: 'Coupons',
                    subtitle: 'Coming soon',
                    onTap: () {
                      _showMessage('Coupons are coming soon.');
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.people_outline,
                    text: 'Refer a Maid/Friend',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReferMaidScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.headset_mic_outlined,
                    text: 'Customer Care',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerCareScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.info_outline,
                    text: 'Terms & Conditions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAccountOption(
                    icon: Icons.edit_note_outlined,
                    text: 'File a Complaint',
                    onTap: _openComplaintWhatsAppChat,
                  ),
                  _buildAccountOption(
                    icon: Icons.person_remove_outlined,
                    text: 'Delete account',
                    textColor: AppColors.emotionOrangeRed,
                    iconColor: AppColors.emotionOrangeRed,
                    showArrow: false,
                    onTap: _isDeletingAccount ? () {} : _deleteAccount,
                  ),
                  _buildAccountOption(
                    icon: Icons.logout,
                    text: 'Logout',
                    textColor: AppColors.emotionOrangeRed,
                    iconColor: AppColors.emotionOrangeRed,
                    showArrow: false,
                    onTap: _logout,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.neutralWhite,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDarkGray,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavbarIndex,
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
          if (_isDeletingAccount) return;
          if (index == _selectedNavbarIndex) {
            return; // Avoid redundant navigation
          }
          setState(() {
            _selectedNavbarIndex = index;
          });
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BookingScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BillScreen()),
            );
          }
        },
      ),
        ),
        if (_isDeletingAccount)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.neutralBlack.withValues(alpha: 0.35),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
      ],
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    String? subtitle,
    Color? textColor,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.primaryPurple),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor ?? AppColors.primaryPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.neutralDarkGray,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primaryPink,
              ),
          ],
        ),
      ),
    );
  }
}
