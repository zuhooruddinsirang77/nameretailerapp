import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../marketplace/models/product.dart';
import '../../marketplace/widgets/bookmark_button.dart';

/// Compact featured publication with the same hierarchy as the catalogue.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onPlan,
    this.width = 296,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onPlan;
  final double width;

  @override
  Widget build(BuildContext context) {
    final domain = Formatters.cleanDomain(product.domain);
    final m = product.metrics;
    return SizedBox(
      width: width.clamp(
        0,
        MediaQuery.sizeOf(context).width - AppSpace.gutter * 2,
      ),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DomainAvatar(domain: product.domain, size: 40),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    domain,
                    style: context.text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                BookmarkButton(product: product),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              '${product.category} · ${product.country}',
              style: context.text.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpace.lg),
            MetricStrip(
              metrics: [
                (kind: MetricKind.dr, value: m.dr),
                (kind: MetricKind.da, value: m.da),
                if ((m.traffic ?? 0) > 0)
                  (kind: MetricKind.traffic, value: m.traffic),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: AppSpace.sm,
              spacing: AppSpace.sm,
              children: [
                PriceBlock(cents: product.priceCents, label: 'From'),
                AppButton(
                  label: 'Plan',
                  size: AppButtonSize.small,
                  trailingIcon: Icons.arrow_forward_rounded,
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
      ),
    );
  }
}

/// Loading placeholder matching [FeaturedCard].
class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key, this.width = 296});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.clamp(
        0,
        MediaQuery.sizeOf(context).width - AppSpace.gutter * 2,
      ),
      child: const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SkeletonBox(width: 40, height: 40, radius: AppRadius.md),
                SizedBox(width: AppSpace.md),
                Expanded(child: SkeletonBox(height: 16)),
              ],
            ),
            SizedBox(height: AppSpace.sm),
            SkeletonBox(height: 16),
            SizedBox(height: AppSpace.lg),
            SkeletonBox(height: 68, radius: AppRadius.md),
            SizedBox(height: AppSpace.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 80, height: 24),
                SkeletonBox(width: 80, height: 48, radius: AppRadius.md),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
