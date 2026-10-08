import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../providers/shortlist_provider.dart';
import '../widgets/compare_table.dart';
import '../widgets/product_card.dart';

class ShortlistScreen extends ConsumerStatefulWidget {
  const ShortlistScreen({super.key});

  @override
  ConsumerState<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends ConsumerState<ShortlistScreen> {
  bool _compare = false;

  Future<void> _confirmClear() async {
    final ok = await showConfirmDialog(
      context,
      icon: Icons.bookmark_remove_outlined,
      title: 'Clear your shortlist?',
      message: 'All saved publications will be removed. This can’t be undone.',
      confirmLabel: 'Clear all',
      destructive: true,
    );
    if (ok) ref.read(shortlistProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final shortlist = ref.watch(shortlistProvider);
    final canCompare = shortlist.length >= 2;
    final showCompare = _compare && canCompare;
    final padding = context.pagePadding(top: AppSpace.sm);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (shortlist.isNotEmpty)
            TextButton(
              onPressed: _confirmClear,
              style: TextButton.styleFrom(
                foregroundColor: context.palette.dangerText,
              ),
              child: const Text('Clear all'),
            ),
          const SizedBox(width: AppSpace.xs),
        ],
      ),
      body: shortlist.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              tint: context.palette.brandText,
              title: 'Nothing saved yet',
              message:
                  'Tap the heart on a publication to save it here, then compare your favorites before you plan placements.',
              actionLabel: 'Explore the catalog',
              onAction: () => context.go('/marketplace'),
            )
          : Column(
              children: [
                ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter,
                      AppSpace.sm,
                      AppSpace.gutter,
                      AppSpace.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${shortlist.length} of ${ShortlistNotifier.limit} publications saved',
                                style: context.text.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.sm),
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            minimumSize: const Size(0, AppSpace.minTarget),
                          ),
                          segments: [
                            const ButtonSegment(
                              value: false,
                              icon: Icon(Icons.view_agenda_outlined),
                              label: Text('List'),
                            ),
                            ButtonSegment(
                              value: true,
                              enabled: canCompare,
                              icon: const Icon(Icons.compare_arrows_rounded),
                              label: const Text('Compare'),
                            ),
                          ],
                          selected: {showCompare},
                          onSelectionChanged: (s) {
                            HapticFeedback.selectionClick();
                            setState(() => _compare = s.first);
                          },
                        ),
                        if (!canCompare) ...[
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            'Save at least two publications to compare them.',
                            style: context.text.bodySmall?.copyWith(
                              color: context.palette.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.of(context),
                    child: showCompare
                        ? ListView(
                            key: const ValueKey('compare'),
                            padding: const EdgeInsets.only(bottom: AppSpace.xl),
                            children: [
                              ContentWidth(
                                maxWidth: 960,
                                child: CompareTable(
                                  products: shortlist,
                                  onRemove: (p) => ref
                                      .read(shortlistProvider.notifier)
                                      .remove(p.id),
                                  onOpen: (p) =>
                                      context.push('/domain/${p.id}'),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            key: const ValueKey('list'),
                            padding: padding.copyWith(top: AppSpace.xs),
                            itemCount: shortlist.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpace.md),
                            itemBuilder: (context, i) {
                              final product = shortlist[i];
                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                                onTap: () =>
                                    context.push('/domain/${product.id}'),
                                onPlan: () =>
                                    showPlacementSheet(context, product),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
