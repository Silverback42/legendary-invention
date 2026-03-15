import 'package:flutter/material.dart';

/// Clean-Modern design system for Schlicht.
/// Single light theme (Phase 1). Dark mode added in Phase 1.5.
///
/// Design principles:
/// - Max 2 accent colors
/// - Generous whitespace
/// - WCAG 2.1 AA compliant (4.5:1 contrast, 44×44px touch targets)
class AppTheme {
  AppTheme._();

  // --- Palette ---
  static const Color _primary = Color(0xFF1A1A2E);     // Deep navy
  static const Color _accent = Color(0xFF4CAF82);      // Soft green (positive, money-growth)
  static const Color _surface = Color(0xFFFAFAFA);
  static const Color _background = Color(0xFFFFFFFF);
  static const Color _onBackground = Color(0xFF1A1A2E);
  static const Color _onSurface = Color(0xFF2D2D44);
  static const Color _subtle = Color(0xFF8A8AA8);
  static const Color _divider = Color(0xFFEEEEF4);

  // Budget status colors
  static const Color budgetOk = Color(0xFF4CAF82);
  static const Color budgetWarning = Color(0xFFFF9800);   // 80%+ used
  static const Color budgetOver = Color(0xFFE57373);      // 100%+ used (soft, not aggressive)

  // --- Typography ---
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: _onBackground,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: _onBackground,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _onBackground,
    ),
    titleLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: _onBackground,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: _onBackground,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onBackground,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _subtle,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  );

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      primary: _primary,
      secondary: _accent,
      surface: _surface,
      background: _background,
      onBackground: _onBackground,
      onSurface: _onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: _background,
      dividerColor: _divider,

      // App bar: clean, no elevation
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: _onBackground,
        ),
      ),

      // Cards: minimal shadow, rounded
      cardTheme: CardTheme(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _divider),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // Buttons: 44px min height (WCAG touch target)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          minimumSize: const Size(44, 44),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _background,
        indicatorColor: _accent.withOpacity(0.15),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: _primary, size: 24);
          }
          return const IconThemeData(color: _subtle, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _subtle,
          );
        }),
        elevation: 0,
        height: 72,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        selectedColor: _primary.withOpacity(0.1),
        side: const BorderSide(color: _divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accent,
        linearTrackColor: _divider,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _primary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
