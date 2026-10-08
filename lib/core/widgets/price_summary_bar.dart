import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';
import 'button.dart';
import 'content_width.dart';

/// Money text that counts to its new value when the amount changes.
class AnimatedPrice extends StatelessWidget {
  const AnimatedPrice({super.key, required this.cents, this.style, this.color});

  final int cents;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = (style ?? context.text.headlineMedium)!.copyWith(
      color: color ?? p.price,
      fontFeatures: AppTypography.tabular,
    );
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: cents),
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.standard,
      builder: (context, value, _) =>
          Text(Formatters.formatCurrency(value), style: base, maxLines: 1),
    );
  }
}

/// Sticky bottom bar: label + live total on the left, primary action on the
/// right. Stacks vertically on very narrow widths or large text.
class PriceSummaryBar extends StatelessWidget {
  const PriceSummaryBar({
    super.key,
    required this.label,
    required this.cents,
    required this.actionLabel,
    required this.onAction,
    this.caption,
    this.actionIcon,
    this.loading = false,
    this.leading,
  });

  final String label;
  final int cents;
  final String? caption;
  final String actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final bool loading;

  /// Optional secondary control placed before the action (e.g. an icon button).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    final price = Semantics(
      container: true,
      label: '$label ${Formatters.formatCurrency(cents)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.text.labelSmall?.copyWith(color: p.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AnimatedPrice(cents: cents),
          if (caption != null)
            Text(
              caption!,
              style: context.text.bodySmall?.copyWith(color: p.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );

    final action = AppButton(
      label: actionLabel,
      icon: actionIcon,
      onPressed: onAction,
      loading: loading,
      size: AppButtonSize.large,
      expand: scale > 1.3,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: AppElevation.bar(context.isDark),
      ),
      child: SafeArea(
        top: false,
        child: ContentWidth(
          maxWidth: AppSpace.maxContentWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.gutter,
              vertical: AppSpace.md,
            ),
            child: LayoutBuilder(
              builder: (context, c) {
                final stack = c.maxWidth < 340 || scale > 1.3;
                if (stack) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      price,
                      const SizedBox(height: AppSpace.md),
                      action,
                    ],
                  );
                }
                return Row(
                  children: [
                    ?leading,
                    if (leading != null) const SizedBox(width: AppSpace.md),
                    Expanded(child: price),
                    const SizedBox(width: AppSpace.md),
                    Flexible(flex: 2, child: action),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
