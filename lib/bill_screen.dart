import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/booking_screen.dart';
import 'package:superbai/account_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superbai/data/whatsapp_messages.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  static const String _supportWhatsAppNumber = '919819293826';

  static const Color _passPurple = Color(0xFF7B3FF2);
  static const Color _passPink = Color(0xFFFF4DA6);
  static const Color _passBackground = Color(0xFFF8F7FB);
  static const Color _textMuted = Color(0xFF687280);
  static const Color _textDark = Color(0xFF1F1235);
  static const Color _lightPink = Color(0xFFFFE6F1);
  static const Color _lightPurple = Color(0xFFEDE8FF);

  int _selectedNavbarIndex = 2;

  Future<void> _openJoinPassWhatsApp() async {
    final message = Uri.encodeComponent(WhatsAppMessages.superbaiPass());
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _passBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopNav(),
              _buildHeroSection(),
              _buildSectionTitle('why superbai pass?'),
              _buildFeatures(),
              _buildSectionTitle('choose your plan', leadingEmoji: '🤍'),
              _buildPlans(),
              _buildJoinCta(),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _passPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 6),
              Text(
                'superbai',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _passPurple,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E2F8)),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.local_fire_department,
                      color: _passPurple,
                      size: 18,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8E2F8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 14, color: _passPurple),
                    const SizedBox(width: 5),
                    Text(
                      'Trusted by 100+ families',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EEFF), Color(0xFFFDF0F8), Color(0xFFFFF5F9)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_passPink, _passPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '✦ join superbai pass',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zero maid',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'household stress',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _passPurple,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _passPurple.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.home_filled,
                        color: _passPurple,
                        size: 36,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'once you take',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _textDark,
                height: 1.3,
              ),
            ),
            Text(
              'SuperBai Pass',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _passPink,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We handle your maid needs, so you can focus on what truly matters.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildHeroBadgeChip(
                    Icons.access_time,
                    'Instant Support',
                    "We're always here",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHeroBadgeChip(
                    Icons.shield_outlined,
                    'Trusted & Verified',
                    'Maids from your area',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadgeChip(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _lightPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: _passPurple),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? leadingEmoji}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingEmoji != null) ...[
            Text(leadingEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
          ] else ...[
            Text('✦', style: GoogleFonts.poppins(color: _passPurple)),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _passPurple,
            ),
          ),
          const SizedBox(width: 8),
          Text('✦', style: GoogleFonts.poppins(color: _passPurple)),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      (
        icon: Icons.verified_user_outlined,
        bg: _lightPurple,
        color: _passPurple,
        title: 'Zero Maid Household Stress',
        desc: 'Once you take Superbai Pass, consider maid stress – gone.',
      ),
      (
        icon: Icons.calendar_month_outlined,
        bg: _lightPink,
        color: _passPink,
        title: "3 Free Substitute Services on Maids' Holiday",
        desc:
            'Get up to 3 free substitute services every month when your maid is on leave.',
      ),
      (
        icon: Icons.access_time,
        bg: _lightPink,
        color: _passPink,
        title: 'Flexible Service Time',
        desc:
            "Change your maid's service time as per your request and urgency.",
      ),
      (
        icon: Icons.location_on_outlined,
        bg: _lightPurple,
        color: _passPurple,
        title: 'Trusted Maids from Nearby Areas',
        desc:
            'Get trusted maids who are working in your neighbourhood, not unknown maids.',
      ),
      (
        icon: Icons.support_agent_outlined,
        bg: _lightPurple,
        color: _passPurple,
        title: 'Dedicated Support',
        desc:
            'To solve all your household maid stress after joining Superbai Pass.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: features.map((f) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _passPurple.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: f.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f.icon, color: f.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _passPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        f.desc,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlans() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildPlanCard(
              labelColor: _passPurple,
              name: 'essential',
              nameColor: _passPink,
              size: 'for 1 bhk, 2 bhk & 3 bhk',
              price: '₹399',
              houseGradient: const [Color(0xFFE8D8FF), Color(0xFFC9B8F8)],
              houseIconColor: _passPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPlanCard(
              labelColor: const Color(0xFF3B82F6),
              name: 'premium',
              nameColor: _passPurple,
              size: 'for large 3 bhk, 4 bhk & above',
              price: '₹699',
              priceColor: _passPurple,
              houseGradient: const [Color(0xFFD4E8FF), Color(0xFFA8CAFF)],
              houseIconColor: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required Color labelColor,
    required String name,
    required Color nameColor,
    required String size,
    required String price,
    required List<Color> houseGradient,
    required Color houseIconColor,
    Color? priceColor,
  }) {
    const features = [
      'up to 3 free substitute services / month',
      'flexible service time changes',
      'trusted maids from nearby areas',
      'dedicated support',
      'priority support',
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _passPurple.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'superbai pass',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: nameColor,
                ),
              ),
              Text(
                size,
                style: GoogleFonts.poppins(fontSize: 9, color: _textMuted),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: price,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: priceColor ?? _passPurple,
                      ),
                    ),
                    TextSpan(
                      text: '/month',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: const BoxDecoration(
                          color: _lightPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              fontSize: 7,
                              color: _passPink,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: _textMuted,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: 16,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: houseGradient,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.home_outlined, color: houseIconColor, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildJoinCta() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openJoinPassWhatsApp,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_passPurple, Color(0xFF9B59F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'join superbai pass now',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'chat with us on whatsapp',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
