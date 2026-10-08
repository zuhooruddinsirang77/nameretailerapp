import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, subtle, danger }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    EdgeInsets padding;
    double fontSize;
    double iconSize;
    double height;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        fontSize = 12;
        iconSize = 14;
        height = 34;
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        fontSize = 13.5;
        iconSize = 16;
        height = 44;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
        fontSize = 15;
        iconSize = 18;
        height = 50;
        break;
    }

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bgColor = isDark ? AppColors.surfaceDarkCard : AppColors.dividerLight;
        fgColor = isDark ? Colors.white : AppColors.textPrimaryLight;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = isDark ? Colors.white : AppColors.textPrimaryLight;
        borderSide = BorderSide(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1.2,
        );
        break;
      case AppButtonVariant.subtle:
        bgColor = isDark
            ? AppColors.accent.withValues(alpha: 0.15)
            : AppColors.accent.withValues(alpha: 0.08);
        fgColor = AppColors.accent;
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = Colors.white;
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTypography.labelLarge.copyWith(
            color: fgColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: onPressed == null ? bgColor.withValues(alpha: 0.5) : bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

