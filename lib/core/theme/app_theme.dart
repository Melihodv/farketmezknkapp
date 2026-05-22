import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ──────────────────────────────────────────────────────────
  // "Aurora Light" — Açık, Premium, Genç Nesle Özel
  // Violet × Pink imza paleti | Plus Jakarta Sans font
  // ──────────────────────────────────────────────────────────

  // Backgrounds
  static const Color background      = Color(0xFFF8F7FE); // lavander tint beyaz
  static const Color surface         = Color(0xFFFFFFFF); // saf beyaz
  static const Color surfaceElevated = Color(0xFFF0EEFF); // hafif violet tint
  static const Color card            = Color(0xFFFAFAFF); // barely-there lavander

  // Accent — Vibrant Violet (imza rengi)
  static const Color accent          = Color(0xFF7C3AED); // rich violet
  static const Color accentLight     = Color(0xFFA78BFA); // soft violet
  static const Color accentGlow      = Color(0xFFEDE9FE); // violet bg tint
  static const Color accentAmber     = Color(0xFFF59E0B); // amber/star
  static const Color accentRose      = Color(0xFFEC4899); // hot pink (gradient ucu)
  static const Color accentMint      = Color(0xFF10B981); // mint yeşil (success)

  // Text
  static const Color textPrimary     = Color(0xFF1A1033); // derin indigo siyah
  static const Color textSecondary   = Color(0xFF4B5563); // slate gri
  static const Color textTertiary    = Color(0xFF9CA3AF); // açık gri

  // Borders
  static const Color cardBorder      = Color(0xFFE8E4FF); // hafif violet border
  static const Color divider         = Color(0xFFF0EEFF);

  // Status
  static const Color success         = Color(0xFF10B981);
  static const Color error           = Color(0xFFEF4444);
  static const Color warning         = Color(0xFFF59E0B);

  // ── İmza Gradient: Violet → Pink ─────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F7FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF8F7FE), Color(0xFFEDE9FE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Shadows ───────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> get accentShadow => [
    BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.40), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get smallShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
  ];

  // ── Theme ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentRose,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge:  GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -1.0),
        displayMedium: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.6),
        titleLarge:    GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium:   GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge:     GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary),
        bodyMedium:    GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge:    GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
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
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
