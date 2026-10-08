import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../models/product.dart';

enum _Best { none, highest, lowest }

class _Row {
  const _Row(this.label, this.value, {this.best = _Best.none, this.numeric});

  final String label;
  final String Function(Product) value;
  final _Best best;

  /// Numeric extractor used to find the best value. Null values are ignored.
  final num? Function(Product)? numeric;
}

/// Side-by-side comparison. The label column stays pinned while the product
/// columns scroll horizontally, so it works on 360dp phones. The best value in
/// each numeric row is highlighted (with a check icon, not colour alone).
class CompareTable extends StatelessWidget {
  const CompareTable({
    super.key,
    required this.products,
    required this.onRemove,
    required this.onOpen,
  });

  final List<Product> products;
  final ValueChanged<Product> onRemove;
  final ValueChanged<Product> onOpen;

  static const double _labelWidth = 104;
  static const double _colWidth = 148;

  static final List<_Row> _rows = [
    _Row(
      'Price',
      (p) => Formatters.formatCurrency(p.priceCents),
      best: _Best.lowest,
      numeric: (p) => p.priceCents,
    ),
    _Row(
      'Domain Rating',
      (p) => Formatters.formatMetric(p.metrics.dr),
      best: _Best.highest,
      numeric: (p) => p.metrics.dr,
    ),
    _Row(
      'Domain Authority',
      (p) => Formatters.formatMetric(p.metrics.da),
      best: _Best.highest,
      numeric: (p) => p.metrics.da,
    ),
    _Row(
      'Trust Flow',
      (p) => Formatters.formatMetric(p.metrics.tf),
      best: _Best.highest,
      numeric: (p) => p.metrics.tf,
    ),
    _Row(
      'Monthly traffic',
      (p) => Formatters.formatMetric(p.metrics.traffic),
      best: _Best.highest,
      numeric: (p) => p.metrics.traffic,
    ),
    _Row(
      'Referring domains',
      (p) => Formatters.formatMetric(p.metrics.referringDomains),
      best: _Best.highest,
      numeric: (p) => p.metrics.referringDomains,
    ),
    _Row(
      'Spam score',
      (p) => Formatters.formatMetric(p.metrics.spamScore),
      best: _Best.lowest,
      numeric: (p) => p.metrics.spamScore,
    ),
    _Row('Topic', (p) => p.category),
    _Row('Country', (p) => p.country),
    _Row('Link type', (p) => p.linkType),
    _Row('Turnaround', (p) => p.turnaround),
  ];

  /// Indices of products holding the best value for [row], or empty when there
  /// is nothing meaningful to highlight (single value or all equal).
  Set<int> _bestIndices(_Row row) {
    if (row.best == _Best.none || row.numeric == null) return const {};
    final values = <int, num>{};
    for (var i = 0; i < products.length; i++) {
      final v = row.numeric!(products[i]);
      if (v != null) values[i] = v;
    }
    if (values.length < 2) return const {};
    final target = row.best == _Best.highest
        ? values.values.reduce((a, b) => a > b ? a : b)
        : values.values.reduce((a, b) => a < b ? a : b);
    final winners = {
      for (final e in values.entries)
        if (e.value == target) e.key,
    };
    return winners.length == values.length ? const {} : winners;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final scaler = MediaQuery.textScalerOf(context);
    final rowHeight = scaler.scale(52).clamp(56.0, 160.0);
    final headerHeight = scaler.scale(112).clamp(112.0, 320.0);
    final best = [for (final r in _rows) _bestIndices(r)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: AppRadius.brLg,
          border: Border.all(color: p.border),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.brLg,
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pinned label column
                Container(
                  width: _labelWidth,
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    border: Border(right: BorderSide(color: p.border)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: headerHeight),
                      for (final r in _rows)
                        _LabelCell(label: r.label, height: rowHeight),
                    ],
                  ),
                ),
                // Scrolling product columns
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < products.length; i++)
                          SizedBox(
                            width: _colWidth,
                            child: Column(
                              children: [
                                _HeaderCell(
                                  product: products[i],
                                  height: headerHeight,
                                  onRemove: () => onRemove(products[i]),
                                  onOpen: () => onOpen(products[i]),
                                ),
                                for (var r = 0; r < _rows.length; r++)
                                  _ValueCell(
                                    label: _rows[r].label,
                                    domain: Formatters.cleanDomain(
                                      products[i].domain,
                                    ),
                                    text: _rows[r].value(products[i]),
                                    isBest: best[r].contains(i),
                                    height: rowHeight,
                                    strong: _rows[r].best != _Best.none,
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelCell extends StatelessWidget {
  const _LabelCell({required this.label, required this.height});

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(color: p.textSecondary),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.product,
    required this.height,
    required this.onRemove,
    required this.onOpen,
  });

  final Product product;
  final double height;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final domain = Formatters.cleanDomain(product.domain);
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: onOpen,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.md,
                  AppSpace.md,
                  AppSpace.md,
                  AppSpace.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DomainAvatar(domain: product.domain, size: 36),
                    const SizedBox(height: AppSpace.sm),
                    Expanded(
                      child: Text(
                        domain,
                        style: context.text.titleSmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove $domain from shortlist',
              iconSize: 18,
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                HapticFeedback.lightImpact();
                onRemove();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  const _ValueCell({
    required this.label,
    required this.domain,
    required this.text,
    required this.isBest,
    required this.height,
    required this.strong,
  });

  final String label;
  final String domain;
  final String text;
  final bool isBest;
  final double height;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: '$label for $domain: $text${isBest ? ', best value' : ''}',
      excludeSemantics: true,
      child: Container(
        height: height,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        decoration: BoxDecoration(
          color: isBest ? p.successSoft : null,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: Row(
          children: [
            Flexible(
              child: Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style:
                    (strong ? context.text.titleSmall : context.text.bodySmall)
                        ?.copyWith(
                          color: isBest ? p.successText : p.text,
                          fontWeight: isBest ? FontWeight.w800 : null,
                          fontFeatures: AppTypography.tabular,
                        ),
              ),
            ),
            if (isBest) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle_rounded, size: 16, color: p.successText),
            ],
          ],
        ),
      ),
    );
  }
}
