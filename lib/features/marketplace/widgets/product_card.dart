import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../models/product.dart';
import 'bookmark_button.dart';

/// Hero tag shared by the catalogue card avatar and the detail header.
String domainHeroTag(String productId) => 'domain-avatar-$productId';

/// Scannable publication card: identity, key metrics, price and actions.
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

  /// Enables the avatar hero transition into the detail screen. Only one card
  /// per product may enable this at a time (the catalogue list does).
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final domain = Formatters.cleanDomain(product.domain);
    final m = product.metrics;
    final hasTraffic = (m.traffic ?? 0) > 0;

    Widget avatar = DomainAvatar(domain: product.domain);
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

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatar,
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain,
                      style: context.text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.category}  ·  ${product.country}',
                      style: context.text.bodySmall?.copyWith(
                        color: p.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              BookmarkButton(product: product),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          MetricStrip(
            metrics: [
              (kind: MetricKind.dr, value: m.dr),
              (kind: MetricKind.da, value: m.da),
              if (hasTraffic) (kind: MetricKind.traffic, value: m.traffic),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: AppSpace.md,
            spacing: AppSpace.md,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  PriceBlock(
                    cents: product.priceCents,
                    label: 'Placement from',
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(product.linkType, style: context.text.bodySmall),
                ],
              ),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppButton(
                    label: 'Details',
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    onPressed: onTap,
                    semanticLabel: 'View details for $domain',
                  ),
                  AppButton(
                    label: 'Plan',
                    trailingIcon: Icons.arrow_forward_rounded,
                    size: AppButtonSize.small,
                    semanticLabel: 'Plan a placement on $domain',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPlan();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
