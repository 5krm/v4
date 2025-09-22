import 'package:flutter/material.dart';

class SwitchColors {
  // === SWITCH VPN DESIGN SYSTEM ===

  // Basic Foundation
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // === PRIMARY BLUE SYSTEM ===
  static const Color switchBlue = Color(0xFF4C82F7); // Main brand blue
  static const Color switchDarkBlue = Color(0xFF2E4FA3); // Darker blue
  static const Color switchLightBlue = Color(0xFF6B9FFF); // Lighter blue
  static const Color switchAccentBlue = Color(0xFF5A8FFF); // Accent blue

  // === DARK THEME BACKGROUND ===
  static const Color switchDark = Color(0xFF1A1D29); // Main dark background
  static const Color switchDarkCard = Color(0xFF242938); // Card background
  static const Color switchDarkSurface = Color(0xFF2A2F3E); // Surface color
  static const Color switchDarkModal = Color(0xFF1F2232); // Modal background

  // === STATUS COLORS ===
  static const Color switchGreen = Color(0xFF00D970); // Success/Connected
  static const Color switchRed = Color(0xFFFF4757); // Error/Disconnected
  static const Color switchOrange = Color(0xFFFF9F43); // Warning
  static const Color switchYellow = Color(0xFFFFD93D); // Info

  // === TEXT COLORS ===
  static const Color switchTextPrimary = Color(0xFFFFFFFF);
  static const Color switchTextSecondary = Color(0xFFB8BCC8);
  static const Color switchTextTertiary = Color(0xFF8E92A3);
  static const Color switchTextDisabled = Color(0xFF5A5F73);

  // === GLASS & SURFACE ===
  static const Color glassLight = Color(0x1AFFFFFF);
  static const Color glassMedium = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);

  // === SWITCH VPN GRADIENTS ===

  // Main App Background
  static const LinearGradient switchBgGradient = LinearGradient(
    colors: [Color(0xFF1A1D29), Color(0xFF242938), Color(0xFF1A1D29)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Connection Button Gradient
  static const LinearGradient switchConnectionGradient = LinearGradient(
    colors: [switchBlue, switchAccentBlue, switchLightBlue],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Primary Button Gradient
  static const LinearGradient switchButtonGradient = LinearGradient(
    colors: [switchBlue, switchDarkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Background Gradient
  static const LinearGradient switchCardGradient = LinearGradient(
    colors: [Color(0xFF2A2F3E), Color(0xFF242938)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success Button Gradient
  static const LinearGradient switchSuccessGradient = LinearGradient(
    colors: [switchGreen, Color(0xFF00B85C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Danger Button Gradient
  static const LinearGradient switchDangerGradient = LinearGradient(
    colors: [switchRed, Color(0xFFE73C43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === UTILITY METHODS ===

  // Get box shadow with glow effect
  static BoxShadow getGlow(Color color,
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

  // Get card decoration with Switch VPN styling
  static BoxDecoration getSwitchCardDecoration({
    double borderRadius = 16,
    bool hasGlow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      gradient: switchCardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glassLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        if (hasGlow && glowColor != null)
          getGlow(glowColor, blurRadius: 15, spreadRadius: 2),
      ],
    );
  }
}
