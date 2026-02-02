import 'package:flutter/material.dart';

// ==========================================
// DUAL UX THEME SYSTEM
// ==========================================

class AppTheme {
  // ========== ADULT MODE THEME ==========
  static ThemeData get adultTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Professional & Data-Driven
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2563EB), // Blue 600
        secondary: Color(0xFF7C3AED), // Violet 600
        tertiary: Color(0xFF059669), // Emerald 600
        error: Color(0xFFDC2626), // Red 600
        surface: Color(0xFFF8FAFC), // Slate 50
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B), // Slate 800
      ),
      
      // Typography - Clean & Professional
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A), // Slate 900
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color(0xFF475569), // Slate 600
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF64748B), // Slate 500
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  // ========== CHILD MODE THEME ==========
  static ThemeData get childTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Vibrant & Playful
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFEC4899), // Pink 500
        secondary: Color(0xFFF59E0B), // Amber 500
        tertiary: Color(0xFF8B5CF6), // Violet 500
        error: Color(0xFFEF4444), // Red 500
        surface: Color(0xFFFEF3C7), // Amber 100
        onPrimary: Colors.white,
        onSecondary: Color(0xFF78350F), // Amber 900
        onSurface: Color(0xFF78350F),
      ),
      
      // Typography - Friendly & Rounded
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7C2D12), // Orange 900
          letterSpacing: 0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Color(0xFF92400E), // Amber 800
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF78350F),
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF92400E),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFA16207),
        ),
      ),
      
      // Card Theme - Rounded & Elevated
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
        shadowColor: Colors.black26,
      ),
      
      // Input Decoration - Fun & Colorful
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEC4899), width: 4),
        ),
      ),
      
      // Elevated Button - Bold & Playful
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC4899),
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// THEME EXTENSIONS
// ==========================================

class AdultThemeExtension {
  static const Color glucoseHigh = Color(0xFFDC2626); // Red
  static const Color glucoseNormal = Color(0xFF059669); // Green
  static const Color glucoseLow = Color(0xFFF59E0B); // Amber
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color chartPrimary = Color(0xFF2563EB);
  static const Color chartSecondary = Color(0xFF7C3AED);
}

class ChildThemeExtension {
  static const Color questComplete = Color(0xFF10B981); // Emerald
  static const Color questActive = Color(0xFFF59E0B); // Amber
  static const Color questLocked = Color(0xFF9CA3AF); // Gray
  static const Color rewardGold = Color(0xFFFBBF24); // Amber 400
  static const Color rewardSilver = Color(0xFFE5E7EB); // Gray 200
  static const Color rewardBronze = Color(0xFFD97706); // Amber 600
}
