import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../providers/shortlist_provider.dart';
import '../widgets/product_card.dart';

class ShortlistScreen extends ConsumerWidget {
  const ShortlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortlist = ref.watch(shortlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Publications'),
        actions: [
          if (shortlist.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Shortlist?'),
                    content: const Text(
                      'Are you sure you want to remove all saved publications from your shortlist?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(ctx).pop();
                          ref.read(shortlistProvider.notifier).clear();
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error),
              ),
            ),
        ],
      ),
      body: shortlist.isEmpty
          ? AppEmptyState(
              icon: Icons.bookmark_border_rounded,
              iconColor: AppColors.accentAmber,
              title: 'Your Shortlist is Empty',
              description:
                  'Bookmark high-authority publications while browsing the marketplace to review and plan placements together.',
              actionText: 'Explore Catalog',
              onActionTap: () => context.go('/marketplace'),
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimens.space16),
              children: [
                // Info Summary Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    border: Border.all(
                      color: AppColors.accentAmber.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_added_rounded, color: AppColors.accentAmber, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${shortlist.length} publication${shortlist.length > 1 ? 's' : ''} saved for planning & comparison.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Saved Cards
                ...shortlist.map(
                  (product) => ProductCard(
                    product: product,
                    onTap: () => context.push('/domain/${product.id}'),
                    onPlan: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ConfigurePlacementSheet(product: product),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
