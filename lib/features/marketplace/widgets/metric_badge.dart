import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';

enum MetricType { da, dr, traffic, tf, ur, backlinks, spam }

class MetricBadge extends StatelessWidget {
  final String label;
  final int? value;
  final MetricType type;
  final bool isCompact;

  const MetricBadge({
    super.key,
    required this.label,
    required this.value,
    this.type = MetricType.dr,
    this.isCompact = false,
  });

  Color _getBadgeColor(BuildContext context) {
    switch (type) {
      case MetricType.da:
        return AppColors.metricDa;
      case MetricType.dr:
        return AppColors.metricDr;
      case MetricType.traffic:
        return AppColors.metricTraffic;
      case MetricType.tf:
        return AppColors.accent;
      case MetricType.ur:
        return AppColors.accentPurple;
      case MetricType.spam:
        return (value ?? 0) > 30 ? AppColors.error : AppColors.success;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 3 : 4.5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: isCompact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            Formatters.formatMetric(value),
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
