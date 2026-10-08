import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final double? borderRadius;
  final bool hasShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius ?? AppDimens.radiusLg);
    final cardColor = color ?? (isDark ? AppColors.surfaceDarkCard : Colors.white);
    final borderColor = isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        border: Border.fromBorderSide(
          border ?? BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: hasShadow ? AppDimens.shadowSubtle(isDark) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimens.space16),
            child: child,
          ),
        ),
      ),
    );
  }
}

