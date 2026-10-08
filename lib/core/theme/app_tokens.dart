import 'package:flutter/material.dart';

/// 4/8pt spacing scale. Use these instead of literals.
abstract final class AppSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double huge = 48;

  /// Horizontal page gutter.
  static const double gutter = 20;

  /// Minimum interactive size (Material / WCAG target size guidance).
  static const double minTarget = 48;

  /// Max content width on tablets; content is centred beyond this.
  static const double maxContentWidth = 720;
}

abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Elevation tokens expressed as shadows (flat surfaces use borders instead).
abstract final class AppElevation {
  static List<BoxShadow> none() => const [];

  static List<BoxShadow> low(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> medium(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.07),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> high(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.14),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Shadow cast upwards by bars pinned to the bottom edge.
  static List<BoxShadow> bar(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];
}

/// Motion tokens. Always resolve durations through [AppMotion.of] so the
/// "remove animations" accessibility setting is honoured.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;
  static const Curve spring = Curves.easeOutBack;

  /// Returns [Duration.zero] when the platform asks for reduced motion.
  static Duration of(BuildContext context, [Duration d = base]) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}
