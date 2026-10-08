import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

/// Icon with a count badge (99+ cap). The count is spoken with the label.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    required this.child,
    this.semanticLabel,
  });

  final int count;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Badge(
      isLabelVisible: count > 0,
      label: Text(label, semanticsLabel: semanticLabel ?? '$count items'),
      child: child,
    );
  }
}

/// "FROM  $88.00" style stacked price used on cards.
class PriceBlock extends StatelessWidget {
  const PriceBlock({
    super.key,
    required this.cents,
    this.label,
    this.large = false,
  });

  final int? cents;
  final String? label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = large ? context.text.displaySmall : context.text.headlineMedium;
    return Semantics(
      label: '${label ?? 'Price'} ${Formatters.formatCurrency(cents)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null)
            Text(
              label!.toUpperCase(),
              style: context.text.labelSmall
                  ?.copyWith(color: p.textMuted, letterSpacing: 0.8),
            ),
          Text(
            Formatters.formatCurrency(cents),
            style: style?.copyWith(
              color: p.price,
              fontFeatures: AppTypography.tabular,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right; wraps cleanly with large text.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasis;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final labelStyle = emphasis
        ? context.text.titleSmall
        : context.text.bodyMedium?.copyWith(color: p.textSecondary);
    final valueStyle = (emphasis
            ? context.text.headlineMedium
            : context.text.titleSmall)
        ?.copyWith(
      color: valueColor ?? (emphasis ? p.price : p.text),
      fontFeatures: AppTypography.tabular,
    );
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          const SizedBox(width: AppSpace.md),
          Flexible(
            child: Text(value, style: valueStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

/// Fades and lifts [child] in once. Skipped under reduced-motion.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 12,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    final total = AppMotion.slow + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1, curve: AppMotion.standard),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * offset), child: child),
      ),
      child: child,
    );
  }
}
