import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

/// What a metric means – drives colour and the spoken name.
enum MetricKind {
  da('DA', 'Domain Authority'),
  dr('DR', 'Domain Rating'),
  traffic('Traffic', 'Monthly traffic'),
  tf('TF', 'Trust Flow'),
  ur('UR', 'URL Rating'),
  backlinks('Links', 'Backlinks'),
  refDomains('RD', 'Referring domains'),
  spam('Spam', 'Spam score');

  const MetricKind(this.short, this.spoken);
  final String short;
  final String spoken;

  Color color(AppPalette p, int? value) => switch (this) {
    MetricKind.da => p.metricDa,
    MetricKind.dr => p.metricDr,
    MetricKind.traffic => p.metricTraffic,
    MetricKind.tf => p.metricTrust,
    MetricKind.ur => p.metricDr,
    MetricKind.backlinks || MetricKind.refDomains => p.metricNeutral,
    MetricKind.spam => (value ?? 0) > 30 ? p.dangerText : p.successText,
  };
}

String _spoken(MetricKind kind, int? value, [String? title]) =>
    '${title ?? kind.spoken}: ${value == null ? 'not available' : Formatters.formatMetric(value)}';

/// A quiet, aligned metric well for scanning publications without colour clutter.
class MetricStrip extends StatelessWidget {
  const MetricStrip({super.key, required this.metrics});

  final List<({MetricKind kind, int? value})> metrics;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: AppRadius.brMd,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / (72 * scale)).floor().clamp(
            1,
            metrics.length,
          );
          final width =
              (constraints.maxWidth - AppSpace.md * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpace.md,
            runSpacing: AppSpace.md,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: width,
                  child: Semantics(
                    label: _spoken(metric.kind, metric.value),
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          metric.kind.short,
                          style: context.text.labelMedium?.copyWith(
                            color: p.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          Formatters.formatCompact(metric.value),
                          style: context.text.titleLarge?.copyWith(
                            fontFeatures: AppTypography.tabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Compact "DR 72" style badge for cards and lists.
class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.kind,
    required this.value,
    this.highlight = false,
  });

  final MetricKind kind;
  final int? value;

  /// Emphasises the chip (e.g. best value in a comparison).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = kind.color(p, value);
    return Semantics(
      label: _spoken(kind, value),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: highlight ? p.tint(color, light: 0.16) : p.surfaceAlt,
          borderRadius: AppRadius.brSm,
          border: Border.all(
            color: highlight ? color.withValues(alpha: 0.55) : p.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kind.short,
              style: context.text.labelSmall?.copyWith(
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: AppSpace.xs + 1),
            Text(
              Formatters.formatCompact(value),
              style: context.text.labelMedium?.copyWith(
                color: p.text,
                fontWeight: FontWeight.w800,
                fontFeatures: AppTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neutral label chip (category, country, link type).
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.emphasis = false,
  });

  final String label;
  final IconData? icon;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fg = emphasis ? p.brandText : p.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 5),
      decoration: BoxDecoration(
        color: emphasis ? p.brandSoft : p.surfaceAlt,
        borderRadius: AppRadius.brSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Larger tile used on the detail screen: icon, name and a value with an
/// optional 0–100 gauge.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.kind,
    required this.value,
    this.title,
    this.icon,
    this.gauge = false,
  });

  final MetricKind kind;
  final int? value;
  final String? title;
  final IconData? icon;

  /// Draw a thin 0–100 bar (for DA/DR/TF/UR/spam).
  final bool gauge;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = kind.color(p, value);
    final frac = (value ?? 0).clamp(0, 100) / 100;
    return Semantics(
      label: _spoken(kind, value, title),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    title ?? kind.spoken,
                    style: context.text.labelMedium?.copyWith(
                      color: p.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              Formatters.formatMetric(value),
              style: context.text.headlineMedium?.copyWith(
                color: p.text,
                fontFeatures: AppTypography.tabular,
              ),
            ),
            if (gauge) ...[
              const SizedBox(height: AppSpace.sm),
              ClipRRect(
                borderRadius: AppRadius.brPill,
                child: LinearProgressIndicator(
                  value: value == null ? 0 : frac,
                  minHeight: 4,
                  color: color,
                  backgroundColor: p.surfaceAlt,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
