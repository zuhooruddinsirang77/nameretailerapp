import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final cartAsync = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planning Cart')),
        body: AppEmptyState(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.accent,
          title: 'Customer Account Required',
          description:
              'Sign in or register a customer account to save domain placements to your private planning cart and proceed with orders.',
          actionText: 'Sign In to Account',
          onActionTap: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Cart',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).loadCart();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Loading your planning cart…'),
            ],
          ),
        ),
        error: (err, _) => AppEmptyState(
          icon: Icons.cloud_off_rounded,
          iconColor: AppColors.error,
          title: 'Unable to Load Cart',
          description: err.toString(),
          actionText: 'Retry',
          onActionTap: () => ref.read(cartProvider.notifier).loadCart(),
        ),
        data: (cart) {
          if (cart.items.isEmpty) {
            return AppEmptyState(
              icon: Icons.shopping_bag_outlined,
              iconColor: AppColors.accent,
              title: 'Your Planning Cart is Empty',
              description:
                  'Browse publications in the marketplace and choose "Plan Placement" to customize briefs and save your orders.',
              actionText: 'Browse Catalog',
              onActionTap: () => context.go('/marketplace'),
            );
          }

          final totalCents = cart.totalCents ??
              cart.items.fold<int>(0, (sum, item) => sum + (item.totalCents ?? 0));

          return Column(
            children: [
              // Info Banner Strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDarkCard
                      : AppColors.accent.withValues(alpha: 0.08),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Items in your planning cart are preserved for your private account.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(cartProvider.notifier).loadCart(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItemCard(context, ref, item, isDark);
                    },
                  ),
                ),
              ),

              // Bottom Sticky Checkout Bar
              Container(
                padding: const EdgeInsets.all(AppDimens.space16),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ORDER TOTAL (${cart.items.length} ${cart.items.length == 1 ? 'ITEM' : 'ITEMS'})',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(totalCents),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentEmerald,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      AppButton(
                        text: 'Review Checkout',
                        icon: Icons.arrow_forward_rounded,
                        size: AppButtonSize.large,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.push('/checkout');
                        },
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

  Widget _buildCartItemCard(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
    bool isDark,
  ) {
    final cleanDomain = Formatters.cleanDomain(item.domain ?? 'Publication');

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
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Domain initial + Name + Remove Button
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cleanDomain.isNotEmpty ? cleanDomain[0].toUpperCase() : 'P',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cleanDomain,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove Placement?'),
                        content: Text(
                          'Remove $cleanDomain from your planning cart?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      HapticFeedback.mediumImpact();
                      await ref.read(cartProvider.notifier).removeItem(item.productId);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Writing Service Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.article_outlined, size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    item.writingWords == 0
                        ? 'Customer Provided Draft'
                        : '${item.writingWords}-Word Writing Package',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Target Keyword / Promoted URL Preview
            if (item.brief != null && item.brief!.keyword.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: AppColors.textMutedLight),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '"${item.brief!.keyword}" → ${item.brief!.promotedUrl}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],

            Divider(
              height: 1,
              color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight,
            ),
            const SizedBox(height: 8),

            // Price Details Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Placement: ${Formatters.formatCurrency(item.placementCents)}'
                  '${(item.writingCents ?? 0) > 0 ? '  •  Writing: ${Formatters.formatCurrency(item.writingCents)}' : ''}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(item.totalCents),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentEmerald,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
