import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Extension to easily convert hex color strings to Color objects
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional "0x" prefix
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to true (default is true).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class AppColors {
  // Primary Colors
  static Color primaryPurple = HexColor.fromHex('#5D4EFF');
  static Color primaryLightPurple = HexColor.fromHex('#9A74FF');
  static Color primaryPink = HexColor.fromHex('#FF69B4');

  // Secondary Colors (Soft pastel pinks and purples)
  static Color secondaryPastelPink = HexColor.fromHex('#FAD2E1');
  static Color secondaryPastelPurple = HexColor.fromHex('#E0BBE4');

  // Emotion Colors
  static Color emotionGreen = HexColor.fromHex('#22C55E');
  static Color emotionYellow = HexColor.fromHex('#EAB308');
  static Color emotionOrangeRed = HexColor.fromHex('#F97316');

  // Neutral Colors
  static Color neutralWhite = Colors.white;
  static Color neutralLightGray = HexColor.fromHex('#F5F5F5');
  static Color neutralMediumGray = HexColor.fromHex('#E0E0E0');
  static Color neutralDarkGray = HexColor.fromHex('#757575');
  static Color neutralBlack = Colors.black;
}

class AppTextStyles {
  // Base font style using Poppins
  static TextStyle _baseTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Headings - Bold weight
  static TextStyle heading1 = _baseTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralBlack,
  );
  static TextStyle heading2 = _baseTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralBlack,
  );
  static TextStyle heading3 = _baseTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralBlack,
  );
  static TextStyle heading4 = _baseTextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralBlack,
  );
  static TextStyle heading5 = _baseTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.neutralBlack,
  );

  // Subtext - Medium weight
  static TextStyle subtext = _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.neutralDarkGray,
  );

  // Body text - Regular weight
  static TextStyle bodyText = _baseTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.neutralDarkGray,
  );

  // Button text - Capitalized, clear spacing, Medium weight (as per subtext spec)
  static TextStyle buttonText = _baseTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.neutralWhite, // Typically white on a colored button
  );
}

// App Theme Data
final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryPurple,
  hintColor: AppColors.primaryPink, // Used for accent color/secondary emphasis
  scaffoldBackgroundColor: AppColors.neutralWhite,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.neutralWhite,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.neutralBlack),
    titleTextStyle: AppTextStyles.heading4.copyWith(color: AppColors.neutralBlack),
  ),
  textTheme: TextTheme(
    headlineLarge: AppTextStyles.heading1,
    headlineMedium: AppTextStyles.heading2,
    headlineSmall: AppTextStyles.heading3,
    titleLarge: AppTextStyles.heading4,
    titleMedium: AppTextStyles.heading5,
    bodyLarge: AppTextStyles.subtext,
    bodyMedium: AppTextStyles.bodyText,
    labelLarge: AppTextStyles.buttonText, // For buttons
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    buttonColor: AppColors.primaryPurple,
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryPurple, // Background color
      foregroundColor: AppColors.neutralWhite, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: AppTextStyles.buttonText,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryPurple,
      side: BorderSide(color: AppColors.primaryPurple, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: AppTextStyles.buttonText,
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AppColors.primaryPurple,
    selectionColor: AppColors.primaryLightPurple.withOpacity(0.3),
    selectionHandleColor: AppColors.primaryPurple,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.neutralLightGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none, // No border by default
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.primaryPurple, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.emotionOrangeRed, width: 2.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: AppColors.emotionOrangeRed, width: 2.0),
    ),
    labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.neutralDarkGray),
    hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.neutralMediumGray),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
);
