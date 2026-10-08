import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/formatters.dart';
import '../models/product.dart';
import '../providers/shortlist_provider.dart';
import 'metric_badge.dart';

class ProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onPlan;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortlist = ref.watch(shortlistProvider);
    final isShortlisted = shortlist.any((p) => p.id == product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cleanDomain = Formatters.cleanDomain(product.domain);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.space12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
        boxShadow: AppDimens.shadowSubtle(isDark),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.space14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Domain Icon + Domain Title + Shortlist Action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        border: Border.all(
                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cleanDomain.isNotEmpty
                            ? cleanDomain.substring(0, 1).toUpperCase()
                            : 'D',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanDomain,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  product.category,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•  ${product.country}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isShortlisted
                            ? AppColors.accentAmber
                            : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.read(shortlistProvider.notifier).toggle(product);
                      },
                      tooltip: isShortlisted ? 'Remove bookmark' : 'Bookmark publication',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metrics Badges Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MetricBadge(
                      label: 'DA',
                      value: product.metrics.da,
                      type: MetricType.da,
                      isCompact: true,
                    ),
                    MetricBadge(
                      label: 'DR',
                      value: product.metrics.dr,
                      type: MetricType.dr,
                      isCompact: true,
                    ),
                    if (product.metrics.traffic != null && product.metrics.traffic! > 0)
                      MetricBadge(
                        label: 'TRAFFIC',
                        value: product.metrics.traffic,
                        type: MetricType.traffic,
                        isCompact: true,
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                        border: Border.all(
                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        product.linkType,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight,
                ),
                const SizedBox(height: 10),

                // Bottom Row: Placement Price + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PLACEMENT FROM',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          Formatters.formatCurrency(product.priceCents),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentEmerald,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 36),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            side: BorderSide(
                              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onPlan();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: const Size(0, 36),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Plan',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
