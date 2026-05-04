import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──────────────────────────────────────────────
  static const Color background    = Color(0xFFF7F5F2);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color card          = Color(0xFFF2F0ED);

  static const Color accent        = Color(0xFFFF4500);
  static const Color accentLight   = Color(0xFFFF7043);
  static const Color accentGlow    = Color(0xFFFFF0EB);
  static const Color accentAmber   = Color(0xFFFF8C00);

  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary  = Color(0xFF94A3B8);

  static const Color cardBorder    = Color(0xFFEDE9E4);
  static const Color divider       = Color(0xFFF1EDE8);

  static const Color success       = Color(0xFF16A34A);
  static const Color error         = Color(0xFFDC2626);
  static const Color warning       = Color(0xFFD97706);

  // ── Gradients ─────────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF8F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF7F5F2), Color(0xFFFFEFE8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadows ───────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 4), spreadRadius: 0),
    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(color: const Color(0xFFFF4500).withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8), spreadRadius: 0),
  ];

  static List<BoxShadow> get smallShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
  ];

  // ── Theme ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentLight,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1),
        displayMedium: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
        titleLarge: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
        bodyMedium: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.outfit(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Keep darkTheme alias for compatibility
  static ThemeData get darkTheme => lightTheme;
}
