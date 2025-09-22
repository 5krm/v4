import 'package:flutter/material.dart';

class MyFont {
  // Base font family
  static const String _primaryFont = 'outfit';
  static const String _secondaryFont = 'poppins';
  
  // Base text style
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: _primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  // Main font getter for compatibility
  static TextStyle get myFont => _baseStyle;
  
  // Heading styles
  static TextStyle get h1 => _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle get h2 => _baseStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h3 => _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static TextStyle get h4 => _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get h5 => _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static TextStyle get h6 => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  
  // Body text styles
  static TextStyle get body1 => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get body2 => _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  
  static TextStyle get body3 => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  // Button text style
  static TextStyle get button => _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  
  // Caption text style
  static TextStyle get caption => _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
  
  // Overline text style
  static TextStyle get overline => _baseStyle.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  );
  
  // Poppins font method for compatibility
  static TextStyle poppins({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: _secondaryFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
  
  // Custom font method
  static TextStyle custom({
    String fontFamily = _primaryFont,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}

// Legacy variables for backward compatibility
final outfitLight = TextStyle(
  fontFamily: 'outfit',
  fontWeight: FontWeight.w300,
  fontSize: 16,
);
final outfitRegular = TextStyle(
  fontFamily: 'outfit',
  fontWeight: FontWeight.w400,
  fontSize: 16,
);
final outfitMedium = TextStyle(
  fontFamily: 'outfit',
  fontWeight: FontWeight.w500,
  fontSize: 16,
);
final outfitSemiBold = TextStyle(
  fontFamily: 'outfit',
  fontWeight: FontWeight.w600,
  fontSize: 16,
);
final outfitBold = TextStyle(
  fontFamily: 'outfit',
  fontWeight: FontWeight.w700,
  fontSize: 16,
);