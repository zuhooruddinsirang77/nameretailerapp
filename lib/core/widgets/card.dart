import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'pressable.dart';

enum AppCardTone { surface, sunken, brand, success, warning, danger }

/// Standard container. Flat with a hairline border by default; pass [raised]
/// for a floating card (hero blocks, sticky elements).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.onTap,
    this.tone = AppCardTone.surface,
    this.raised = false,
    this.radius = AppRadius.lg,
    this.semanticLabel,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final AppCardTone tone;
  final bool raised;
  final double radius;
  final String? semanticLabel;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isDark = context.isDark;
    final (Color fill, Color line) = switch (tone) {
      AppCardTone.surface => (p.surface, p.border),
      AppCardTone.sunken => (p.surfaceAlt, p.border),
      AppCardTone.brand => (p.brandSoft, p.brand.withValues(alpha: 0.25)),
      AppCardTone.success => (p.successSoft, p.success.withValues(alpha: 0.3)),
      AppCardTone.warning => (p.warningSoft, p.warning.withValues(alpha: 0.35)),
      AppCardTone.danger => (p.dangerSoft, p.danger.withValues(alpha: 0.3)),
    };
    final br = BorderRadius.circular(radius);

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: br,
        border: Border.all(color: line),
        boxShadow: raised ? AppElevation.medium(isDark) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: br,
        clipBehavior: clip ? Clip.antiAlias : Clip.none,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap != null) {
      card = Pressable(scale: 0.985, onTap: onTap, child: card);
    }
    if (semanticLabel != null) {
      card = Semantics(
        container: true,
        button: onTap != null,
        label: semanticLabel,
        child: card,
      );
    }
    return card;
  }
}
