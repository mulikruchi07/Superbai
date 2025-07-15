import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superbai/theme.dart'; // Assuming AppColors and other theme definitions are here
import 'package:flutter/services.dart'; // For Clipboard

class CouponScreen extends StatefulWidget {
  CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  // Made the coupons list static const as its content is compile-time constant
  static const List<Map<String, String>> _coupons = [
    const {
      'brand': 'Croma',
      'logo_color': 'E0BBE4/5D4EFF',
      'text_color': 'neutralWhite',
      'logo_text': 'croma',
      'offer_details':
          'Lorem Ipsum is 50% OFF simply dummy text of the printing and typesetting industry. Lorem Ipsum has',
      'conditions':
          'Lorem Ipsum is 50% OFF simply dummy text of the printing and typesetting industry. Lorem Ipsum has',
      'address': 'Street 123, FC Road , Pune',
      'redeem_code': 'CROMA50OFF',
    },
    const {
      'brand': 'McDonalds',
      'logo_color': 'FF0000/FFFFFF',
      'text_color': 'neutralWhite',
      'logo_text': 'McDonald\'s',
      'offer_details':
          'Get 20% off on your next order. Valid for dine-in and takeaway.',
      'conditions': 'Minimum purchase of \$10. Not valid with other offers.',
      'address': 'Burger Street, Food City',
      'redeem_code': 'MCDONALDS20',
    },
    const {
      'brand': 'Canva',
      'logo_color': '00C4CC/FFFFFF',
      'text_color': 'neutralWhite',
      'logo_text': 'Canva',
      'offer_details': 'Enjoy 3 months free on Canva Pro subscription.',
      'conditions': 'New users only. Credit card required.',
      'address': 'Online',
      'redeem_code': 'CANVAPROFREE',
    },
    const {
      'brand': 'Domino\'s',
      'logo_color': '006491/FFFFFF',
      'text_color': 'neutralWhite',
      'logo_text': 'Domino\'s',
      'offer_details': 'Buy one get one free on large pizzas.',
      'conditions': 'Valid on selected pizzas. Delivery charges may apply.',
      'address': 'Pizza Lane, Fastfood Town',
      'redeem_code': 'DOMINOSBOGO',
    },
    const {
      'brand': 'Reliance Digital',
      'logo_color': '000000/FFFFFF',
      'text_color': 'neutralWhite',
      'logo_text': 'Reliance Digital',
      'offer_details': 'Flat 15% off on all electronics.',
      'conditions': 'Excludes Apple products. Limited stock.',
      'address': 'Tech Park, Electronic City',
      'redeem_code': 'REL15OFF',
    },
    const {
      'brand': 'DMart',
      'logo_color': '008000/FFFFFF',
      'text_color': 'neutralWhite',
      'logo_text': 'DMart',
      'offer_details': 'Get \$50 cashback on groceries over \$500.',
      'conditions': 'Offer valid once per customer. Terms apply.',
      'address': 'Supermarket Road, Retail Area',
      'redeem_code': 'DMARTCASH50',
    },
  ];

  Map<String, String>? _selectedCoupon;
  bool _isCouponInfoVisible = false;
  bool _showRedeemCode = false;

  void _showCouponInfo(Map<String, String> coupon) {
    setState(() {
      _selectedCoupon = coupon;
      _isCouponInfoVisible = true;
      _showRedeemCode = false; // Reset redeem code visibility
    });
  }

  void _hideCouponInfo() {
    setState(() {
      _isCouponInfoVisible = false;
      _selectedCoupon = null;
      _showRedeemCode = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Copied "$text" to clipboard!')));
    });
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
            // This back button now only navigates back from the CouponScreen itself
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Points',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neutralWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    '350',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.monetization_on,
                    size: 20,
                    color: AppColors.emotionYellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Your Coupons',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = _coupons[index];
                    // Using placehold.co as a dynamic placeholder for coupon cards
                    final String logoUrl =
                        'https://placehold.co/100x50/${coupon['logo_color']}?text=${coupon['logo_text']}';

                    return GestureDetector(
                      onTap: () =>
                          _showCouponInfo(coupon), // Show coupon info on tap
                      child: _buildCouponCard(
                        context,
                        brandLogoUrl: logoUrl,
                        offerText: '10% OFF',
                        description: 'Redeem now at any near by store.',
                        terms: 'Terms and Conditions',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Tap detector to close the info card when tapping outside it
          if (_isCouponInfoVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideCouponInfo,
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Dim the background
                ),
              ),
            ),
          // Coupon Info Card (slides from right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // Adjust right, top, bottom, and width for desired padding and centering
            right: _isCouponInfoVisible
                ? 20
                : -MediaQuery.of(context).size.width,
            top: 80, // Increased top padding
            bottom: 80, // Increased bottom padding
            width:
                MediaQuery.of(context).size.width -
                40, // Adjust width for padding
            child: _selectedCoupon != null
                ? _buildCouponInfoCard(context, _selectedCoupon!)
                : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(
    BuildContext context, {
    required String brandLogoUrl,
    required String offerText,
    required String description,
    required String terms,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.primaryPurple, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    brandLogoUrl,
                  ), // Placeholder image for coupon card
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.2),
                border: Border.all(color: AppColors.primaryPurple, width: 1.0),
              ),
              child: Center(
                child: Text(
                  offerText,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black, // Redeem font color black
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Text(
                    terms,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color:
                          Colors.black, // Terms and condition font color black
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponInfoCard(
    BuildContext context,
    Map<String, String> coupon,
  ) {
    final String logoUrl =
        'https://placehold.co/100x50/${coupon['logo_color']}?text=${coupon['logo_text']}';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    logoUrl,
                  ), // Placeholder image for info card
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Font color black
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coupon['offer_details'] ?? 'No offer details available.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black, // Font color black
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Font color black
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coupon['conditions'] ?? 'No conditions available.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black, // Font color black
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Address',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Font color black
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            coupon['address'] ?? 'No address available.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black, // Font color black
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Icon(Icons.location_on, color: AppColors.primaryPink),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showRedeemCode = !_showRedeemCode;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          fixedSize: const Size.fromHeight(50), // Fixed height
                        ),
                        child: _showRedeemCode
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coupon['redeem_code'] ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppColors.neutralWhite,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () => _copyToClipboard(
                                      coupon['redeem_code'] ?? '',
                                    ),
                                    child: Icon(
                                      Icons.copy,
                                      color: AppColors.neutralWhite,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Redeem Now',
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
            ),
          ],
        ),
      ),
    );
  }
}
