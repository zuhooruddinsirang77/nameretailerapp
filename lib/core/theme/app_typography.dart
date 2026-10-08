import 'package:flutter/material.dart';

/// Manrope keeps headings, values and controls consistent with a native UI.
///
/// Minimum size is 11sp. All sizes scale with the system text scaler.
abstract final class AppTypography {
  static const String display = 'Manrope';
  static const String ui = 'Manrope';

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  // Legacy static styles kept for call sites that have not migrated yet.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: display,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: display,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  );
  static const TextStyle titleLarge = TextStyle(
    fontFamily: ui,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: ui,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );
  static const TextStyle titleSmall = TextStyle(
    fontFamily: ui,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: ui,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: ui,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: ui,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: ui,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: ui,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: ui,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  /// Builds the Material [TextTheme] for the given text colours.
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    TextStyle s(
      String family,
      double size,
      FontWeight weight, {
      double? height,
      double? letterSpacing,
      Color? color,
      List<FontFeature>? features,
    }) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? primary,
      fontFeatures: features,
    );

    return TextTheme(
      // Compact display moments; functional screens use the title scale.
      displayLarge: s(
        display,
        32,
        FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.8,
      ),
      displayMedium: s(
        display,
        28,
        FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.6,
      ),
      displaySmall: s(
        display,
        24,
        FontWeight.w800,
        height: 1.25,
        letterSpacing: -0.4,
      ),
      headlineLarge: s(
        display,
        24,
        FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.3,
      ),
      headlineMedium: s(
        display,
        20,
        FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      ),
      headlineSmall: s(ui, 18, FontWeight.w700, height: 1.3),
      // UI titles – sans
      titleLarge: s(ui, 18, FontWeight.w800, height: 1.3, letterSpacing: -0.2),
      titleMedium: s(
        ui,
        15,
        FontWeight.w700,
        height: 1.35,
        letterSpacing: -0.1,
      ),
      titleSmall: s(ui, 14, FontWeight.w700, height: 1.35),
      bodyLarge: s(ui, 16, FontWeight.w500, height: 1.5),
      bodyMedium: s(ui, 14, FontWeight.w500, height: 1.45, color: secondary),
      bodySmall: s(ui, 13, FontWeight.w500, height: 1.45, color: secondary),
      labelLarge: s(ui, 14, FontWeight.w700, height: 1.2),
      labelMedium: s(ui, 12, FontWeight.w700, height: 1.2),
      labelSmall: s(ui, 12, FontWeight.w600, height: 1.3, letterSpacing: 0.2),
    );
  }
}
