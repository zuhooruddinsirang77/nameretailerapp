import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Essentials & FAQ'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.space16,
          vertical: AppDimens.space20,
        ),
        children: [
          _buildGuideItem(
            context,
            icon: Icons.people_outline,
            accentColor: AppColors.accent,
            title: 'Audience before raw scores',
            body:
                'Always evaluate topical relevance, target country, and language fit first. Third-party metrics (DR, DA, TF) and estimated organic visits are useful reference signals, but do not guarantee editorial fit or specific ranking results.',
          ),
          const SizedBox(height: AppDimens.space12),
          _buildGuideItem(
            context,
            icon: Icons.edit_note,
            accentColor: AppColors.accentEmerald,
            title: 'Content & placement separation',
            body:
                'Placement fees secure editorial review and publishing on the selected publication. If you choose our copywriting services (500, 750, or 1000 words), your article is crafted from your brief to match the host site’s editorial standards.',
          ),
          const SizedBox(height: AppDimens.space12),
          _buildGuideItem(
            context,
            icon: Icons.timelapse,
            accentColor: AppColors.accentAmber,
            title: 'Turnaround expectations',
            body:
                'Typical turnaround is 3 to 5 business days from the moment your article brief is confirmed. Editorial review schedules may naturally adjust around local holidays and weekends.',
          ),
          const SizedBox(height: AppDimens.space12),
          _buildGuideItem(
            context,
            icon: Icons.shield_outlined,
            accentColor: AppColors.accentPurple,
            title: 'Planning cart vs. Live checkout',
            body:
                'Adding items to your cart saves your customized configurations privately. Progressing to order draft generation securely reserves your campaign proposal for 7 days without committing payment immediately.',
          ),
          const SizedBox(height: AppDimens.space12),
          _buildGuideItem(
            context,
            icon: Icons.link_rounded,
            accentColor: AppColors.accent,
            title: 'DoFollow link guidelines',
            body:
                'Publications typically allow up to 2 DoFollow anchor links within natural editorial context. Over-optimized anchor text, commercial disclaimers, or off-topic landing pages may be rejected by editorial teams.',
          ),
          const SizedBox(height: AppDimens.space12),
          _buildGuideItem(
            context,
            icon: Icons.support_agent_outlined,
            accentColor: AppColors.accentEmerald,
            title: 'Need a custom volume or tier?',
            body:
                'If you are seeking bulk campaigns or custom publisher outreach not currently indexed in the catalog, submit an inquiry from the customer dashboard for tailored enterprise coordination.',
          ),
          const SizedBox(height: AppDimens.space24),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String body,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.space10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppDimens.space14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppTypography.bodySmall.copyWith(
                    height: 1.5,
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
