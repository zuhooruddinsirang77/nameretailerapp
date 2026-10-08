import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About NameRetailer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand hero banner
            Center(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(AppDimens.space8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                      boxShadow: AppDimens.shadowSubtle(isDark),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      child: Image.asset(
                        'assets/images/logo_emblem.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space12),
                  Text(
                    'NameRetailer',
                    style: AppTypography.displayMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                    ),
                    child: Text(
                      'PREMIUM GUEST-POST MARKETPLACE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space24),

            // Overview card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                        ),
                        child: const Icon(
                          Icons.travel_explore,
                          size: 18,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space10),
                      const Text(
                        'Built For Quality Placements',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space10),
                  Text(
                    'NameRetailer unites high-authority publications with verified audience metrics, transparent pricing, and optional bespoke copywriting so modern marketing teams scale their guest post campaigns with absolute confidence.',
                    style: AppTypography.bodyMedium.copyWith(
                      height: 1.55,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space16),

            // Key Pillars
            _buildFeaturePill(
              context,
              icon: Icons.language,
              title: '56,000+ Vetted Publications',
              description:
                  'Filter by topic, country, language, and real Domain Authority, Domain Rating, and verified organic traffic.',
            ),
            const SizedBox(height: AppDimens.space10),
            _buildFeaturePill(
              context,
              icon: Icons.edit_note,
              title: 'Content & Placement Separation',
              description:
                  'Placement fees are transparently quoted. Optional 500w, 750w, and 1,000w article drafting are written natively for your target publisher.',
            ),
            const SizedBox(height: AppDimens.space10),
            _buildFeaturePill(
              context,
              icon: Icons.lock_clock_outlined,
              title: 'Private 7-Day Planning Drafts',
              description:
                  'Build customized media plans with live pricing calculations and lock in drafts without pressure.',
            ),
            const SizedBox(height: AppDimens.space20),

            // Legal & Corporate Information
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: AppColors.accentEmerald,
                      ),
                      const SizedBox(width: AppDimens.space6),
                      Text(
                        'Corporate Entity',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentEmerald,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space6),
                  const Text(
                    'Name Retailer FZE',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppDimens.space4),
                  Text(
                    '26 - G Hamriyah Freezone\nSharjah, United Arab Emirates\nEmail: info@nameretailer.com',
                    style: AppTypography.bodySmall.copyWith(
                      height: 1.5,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.space24),

            // Build badge
            Center(
              child: Text(
                'Customer Mobile Edition • v1.0.0',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.space8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDarkCard : AppColors.dividerLight,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    height: 1.4,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
