import 'package:flutter/material.dart';

class CashlyColors {
  // Background
  static const background = Color(0xFF0B0B12);
  static const surface = Color(0xFF111117);
  static const surfaceElevated = Color(0xFF16161F);

  // Primary - vibrant violet
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFF9F6EF5);
  static const primaryGlow = Color(0xFFB47EFF);

  // Accent - magenta
  static const accent = Color(0xFFD946EF);
  static const accentLight = Color(0xFFE879F9);

  // Text
  static const foreground = Color(0xFFF5F5FA);
  static const mutedForeground = Color(0xFF9494A8);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  // Border
  static const border = Color(0xFF252535);
  static const inputBorder = Color(0xFF1E1E2C);

  // Gradients
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFD946EF)],
  );

  static const gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF7E22CE), Color(0xFFA21CAF)],
    stops: [0.0, 0.5, 1.0],
  );

  static const gradientSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF13131C), Color(0xFF0E0E16)],
  );
}

class CashlyTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CashlyColors.background,
      colorScheme: const ColorScheme.dark(
        background: CashlyColors.background,
        surface: CashlyColors.surface,
        primary: CashlyColors.primary,
        secondary: CashlyColors.accent,
        onPrimary: Colors.white,
        onSurface: CashlyColors.foreground,
        error: CashlyColors.danger,
        outline: CashlyColors.border,
      ),
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800,
          color: CashlyColors.foreground, letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700,
          color: CashlyColors.foreground, letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: CashlyColors.foreground,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: CashlyColors.foreground,
        ),
        titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600,
          color: CashlyColors.foreground,
        ),
        titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: CashlyColors.foreground,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: CashlyColors.foreground),
        bodyMedium: TextStyle(fontSize: 13, color: CashlyColors.foreground),
        bodySmall: TextStyle(fontSize: 11, color: CashlyColors.mutedForeground),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: CashlyColors.foreground,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CashlyColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: CashlyColors.foreground,
          fontSize: 18, fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: CashlyColors.foreground),
      ),
      cardTheme: CardThemeData(
        color: CashlyColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CashlyColors.border, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CashlyColors.inputBorder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CashlyColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CashlyColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CashlyColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: CashlyColors.mutedForeground),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CashlyColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CashlyColors.surface,
        indicatorColor: CashlyColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: CashlyColors.primaryLight,
            );
          }
          return const TextStyle(
            fontSize: 11, color: CashlyColors.mutedForeground,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: CashlyColors.primaryLight, size: 22);
          }
          return const IconThemeData(color: CashlyColors.mutedForeground, size: 22);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: CashlyColors.border,
        thickness: 0.8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CashlyColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
