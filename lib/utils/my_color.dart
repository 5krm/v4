// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';

class MyColor {
  // === ULTRA MODERN COLOR SYSTEM ===

  // Basic Foundation
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // === NEON GRADIENT SYSTEM ===

  // Primary Neon Colors
  static const Color neonPink = Color(0xFFFF0080);
  static const Color neonBlue = Color(0xFF00BFFF);
  static const Color neonPurple = Color(0xFF8B00FF);
  static const Color neonGreen = Color(0xFF00FF80);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonOrange = Color(0xFFFF8000);

  // Cyber Colors
  static const Color cyberViolet = Color(0xFF7C3AED);
  static const Color cyberIndigo = Color(0xFF4F46E5);
  static const Color cyberTeal = Color(0xFF14B8A6);
  static const Color cyberEmerald = Color(0xFF10B981);

  // Dark Theme Foundation
  static const Color darkSpace = Color(0xFF0A0A0F);
  static const Color darkMatter = Color(0xFF1A1B23);
  static const Color darkNebula = Color(0xFF2D2E3A);
  static const Color darkVoid = Color(0xFF1C1D25);

  // Glass & Surface Colors
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassMedium = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);
  static const Color surfaceGlow = Color(0xFF252633);

  // Text Hierarchy
  static const Color textUltra = Color(0xFFFFFFFF);
  static const Color textHigh = Color(0xFFE2E4E9);
  static const Color textMedium = Color(0xFFB3B8C4);
  static const Color textLow = Color(0xFF7A7F8C);
  static const Color textDisabled = Color(0xFF4A4D58);

  // Status Colors with Glow
  static const Color successGlow = Color(0xFF00FF88);
  static const Color warningGlow = Color(0xFFFFAA00);
  static const Color errorGlow = Color(0xFFFF4081);
  static const Color infoGlow = Color(0xFF40C7FF);

  // === PREMIUM GRADIENTS ===

  // Hero Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF8B00FF), Color(0xFF00BFFF), Color(0xFF00FF80)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5), Color(0xFF14B8A6)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFFFF0080), Color(0xFF8B00FF), Color(0xFF00BFFF)],
    stops: [0.0, 0.4, 1.0],
    begin: Alignment(-0.8, -0.8),
    end: Alignment(0.8, 0.8),
  );

  // Background Gradients
  static const LinearGradient spaceGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF1A1B23), Color(0xFF0A0A0F)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient cosmicGradient = RadialGradient(
    colors: [
      Color(0xFF2D2E3A),
      Color(0xFF1A1B23),
      Color(0xFF0A0A0F),
    ],
    stops: [0.0, 0.7, 1.0],
    center: Alignment.center,
    radius: 1.2,
  );

  // Button Gradients
  static const LinearGradient buttonPrimary = LinearGradient(
    colors: [Color(0xFF8B00FF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonSecondary = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonSuccess = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonDanger = LinearGradient(
    colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === LEGACY COMPATIBILITY ===
  static const Color primary = cyberViolet;
  static const Color primaryLight = neonPurple;
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color accent = neonCyan;
  static const Color accentLight = neonBlue;
  static const Color success = successGlow;
  static const Color warning = warningGlow;
  static const Color error = errorGlow;
  static const Color bg = darkSpace;
  static const Color bgSecondary = darkMatter;
  static const Color cardBg = darkNebula;
  static const Color surfaceBg = surfaceGlow;
  static const Color textPrimary = textUltra;
  static const Color textSecondary = textMedium;
  static const Color textAccent = neonCyan;

  // Old colors for backward compatibility
  static const Color yellow = neonCyan;
  static const Color textFieldBg = darkNebula;
  static const Color ipContainer = surfaceGlow;
  static const Color orange = neonOrange;
  static const Color settingsHeader = darkMatter;
  static const Color settingsBody = darkSpace;
  static const Color proItemPackBg = surfaceGlow;
  static const Color green = successGlow;
  static const Color yellowDark = warningGlow;
  static const Color bgColor = darkSpace; // Added missing bgColor getter

  // Glassmorphism
  static Color glassBg = glassLight;
  static Color glassBorder = glassMedium;

  // Legacy gradients
  static const LinearGradient primaryGradient = buttonPrimary;
  static const LinearGradient accentGradient = buttonSecondary;
  static const LinearGradient bgGradient = spaceGradient;

  // === DYNAMIC THEME UTILITIES ===

  // Get gradient by name
  static LinearGradient getGradient(String name) {
    switch (name) {
      case 'hero':
        return heroGradient;
      case 'cyber':
        return cyberGradient;
      case 'neon':
        return neonGradient;
      case 'primary':
        return buttonPrimary;
      case 'secondary':
        return buttonSecondary;
      case 'success':
        return buttonSuccess;
      case 'danger':
        return buttonDanger;
      default:
        return heroGradient;
    }
  }

  // Get neon color with glow effect
  static BoxShadow getNeonGlow(Color color,
      {double blurRadius = 20, double spreadRadius = 5}) {
    return BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: const Offset(0, 0),
    );
  }

  // Get glassmorphism decoration
  static BoxDecoration getGlassDecoration({
    double borderRadius = 16,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? glassLight,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? glassMedium,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
