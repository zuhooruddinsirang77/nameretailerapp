import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';
import 'configure_placement_sheet.dart';
import '../../marketplace/models/product.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticated = ref.watch(
      authStateProvider.select((s) => s.isAuthenticated),
    );
    final cartAsync = ref.watch(cartProvider);

    if (!authenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Planning cart')),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: 'Sign in to use your cart',
          message:
              'Your planning cart is private to your account. Sign in or create an account to save placements and continue to checkout.',
          actionLabel: 'Sign in',
          onAction: () => context.push('/login'),
          secondaryLabel: 'Create an account',
          onSecondary: () => context.push('/register'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cartAsync.valueOrNull?.items.length ?? 0})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh cart',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(cartProvider.notifier).loadCart();
            },
          ),
          const SizedBox(width: AppSpace.xs),
        ],
      ),
      body: cartAsync.when(
        loading: () => SkeletonLoader(
          semanticLabel: 'Loading your cart',
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: context.pagePadding(),
            children: const [
              CartItemSkeleton(),
              SizedBox(height: AppSpace.md),
              CartItemSkeleton(),
              SizedBox(height: AppSpace.md),
              CartItemSkeleton(),
            ],
          ),
        ),
        error: (err, _) => ErrorState(
          error: err,
          onRetry: () => ref.read(cartProvider.notifier).loadCart(),
        ),
        data: (cart) {
          if (cart.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message:
                  'Browse the catalog and choose â€œPlanâ€ on a publication to build your brief and save it here.',
              actionLabel: 'Browse the catalog',
              onAction: () => context.go('/marketplace'),
            );
          }
          return _CartBody(cart: cart);
        },
      ),
    );
  }
}

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.cart});

  final CartView cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = cart.items;
    final totalCents =
        cart.totalCents ??
        items.fold<int>(0, (sum, item) => sum + (item.totalCents ?? 0));
    final placementSum = items.fold<int>(
      0,
      (s, i) => s + (i.placementCents ?? 0),
    );
    final writingSum = items.fold<int>(0, (s, i) => s + (i.writingCents ?? 0));
    final padding = context.pagePadding(top: AppSpace.sm);
    final count = items.length;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(cartProvider.notifier).loadCart(),
            child: ListView(
              padding: padding,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const InlineMessage(
                  message:
                      'Placements stay in your private planning cart until you check out.',
                  icon: Icons.shield_outlined,
                ),
                const SizedBox(height: AppSpace.md),
                for (var i = 0; i < items.length; i++) ...[
                  _CartItemCard(item: items[i]),
                  const SizedBox(height: AppSpace.sm),
                ],
                const SizedBox(height: AppSpace.sm),
                AppCard(
                  tone: AppCardTone.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Order summary', style: context.text.titleMedium),
                      const SizedBox(height: AppSpace.md),
                      KeyValueRow(
                        label: 'Placement fees',
                        value: Formatters.formatCurrency(placementSum),
                      ),
                      if (writingSum > 0) ...[
                        const SizedBox(height: AppSpace.sm),
                        KeyValueRow(
                          label: 'Writing packages',
                          value: Formatters.formatCurrency(writingSum),
                        ),
                      ],
                      const SizedBox(height: AppSpace.md),
                      Divider(height: 1, color: context.palette.border),
                      const SizedBox(height: AppSpace.md),
                      KeyValueRow(
                        label: 'Total',
                        value: Formatters.formatCurrency(totalCents),
                        emphasis: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        PriceSummaryBar(
          label: 'Order total Â· $count ${count == 1 ? 'item' : 'items'}',
          cents: totalCents,
          actionLabel: 'Checkout',
          actionIcon: Icons.arrow_forward_rounded,
          onAction:
              cart.totalCents == null || items.any((item) => item.issue != null)
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  context.push('/checkout');
                },
        ),
      ],
    );
  }
}

class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItem item;

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    String domain,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: 'Remove this placement?',
      message: '$domain will be removed from your planning cart.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok) return;
    final removed = await ref
        .read(cartProvider.notifier)
        .removeItem(item.productId);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            removed
                ? '$domain removed from your cart.'
                : "We couldn't remove it. Check your connection and try again.",
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final raw = item.domain ?? 'Publication';
    final domain = Formatters.cleanDomain(raw);
    final brief = item.brief;
    final hasBrief = brief != null && brief.keyword.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(AppSpace.md),
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DomainAvatar(domain: raw, size: 56),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      domain,
                      style: context.text.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      Formatters.formatCurrency(item.totalCents),
                      style: context.text.titleMedium?.copyWith(
                        color: p.brandText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove $domain',
                icon: Icon(Icons.close_rounded, size: 19, color: p.textMuted),
                onPressed: () => _remove(context, ref, domain),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            item.writingWords == 0
                ? 'Customer-provided article'
                : '${item.writingWords}-word writing package',
            style: context.text.labelSmall?.copyWith(color: p.textSecondary),
          ),
          if (hasBrief) ...[
            const SizedBox(height: AppSpace.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.link_rounded, size: 16, color: p.textMuted),
                const SizedBox(width: AppSpace.xs),
                Expanded(
                  child: Text(
                    brief.promotedUrl.isEmpty
                        ? '“${brief.keyword}”'
                        : '“${brief.keyword}” → ${brief.promotedUrl}',
                    style: context.text.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (item.file != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text('Article file: ${item.file!.name}'),
          ],
          if (item.options != null) ...[
            const SizedBox(height: AppSpace.sm),
            KeyValueRow(label: 'Link type', value: item.options!.linkType),
          ],
          if (item.issue != null) ...[
            const SizedBox(height: AppSpace.sm),
            InlineMessage(
              tone: item.status == 'unavailable'
                  ? MessageTone.danger
                  : MessageTone.warning,
              message: item.issue!,
            ),
          ],
          if (item.status != 'unavailable')
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit placement brief'),
              onPressed: () => showPlacementSheet(
                context,
                Product(
                  id: item.productId,
                  domain: raw,
                  language: '',
                  country: '',
                  category: '',
                  priceCents:
                      item.options?.placementCents ?? item.placementCents ?? 0,
                  currency: 'USD',
                  status: 'active',
                  metrics: ProductMetrics(),
                  linkType: item.options?.linkType ?? '',
                  turnaround: item.options?.turnaround ?? '',
                  requirements: item.options?.requirements ?? '',
                  version: item.options?.productVersion ?? item.productVersion,
                ),
                options: item.options,
              ),
            ),
        ],
      ),
    );
  }
}
