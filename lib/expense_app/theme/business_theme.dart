import 'package:flutter/material.dart';

class BusinessTheme {
  // Professional business color palette
  static const Color primaryNavy = Color(0xFF1B365D);
  static const Color primaryBlue = Color(0xFF2E5D8A);
  static const Color lightBlue = Color(0xFF4A90C2);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color warningAmber = Color(0xFFF39C12);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textMedium = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  static const Color borderLight = Color(0xFFE6E6E6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: lightBlue,
        surface: cardWhite,
        background: backgroundGray,
        error: errorRed,
        onPrimary: cardWhite,
        onSecondary: cardWhite,
        onSurface: textDark,
        onBackground: textDark,
        onError: cardWhite,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: cardWhite,
        elevation: 2,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cardWhite,
        ),
        iconTheme: IconThemeData(color: cardWhite),
        actionsIconTheme: IconThemeData(color: cardWhite),
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: cardWhite,
        unselectedLabelColor: Colors.white70,
        indicatorColor: cardWhite,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: cardWhite,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryNavy,
        unselectedItemColor: textMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGreen,
        foregroundColor: cardWhite,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMedium,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
      ),

      // Scaffold Background
      scaffoldBackgroundColor: backgroundGray,
    );
  }

  // Status colors
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return accentGreen;
      case 'pending':
        return warningAmber;
      case 'rejected':
        return errorRed;
      default:
        return textMedium;
    }
  }

  // Category colors
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return const Color(0xFF3498DB);
      case 'transportation':
        return const Color(0xFF9B59B6);
      case 'office':
        return const Color(0xFF1ABC9C);
      case 'travel':
        return const Color(0xFFF39C12);
      case 'equipment':
        return const Color(0xFFE67E22);
      case 'software':
        return const Color(0xFF2ECC71);
      case 'training':
        return const Color(0xFFE74C3C);
      case 'marketing':
        return const Color(0xFF34495E);
      default:
        return textMedium;
    }
  }

  // Category icons
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'office':
        return Icons.business;
      case 'travel':
        return Icons.flight;
      case 'equipment':
        return Icons.devices;
      case 'software':
        return Icons.computer;
      case 'training':
        return Icons.school;
      case 'marketing':
        return Icons.campaign;
      default:
        return Icons.attach_money;
    }
  }
}