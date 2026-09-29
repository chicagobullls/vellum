import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vellum Theme System: Victorian Dark Academia meets Apple Scandinavian Minimalism
class VellumTheme {
  // Light Palette: Handmade Parchment
  static const Color parchmentLight = Color(0xFFFBF8F1);
  static const Color parchmentSurface = Color(0xFFF4EFE6);
  static const Color inkPrimary = Color(0xFF1A1816);
  static const Color inkSecondary = Color(0xFF5C554E);
  static const Color inkGhost = Color(0x401A1816); // 25% opacity
  static const Color inkCorrect = Color(0xFF1A1816);
  static const Color inkMistake = Color(0xFFA83232);

  // Dark Academia Palette: Antique Walnut & Night Ink
  static const Color darkWood = Color(0xFF141311);
  static const Color darkSurface = Color(0xFF1D1B18);
  static const Color darkInkGhost = Color(0x35E6DFD5);
  static const Color darkInkPrimary = Color(0xFFEBE5DB);
  static const Color darkInkSecondary = Color(0xFFA0988E);

  // Luxury Accents
  static const Color antiqueGold = Color(0xFFC29B38);
  static const Color antiqueGoldMuted = Color(0x33C29B38);
  static const Color waxCrimson = Color(0xFF842D2D);
  static const Color waxCrimsonGlow = Color(0x4D842D2D);

  /// Typography styles
  static TextStyle get poemTitleStyle => GoogleFonts.ebGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: inkPrimary,
      );

  static TextStyle get poemAuthorStyle => GoogleFonts.ebGaramond(
        fontSize: 16,
        fontStyle: FontStyle.italic,
        letterSpacing: 0.8,
        color: inkSecondary,
      );

  static TextStyle get verseStyle => GoogleFonts.ebGaramond(
        fontSize: 20,
        height: 1.8,
        letterSpacing: 0.2,
      );

  static TextStyle get headerDateStyle => GoogleFonts.cinzel(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 3.0,
        color: antiqueGold,
      );

  static TextStyle get labelStyle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  /// Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: parchmentLight,
      colorScheme: const ColorScheme.light(
        primary: inkPrimary,
        secondary: antiqueGold,
        surface: parchmentSurface,
        error: inkMistake,
      ),
      textTheme: GoogleFonts.ebGaramondTextTheme().apply(
        bodyColor: inkPrimary,
        displayColor: inkPrimary,
      ),
      dividerColor: const Color(0x1F1A1816),
      appBarTheme: const AppBarTheme(
        backgroundColor: parchmentLight,
        elevation: 0,
        iconTheme: IconThemeData(color: inkPrimary),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkWood,
      colorScheme: const ColorScheme.dark(
        primary: darkInkPrimary,
        secondary: antiqueGold,
        surface: darkSurface,
        error: Color(0xFFD64545),
      ),
      textTheme: GoogleFonts.ebGaramondTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkInkPrimary,
        displayColor: darkInkPrimary,
      ),
      dividerColor: const Color(0x1FE6DFD5),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkWood,
        elevation: 0,
        iconTheme: IconThemeData(color: darkInkPrimary),
      ),
    );
  }
}
