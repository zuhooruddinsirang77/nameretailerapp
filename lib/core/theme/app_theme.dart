import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from [AppPalette] so both modes share
/// one definition.
class AppTheme {
  static ThemeData get lightTheme => _build(AppPalette.light, Brightness.light);
  static ThemeData get darkTheme => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme(
      primary: p.text,
      secondary: p.textSecondary,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.brand,
      onPrimary: p.onBrand,
      primaryContainer: p.brandSoft,
      onPrimaryContainer: p.brandText,
      secondary: p.success,
      onSecondary: Colors.white,
      tertiary: p.warning,
      onTertiary: Colors.white,
      error: p.danger,
      onError: Colors.white,
      errorContainer: p.dangerSoft,
      onErrorContainer: p.dangerText,
      surface: p.surface,
      onSurface: p.text,
      onSurfaceVariant: p.textSecondary,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceRaised,
      surfaceContainerHighest: p.surfaceAlt,
      outline: p.borderStrong,
      outlineVariant: p.border,
      scrim: p.scrim,
      shadow: Colors.black,
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.brMd,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: AppTypography.ui,
      scaffoldBackgroundColor: p.background,
      extensions: [p],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
      dividerColor: p.border,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: AppSpace.gutter,
        toolbarHeight: 60,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: p.text),
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: p.border.withValues(alpha: 0))),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brLg,
          side: BorderSide(color: p.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.onBrand,
          minimumSize: const Size(64, AppSpace.minTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.onBrand,
          elevation: 0,
          minimumSize: const Size(64, AppSpace.minTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: const Size(64, AppSpace.minTarget),
          side: BorderSide(color: p.borderStrong),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.brandText,
          minimumSize: const Size(64, AppSpace.minTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSpace.minTarget, AppSpace.minTarget),
          foregroundColor: p.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: 14,
        ),
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(p.brand, 2),
        errorBorder: inputBorder(p.danger),
        focusedErrorBorder: inputBorder(p.danger, 2),
        disabledBorder: inputBorder(p.border),
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.textMuted),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(color: p.brandText),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.textMuted),
        helperStyle: textTheme.bodySmall?.copyWith(color: p.textMuted),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: p.dangerText,
          fontWeight: FontWeight.w600,
        ),
        errorMaxLines: 3,
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.brandSoft,
        side: BorderSide(color: p.borderStrong),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.brand,
        inactiveTrackColor: p.surfaceAlt,
        thumbColor: p.brand,
        overlayColor: p.brand.withValues(alpha: 0.12),
        trackHeight: 4,
        valueIndicatorColor: p.brand,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: p.onBrand,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onBrand : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.brand : p.surfaceAlt,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 24,
            color: s.contains(WidgetState.selected) ? p.brandText : p.textMuted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => textTheme.labelSmall?.copyWith(
            letterSpacing: 0.1,
            color: s.contains(WidgetState.selected) ? p.brandText : p.textMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: p.surfaceRaised,
        indicatorColor: p.brandSoft,
        selectedIconTheme: IconThemeData(color: p.brandText),
        unselectedIconTheme: IconThemeData(color: p.textMuted),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: p.brandText,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: p.textMuted,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surfaceRaised,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brXl),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: p.surface,
          foregroundColor: p.textSecondary,
          selectedBackgroundColor: p.brandSoft,
          selectedForegroundColor: p.brandText,
          side: BorderSide(color: p.border),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: p.brandText,
        collapsedIconColor: p.textMuted,
        expansionAnimationStyle: const AnimationStyle(duration: AppMotion.base),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.surfaceRaised : p.text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? p.text : p.background,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: isDark ? p.brandText : const Color(0xFF9DBCFF),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.text,
        minVerticalPadding: AppSpace.sm,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.brand,
        linearTrackColor: p.surfaceAlt,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? p.surfaceRaised : p.text,
          borderRadius: AppRadius.brSm,
        ),
        textStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? p.text : p.background,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.brand,
        selectionColor: p.brand.withValues(alpha: 0.25),
        selectionHandleColor: p.brand,
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: p.brand,
        textColor: p.onBrand,
        textStyle: textTheme.labelSmall?.copyWith(letterSpacing: 0),
      ),
    );
  }
}
