import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../models/product.dart';
import 'bookmark_button.dart';

String domainHeroTag(String productId) => 'domain-avatar-$productId';

/// Compact artwork, identity, metrics and price with separate save/plan targets.
/// Large text uses a stacked layout so all information stays available.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onPlan,
    this.heroEnabled = false,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onPlan;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final domain = Formatters.cleanDomain(product.domain);
    final m = product.metrics;
    Widget avatar = DomainAvatar(domain: product.domain, size: 68);
    if (heroEnabled) {
      avatar = Hero(
        tag: domainHeroTag(product.id),
        flightShuttleBuilder: (_, _, _, _, toContext) => Material(
          type: MaterialType.transparency,
          child: (toContext.widget as Hero).child,
        ),
        child: avatar,
      );
    }

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          domain,
          style: context.text.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          '${product.category} · ${product.country}',
          style: context.text.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpace.xs),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.xs,
          children: [
            if (m.dr != null) _MetricLabel(label: 'DR', value: '${m.dr}'),
            if (m.da != null) _MetricLabel(label: 'DA', value: '${m.da}'),
            if ((m.traffic ?? 0) > 0)
              _MetricLabel(
                label: 'Traffic',
                value: Formatters.formatCompact(m.traffic),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'From ${Formatters.formatCurrency(product.priceCents)}',
          style: context.text.titleMedium?.copyWith(
            color: p.price,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );

    final plan = IconButton.filled(
      tooltip: 'Plan a placement on $domain',
      onPressed: () {
        HapticFeedback.lightImpact();
        onPlan();
      },
      style: IconButton.styleFrom(
        backgroundColor: p.brand,
        foregroundColor: p.onBrand,
        minimumSize: const Size.square(AppSpace.minTarget),
        shape: const CircleBorder(),
      ),
      icon: const Icon(Icons.add_shopping_cart_rounded, size: 21),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.md),
      radius: AppRadius.lg,
      raised: true,
      onTap: onTap,
      semanticLabel: 'View $domain',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final large =
              MediaQuery.textScalerOf(context).scale(1) > 1.4 ||
              constraints.maxWidth < 260;
          if (large) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    avatar,
                    const Spacer(),
                    BookmarkButton(product: product),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                identity,
                const SizedBox(height: AppSpace.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.linkType,
                        style: context.text.bodySmall,
                      ),
                    ),
                    plan,
                  ],
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: AppSpace.md),
              Expanded(child: identity),
              const SizedBox(width: AppSpace.xs),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BookmarkButton(product: product),
                  plan,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        TextSpan(
          text: '$label ',
          style: TextStyle(color: context.palette.textMuted),
        ),
        TextSpan(
          text: value,
          style: TextStyle(
            color: context.palette.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
    style: context.text.labelSmall?.copyWith(fontSize: 11),
  );
}
