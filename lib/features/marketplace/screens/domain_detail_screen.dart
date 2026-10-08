import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../models/placement_options.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/shortlist_provider.dart';

class DomainDetailScreen extends ConsumerWidget {
  final String productId;

  const DomainDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(productId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publication Overview'),
        actions: [
          detailAsync.whenOrNull(
            data: (data) {
              final product = data['product'] as Product;
              final shortlist = ref.watch(shortlistProvider);
              final isShortlisted = shortlist.any((p) => p.id == product.id);
              return IconButton(
                icon: Icon(
                  isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isShortlisted ? AppColors.accentAmber : null,
                ),
                tooltip: isShortlisted ? 'Remove bookmark' : 'Bookmark publication',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(shortlistProvider.notifier).toggle(product);
                },
              );
            },
          ) ?? const SizedBox.shrink(),
          const SizedBox(width: 4),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Fetching publication metrics…'),
            ],
          ),
        ),
        error: (err, _) => AppEmptyState(
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.error,
          title: 'Unable to Load Publication',
          description: err.toString(),
          actionText: 'Retry',
          onActionTap: () => ref.refresh(productDetailProvider(productId)),
        ),
        data: (data) {
          final product = data['product'] as Product;
          final options = data['options'] as PlacementOptions?;
          final cleanDomain = Formatters.cleanDomain(product.domain);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Hero Domain Card
                      Container(
                        padding: const EdgeInsets.all(AppDimens.space20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                                : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                          boxShadow: AppDimens.shadowCard(isDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    product.category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(
                                      product.domain.startsWith('http')
                                          ? product.domain
                                          : 'https://${product.domain}',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Visit Site',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.open_in_new_rounded, color: Colors.white, size: 12),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Domain Heading
                            Text(
                              cleanDomain,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.country} • Language: ${product.language}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 12),

                            // Pricing Strip
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'BASE PLACEMENT RATE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      Formatters.formatCurrency(product.priceCents),
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.accentEmerald,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flash_on_rounded, color: AppColors.accentAmber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.turnaround,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Metrics Section Heading
                      Row(
                        children: [
                          const Icon(Icons.insights_rounded, size: 20, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            'Verified SEO Authority Metrics',
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Metrics 2-column Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.1,
                        children: [
                          _buildMetricTile(context, 'Domain Authority', product.metrics.da, AppColors.metricDa, Icons.shield_outlined),
                          _buildMetricTile(context, 'Domain Rating', product.metrics.dr, AppColors.metricDr, Icons.star_border_rounded),
                          _buildMetricTile(context, 'Monthly Traffic', product.metrics.traffic, AppColors.metricTraffic, Icons.trending_up_rounded),
                          _buildMetricTile(context, 'Trust Flow', product.metrics.tf, AppColors.accent, Icons.verified_outlined),
                          _buildMetricTile(context, 'URL Rating', product.metrics.ur, AppColors.accentPurple, Icons.link_rounded),
                          _buildMetricTile(context, 'Referring Domains', product.metrics.referringDomains, const Color(0xFF64748B), Icons.hub_outlined),
                          _buildMetricTile(context, 'Total Backlinks', product.metrics.backlinks, const Color(0xFF64748B), Icons.all_inclusive_rounded),
                          _buildMetricTile(
                            context,
                            'Spam Score',
                            product.metrics.spamScore,
                            (product.metrics.spamScore ?? 0) > 30 ? AppColors.error : AppColors.success,
                            Icons.security_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Placement Terms & Editorial Requirements Card
                      Row(
                        children: [
                          const Icon(Icons.gavel_rounded, size: 20, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(
                            'Placement Terms & Editorial Policy',
                            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      AppCard(
                        padding: const EdgeInsets.all(AppDimens.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Link Attribute Format', product.linkType, Icons.check_circle_outline, isDark),
                            const Divider(height: 20),
                            _buildInfoRow('Expected Turnaround', product.turnaround, Icons.schedule_rounded, isDark),
                            const Divider(height: 20),
                            _buildInfoRow(
                              'Editorial Guidelines',
                              product.requirements.isNotEmpty
                                  ? product.requirements
                                  : 'Standard editorial fit required. Articles must be informational and comply with publisher niche standards.',
                              Icons.description_outlined,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Trust Notice
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDarkCard
                              : AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.info, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'All supplied metrics are periodically verified. Always confirm content relevance and anchor fit prior to placement publication.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Inquire button
                      IconButton.outlined(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push(
                            '/inquiry?domain=${Uri.encodeComponent(cleanDomain)}',
                          );
                        },
                        icon: const Icon(Icons.mail_outline_rounded),
                        tooltip: 'Send Custom Inquiry',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          side: BorderSide(
                            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Plan Placement CTA button
                      Expanded(
                        child: AppButton(
                          text: 'Plan Placement  •  ${Formatters.formatCurrency(product.priceCents)}',
                          icon: Icons.assignment_turned_in_outlined,
                          size: AppButtonSize.large,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ConfigurePlacementSheet(
                                product: product,
                                options: options,
                              ),
                            );
                          },
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

  Widget _buildMetricTile(
    BuildContext context,
    String title,
    int? value,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
        boxShadow: AppDimens.shadowSubtle(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.formatMetric(value),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
