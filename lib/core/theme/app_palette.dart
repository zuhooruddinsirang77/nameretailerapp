import 'package:flutter/material.dart';

/// Semantic colour roles for the whole app, resolved per brightness.
///
/// Screens read colours from `context.palette` and never branch on brightness.
/// Text colours were chosen to meet WCAG AA (4.5:1) on the surfaces they are
/// used with.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceRaised,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textSecondary,
    required this.textMuted,
    required this.brand,
    required this.brandText,
    required this.brandSoft,
    required this.onBrand,
    required this.success,
    required this.successText,
    required this.successSoft,
    required this.warning,
    required this.warningText,
    required this.warningSoft,
    required this.danger,
    required this.dangerText,
    required this.dangerSoft,
    required this.info,
    required this.infoText,
    required this.infoSoft,
    required this.price,
    required this.heroStart,
    required this.heroEnd,
    required this.metricDa,
    required this.metricDr,
    required this.metricTraffic,
    required this.metricTrust,
    required this.metricNeutral,
    required this.scrim,
    required this.skeleton,
  });

  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceAlt; // sunken: chips, input wells, table label column
  final Color surfaceRaised; // bars, sheets
  final Color border;
  final Color borderStrong;

  // Text
  final Color text;
  final Color textSecondary;
  final Color textMuted;

  // Brand
  final Color brand; // fills (buttons, indicators)
  final Color brandText; // brand-coloured text/icons on surface
  final Color brandSoft; // tinted backgrounds
  final Color onBrand;

  // Status
  final Color success;
  final Color successText;
  final Color successSoft;
  final Color warning;
  final Color warningText;
  final Color warningSoft;
  final Color danger;
  final Color dangerText;
  final Color dangerSoft;
  final Color info;
  final Color infoText;
  final Color infoSoft;

  /// Money.
  final Color price;

  // Hero gradient (same dark-ink family in both modes; text on it is white).
  final Color heroStart;
  final Color heroEnd;

  // Metrics (text-safe on their soft tint).
  final Color metricDa;
  final Color metricDr;
  final Color metricTraffic;
  final Color metricTrust;
  final Color metricNeutral;

  final Color scrim;
  final Color skeleton;

  static const light = AppPalette(
    background: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F2F6),
    surfaceRaised: Color(0xFFFFFFFF),
    border: Color(0xFFE5E8EF),
    borderStrong: Color(0xFFCDD3DE),
    text: Color(0xFF172238),
    textSecondary: Color(0xFF475469),
    textMuted: Color(0xFF626E80),
    brand: Color(0xFF2563EB),
    brandText: Color(0xFF1D4ED8),
    brandSoft: Color(0xFFE6EEFF),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF059669),
    successText: Color(0xFF047857),
    successSoft: Color(0xFFDDF6EA),
    warning: Color(0xFFD97706),
    warningText: Color(0xFF92400E),
    warningSoft: Color(0xFFFDF0D0),
    danger: Color(0xFFDC2626),
    dangerText: Color(0xFFB91C1C),
    dangerSoft: Color(0xFFFDE4E4),
    info: Color(0xFF2563EB),
    infoText: Color(0xFF1D4ED8),
    infoSoft: Color(0xFFE6EEFF),
    price: Color(0xFF172238),
    heroStart: Color(0xFF14224A),
    heroEnd: Color(0xFF0A1128),
    metricDa: Color(0xFF1D4ED8),
    metricDr: Color(0xFF6D28D9),
    metricTraffic: Color(0xFF047857),
    metricTrust: Color(0xFF0E7490),
    metricNeutral: Color(0xFF475569),
    scrim: Color(0x990B1220),
    skeleton: Color(0xFFE3E8F1),
  );

  static const dark = AppPalette(
    background: Color(0xFF0D1420),
    surface: Color(0xFF172131),
    surfaceAlt: Color(0xFF1D2A3D),
    surfaceRaised: Color(0xFF172131),
    border: Color(0xFF2A3649),
    borderStrong: Color(0xFF43516A),
    text: Color(0xFFF1F5F9),
    textSecondary: Color(0xFFB8C2D4),
    textMuted: Color(0xFF8E9BB2),
    brand: Color(0xFF2F6BF0),
    brandText: Color(0xFF8DB4FF),
    brandSoft: Color(0xFF16254A),
    onBrand: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    successText: Color(0xFF4ADE9F),
    successSoft: Color(0xFF0F2B26),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFFBBF4A),
    warningSoft: Color(0xFF30260F),
    danger: Color(0xFFEF4444),
    dangerText: Color(0xFFFCA5A5),
    dangerSoft: Color(0xFF331519),
    info: Color(0xFF3B82F6),
    infoText: Color(0xFF8DB4FF),
    infoSoft: Color(0xFF16254A),
    price: Color(0xFFF1F5F9),
    heroStart: Color(0xFF16275A),
    heroEnd: Color(0xFF0C142E),
    metricDa: Color(0xFF8DB4FF),
    metricDr: Color(0xFFB9A4FF),
    metricTraffic: Color(0xFF4ADE9F),
    metricTrust: Color(0xFF5EDCF0),
    metricNeutral: Color(0xFFB8C2D4),
    scrim: Color(0xB3000000),
    skeleton: Color(0xFF1B2540),
  );

  /// Soft tint of [c] suitable as a chip/badge background.
  Color tint(Color c, {double light = 0.10, double dark = 0.18}) =>
      c.withValues(alpha: background.computeLuminance() < 0.5 ? dark : light);

  @override
  AppPalette copyWith({Color? brand}) => AppPalette(
    background: background,
    surface: surface,
    surfaceAlt: surfaceAlt,
    surfaceRaised: surfaceRaised,
    border: border,
    borderStrong: borderStrong,
    text: text,
    textSecondary: textSecondary,
    textMuted: textMuted,
    brand: brand ?? this.brand,
    brandText: brandText,
    brandSoft: brandSoft,
    onBrand: onBrand,
    success: success,
    successText: successText,
    successSoft: successSoft,
    warning: warning,
    warningText: warningText,
    warningSoft: warningSoft,
    danger: danger,
    dangerText: dangerText,
    dangerSoft: dangerSoft,
    info: info,
    infoText: infoText,
    infoSoft: infoSoft,
    price: price,
    heroStart: heroStart,
    heroEnd: heroEnd,
    metricDa: metricDa,
    metricDr: metricDr,
    metricTraffic: metricTraffic,
    metricTrust: metricTrust,
    metricNeutral: metricNeutral,
    scrim: scrim,
    skeleton: skeleton,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }

  TextTheme get text => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// True on tablet-width layouts.
  bool get isWide => MediaQuery.sizeOf(this).width >= 600;
}
