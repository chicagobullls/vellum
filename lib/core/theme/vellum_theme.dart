import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Vellum Theme System: Typewriter Paper & Soft Minimalism.
/// Ribbon ink typed onto a worn light-beige sheet; controls are plain surfaces with soft shadows.
class VellumTheme {
  /// Bundled typewriter face (TT2020, SIL OFL 1.1): Style E as regular, Style B as bold.
  static const String typewriterFamily = 'TT2020';

  // Typewriter Paper Palette (light beige, default)
  static const Color paperHighlight = Color(0xFFF8F3EA);
  static const Color paperBase = Color(0xFFF0E8DA);
  static const Color paperShade = Color(0xFFE2D5C0);
  static const Color paperSurface = Color(0xFFFCFAF6); // cards and controls lifted off the sheet
  static const Color ink = Color(0xFF231F1A); // ribbon black
  static const Color inkSecondary = Color(0xFF6E6555); // faded ribbon
  static const Color inkGhost = Color(0x38231F1A); // ribbon ink @ 22%
  static const Color inkRed = Color(0xFFA3362B); // red half of a bichrome ribbon, errors only
  static const Color hairline = Color(0x26231F1A); // 1px rules and tracks

  // Carbon Copy Palette (dark)
  static const Color carbonHighlight = Color(0xFF2F323A);
  static const Color carbonBase = Color(0xFF23252C);
  static const Color carbonDeep = Color(0xFF16171C);
  static const Color carbonInk = Color(0xFFE8E3D6);
  static const Color carbonInkSecondary = Color(0xFFA29C8F);
  static const Color carbonGhost = Color(0x38E8E3D6); // carbon ink @ 22%

  /// Soft, warm shadow of a paper card: a tight contact shade plus a wide ambient falloff.
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F3D2E1C), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A3D2E1C), blurRadius: 22, offset: Offset(0, 8)),
  ];

  /// Soft shadow under solid ink surfaces.
  static const List<BoxShadow> softShadowInk = [
    BoxShadow(color: Color(0x1F231F1A), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x33231F1A), blurRadius: 20, offset: Offset(0, 8)),
  ];

  /// Folio book spine: a strip of ribbon-black binding cloth.
  static const LinearGradient inkSpine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A433A), ink, Color(0xFF3A342D)],
  );

  /// Ribbon ink soaking slightly into the paper fibres around each glyph.
  static const List<Shadow> inkBleed = [
    Shadow(color: Color(0x4D231F1A), blurRadius: 0.8),
  ];

  /// Ink bleed for light glyphs on carbon paper.
  static const List<Shadow> inkBleedLight = [
    Shadow(color: Color(0x40E8E3D6), blurRadius: 0.8),
  ];

  /// Typography styles
  static const TextStyle poemTitleStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    height: 1.3,
    color: ink,
    shadows: inkBleed,
  );

  static const TextStyle poemAuthorStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 13,
    letterSpacing: 1.2,
    color: inkSecondary,
  );

  static const TextStyle verseStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 17,
    height: 1.75,
  );

  static const TextStyle headerDateStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 12,
    letterSpacing: 3.0,
    color: ink,
  );

  static const TextStyle labelStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 11,
    letterSpacing: 1.5,
    color: inkSecondary,
  );

  /// Uppercase micro-caption for section headers and badges.
  static const TextStyle captionStyle = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 10,
    letterSpacing: 2.5,
    color: inkSecondary,
  );

  /// Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: typewriterFamily,
      scaffoldBackgroundColor: paperBase,
      colorScheme: const ColorScheme.light(
        primary: ink,
        onPrimary: paperHighlight,
        secondary: inkSecondary,
        onSecondary: paperHighlight,
        surface: paperHighlight,
        onSurface: ink,
        error: inkRed,
        outline: hairline,
        surfaceTint: Colors.transparent,
      ),
      dividerColor: hairline,
      iconTheme: const IconThemeData(color: ink, size: 22),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: ink,
        iconTheme: IconThemeData(color: ink, size: 22),
        titleTextStyle: headerDateStyle,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ink,
        linearTrackColor: hairline,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: ink,
        titleTextStyle: TextStyle(fontFamily: typewriterFamily, fontSize: 14, color: ink),
        subtitleTextStyle: TextStyle(
          fontFamily: typewriterFamily,
          fontSize: 11,
          height: 1.4,
          color: inkSecondary,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(paperHighlight),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? ink : paperShade,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: inkSecondary,
          textStyle: const TextStyle(fontFamily: typewriterFamily, fontSize: 11, letterSpacing: 1.0),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(
          fontFamily: typewriterFamily,
          fontSize: 12,
          letterSpacing: 0.5,
          color: paperHighlight,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: ink,
        selectionColor: Color(0x33231F1A),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.all(Radius.circular(8))),
        textStyle: TextStyle(fontFamily: typewriterFamily, fontSize: 11, color: paperHighlight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: typewriterFamily,
      scaffoldBackgroundColor: carbonBase,
      colorScheme: const ColorScheme.dark(
        primary: carbonInk,
        onPrimary: carbonDeep,
        secondary: carbonInkSecondary,
        surface: carbonBase,
        onSurface: carbonInk,
        error: Color(0xFFD06A5E),
        outline: Color(0x26E8E3D6),
        surfaceTint: Colors.transparent,
      ),
      dividerColor: const Color(0x26E8E3D6),
      iconTheme: const IconThemeData(color: carbonInk, size: 22),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: carbonInk,
        iconTheme: IconThemeData(color: carbonInk, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: typewriterFamily,
          fontSize: 12,
          letterSpacing: 3.0,
          color: carbonInk,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
