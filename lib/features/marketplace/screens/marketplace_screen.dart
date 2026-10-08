import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/shortlist_provider.dart';
import '../widgets/filter_edit.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_card.dart';

const _sortOptions = <({String key, String label, String short})>[
  (key: 'domain', label: 'Publication name (A–Z)', short: 'Name A–Z'),
  (key: 'priceAsc', label: 'Price: low to high', short: 'Price ↑'),
  (key: 'priceDesc', label: 'Price: high to low', short: 'Price ↓'),
  (key: 'drDesc', label: 'Domain Rating: highest first', short: 'Top DR'),
  (
    key: 'trafficDesc',
    label: 'Monthly traffic: highest first',
    short: 'Top traffic',
  ),
];

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(productFilterProvider).query;
    if (currentQuery != null && currentQuery.isNotEmpty) {
      _searchController.text = currentQuery;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setFilters(ProductFilterParams next) {
    ref.read(productFilterProvider.notifier).state = next;
  }

  void _applyQuery(String val) {
    final trimmed = val.trim();
    final current = ref.read(productFilterProvider);
    if ((current.query ?? '') == trimmed) return;
    _setFilters(current.edit(query: trimmed.isEmpty ? null : trimmed, page: 1));
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _applyQuery(val),
    );
  }

  void _onSearchSubmitted(String val) {
    _debounce?.cancel();
    HapticFeedback.lightImpact();
    _applyQuery(val);
  }

  void _goToPage(ProductFilterParams params, int page) {
    _setFilters(params.edit(page: page));
    if (_scrollController.hasClients) {
      if (context.reduceMotion) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          0,
          duration: AppMotion.base,
          curve: AppMotion.standard,
        );
      }
    }
  }

  void _resetAll(ProductFilterParams current) {
    _debounce?.cancel();
    _searchController.clear();
    _setFilters(ProductFilterParams(sort: current.sort));
  }

  Future<void> _openFilters() async {
    HapticFeedback.lightImpact();
    final facets = ref.read(facetsProvider);
    final data = facets.valueOrNull;
    if (data == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              facets.hasError
                  ? "Filters couldn't load. Check your connection."
                  : 'Loading filters…',
            ),
            action: facets.hasError
                ? SnackBarAction(
                    label: 'Retry',
                    onPressed: () => ref.invalidate(facetsProvider),
                  )
                : null,
          ),
        );
      if (facets.hasError) ref.invalidate(facetsProvider);
      return;
    }
    await showFilterSheet(
      context,
      initial: ref.read(productFilterProvider),
      facets: data,
      onApply: _setFilters,
    );
  }

  Future<void> _openSort() async {
    HapticFeedback.lightImpact();
    final current = ref.read(productFilterProvider);
    final picked = await showAppSheet<String>(
      context,
      title: 'Sort publications',
      builder: (ctx) => Column(
        children: [
          for (final o in _sortOptions) ...[
            ChoiceTile(
              selected: current.sort == o.key,
              title: o.label,
              onTap: () => Navigator.of(ctx).pop(o.key),
            ),
            const SizedBox(height: AppSpace.sm),
          ],
        ],
      ),
    );
    if (picked != null && picked != current.sort) {
      _setFilters(current.edit(sort: picked, page: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFilterProvider);
    final productsAsync = ref.watch(productListProvider);
    final shortlistCount = ref.watch(shortlistProvider.select((l) => l.length));
    final categories =
        ref.watch(facetsProvider).valueOrNull?.categories ?? const <String>[];
    final sortLabel = _sortOptions
        .firstWhere(
          (o) => o.key == filters.sort,
          orElse: () => _sortOptions.first,
        )
        .short;
    final padding = context.pagePadding(top: AppSpace.md, bottom: AppSpace.xl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search publications'),
        actions: [
          IconButton(
            tooltip: 'Saved publications',
            icon: CountBadge(
              count: shortlistCount,
              semanticLabel: '$shortlistCount saved',
              child: const Icon(Icons.favorite_border_rounded),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/shortlist');
            },
          ),
          const SizedBox(width: AppSpace.xs),
        ],
      ),
      body: Column(
        children: [
          // Sticky toolbar: search, filters, sort.
          ContentWidth(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left > AppSpace.gutter ? 0 : AppSpace.gutter,
                AppSpace.xs,
                padding.left > AppSpace.gutter ? 0 : AppSpace.gutter,
                AppSpace.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppSearchField(
                          controller: _searchController,
                          hint: 'Search domain or niche',
                          onChanged: _onSearchChanged,
                          onSubmitted: _onSearchSubmitted,
                          onClear: () => _onSearchSubmitted(''),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: context.palette.brandSoft,
                          foregroundColor: context.palette.brandText,
                        ),
                        tooltip: filters.activeFilterCount > 0
                            ? 'Filters, ${filters.activeFilterCount} active'
                            : 'Filters',
                        onPressed: _openFilters,
                        icon: CountBadge(
                          count: filters.activeFilterCount,
                          child: const Icon(Icons.tune_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(20) + 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpace.sm),
                      itemBuilder: (context, i) {
                        final category = i == 0 ? null : categories[i - 1];
                        final selected = filters.category == category;
                        return Center(
                          child: ChoiceChip(
                            label: Text(category ?? 'All'),
                            selected: selected,
                            showCheckmark: false,
                            selectedColor: context.palette.brand,
                            labelStyle: context.text.labelMedium?.copyWith(
                              color: selected
                                  ? context.palette.onBrand
                                  : context.palette.textSecondary,
                            ),
                            onSelected: (_) => _setFilters(
                              filters.edit(category: category, page: 1),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filters.hasActiveFilters)
            ContentWidth(
              child: _ActiveFilters(
                filters: filters,
                onChange: _setFilters,
                onClearQuery: () => _searchController.clear(),
                onReset: () => _resetAll(filters),
              ),
            ),
          Divider(height: 1, color: context.palette.border),
          Expanded(
            child: _Results(
              async: productsAsync,
              filters: filters,
              sortLabel: sortLabel,
              scrollController: _scrollController,
              padding: padding,
              onPage: (page) => _goToPage(filters, page),
              onReset: () => _resetAll(filters),
              onRetry: () => ref.invalidate(productListProvider),
              onSort: _openSort,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.filters,
    required this.onChange,
    required this.onClearQuery,
    required this.onReset,
  });

  final ProductFilterParams filters;
  final ValueChanged<ProductFilterParams> onChange;
  final VoidCallback onClearQuery;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final f = filters;
    final chips = <(String, VoidCallback)>[
      if (f.query != null && f.query!.trim().isNotEmpty)
        (
          '“${f.query}”',
          () {
            onClearQuery();
            onChange(f.edit(query: null, page: 1));
          },
        ),
      if (f.category != null && f.category!.isNotEmpty)
        (f.category!, () => onChange(f.edit(category: null, page: 1))),
      if (f.country != null && f.country!.isNotEmpty)
        (f.country!, () => onChange(f.edit(country: null, page: 1))),
      if (f.language != null && f.language!.isNotEmpty)
        (f.language!, () => onChange(f.edit(language: null, page: 1))),
      if (f.minDr != null || f.maxDr != null)
        (
          _range('DR', f.minDr, f.maxDr),
          () => onChange(f.edit(minDr: null, maxDr: null, page: 1)),
        ),
      if (f.minDa != null || f.maxDa != null)
        (
          _range('DA', f.minDa, f.maxDa),
          () => onChange(f.edit(minDa: null, maxDa: null, page: 1)),
        ),
      if (f.minTraffic != null || f.maxTraffic != null)
        (
          _range('Traffic', f.minTraffic, f.maxTraffic),
          () => onChange(f.edit(minTraffic: null, maxTraffic: null, page: 1)),
        ),
      if (f.minPrice != null || f.maxPrice != null)
        (
          _priceRange(f.minPrice, f.maxPrice),
          () => onChange(f.edit(minPrice: null, maxPrice: null, page: 1)),
        ),
    ];

    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(32) + 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.gutter,
          vertical: AppSpace.xs,
        ),
        itemCount: chips.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
        itemBuilder: (context, i) {
          if (i == chips.length) {
            return Center(
              child: TextButton(
                onPressed: onReset,
                child: const Text('Reset all'),
              ),
            );
          }
          final (label, remove) = chips[i];
          return Center(
            child: InputChip(
              label: Text(label),
              onDeleted: () {
                HapticFeedback.selectionClick();
                remove();
              },
              deleteIcon: const Icon(Icons.close_rounded, size: 18),
              deleteButtonTooltipMessage: 'Remove filter $label',
              materialTapTargetSize: MaterialTapTargetSize.padded,
              backgroundColor: context.palette.brandSoft,
              side: BorderSide(
                color: context.palette.brand.withValues(alpha: 0.4),
              ),
              labelStyle: context.text.labelMedium?.copyWith(
                color: context.palette.brandText,
              ),
              deleteIconColor: context.palette.brandText,
            ),
          );
        },
      ),
    );
  }

  static String _range(String name, int? min, int? max) {
    if (min != null && max != null) return '$name $min–$max';
    if (min != null) return '$name $min+';
    return '$name ≤ $max';
  }

  static String _priceRange(double? min, double? max) {
    if (min != null && max != null) return '\$${min.round()}–\$${max.round()}';
    if (min != null) return '\$${min.round()}+';
    return 'Up to \$${max!.round()}';
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.async,
    required this.filters,
    required this.sortLabel,
    required this.scrollController,
    required this.padding,
    required this.onPage,
    required this.onReset,
    required this.onRetry,
    required this.onSort,
  });

  final AsyncValue<ProductPage> async;
  final ProductFilterParams filters;
  final String sortLabel;
  final ScrollController scrollController;
  final EdgeInsets padding;
  final ValueChanged<int> onPage;
  final VoidCallback onReset;
  final VoidCallback onRetry;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = async.valueOrNull;
    final reloading = async.isLoading && page != null;

    if (async.hasError && !async.isLoading) {
      return ErrorState(error: async.error, onRetry: onRetry);
    }
    if (page == null) {
      return ProductListSkeleton(padding: padding);
    }
    if (page.data.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No publications found',
        message: filters.hasActiveFilters
            ? 'Nothing matches those criteria. Try widening your ranges or removing a filter.'
            : 'There are no publications to show right now.',
        actionLabel: filters.hasActiveFilters ? 'Clear filters' : null,
        onAction: filters.hasActiveFilters ? onReset : null,
      );
    }

    final totalPages = page.pageSize == 0
        ? 1
        : (page.total / page.pageSize).ceil();

    return Stack(
      children: [
        AnimatedOpacity(
          duration: AppMotion.of(context, AppMotion.fast),
          opacity: reloading ? 0.55 : 1,
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(productListProvider),
            child: CustomScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: padding.copyWith(bottom: 0),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              liveRegion: true,
                              child: Text(
                                '${Formatters.formatMetric(page.total)} publications',
                                style: context.text.titleSmall,
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'Sort, currently $sortLabel',
                            child: AppButton(
                              label: 'Sort',
                              icon: Icons.swap_vert_rounded,
                              size: AppButtonSize.small,
                              variant: AppButtonVariant.outline,
                              semanticLabel: 'Sort, currently $sortLabel',
                              onPressed: onSort,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: padding.copyWith(top: 0, bottom: 0),
                  sliver: SliverList.separated(
                    itemCount: page.data.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpace.md),
                    itemBuilder: (context, i) {
                      final product = page.data[i];
                      return ProductCard(
                        key: ValueKey(product.id),
                        product: product,
                        heroEnabled: true,
                        onTap: () => context.push('/domain/${product.id}'),
                        onPlan: () => showPlacementSheet(context, product),
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: padding.copyWith(top: AppSpace.lg),
                  sliver: SliverToBoxAdapter(
                    child: _Pager(
                      page: page.page,
                      totalPages: totalPages,
                      busy: reloading,
                      onPage: onPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (reloading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 3),
          ),
      ],
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.totalPages,
    required this.busy,
    required this.onPage,
  });

  final int page;
  final int totalPages;
  final bool busy;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'Previous',
              icon: Icons.chevron_left_rounded,
              variant: AppButtonVariant.outline,
              onPressed: page > 1 && !busy ? () => onPage(page - 1) : null,
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            '$page / $totalPages',
            style: context.text.labelLarge?.copyWith(color: p.textSecondary),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Next',
              trailingIcon: Icons.chevron_right_rounded,
              variant: AppButtonVariant.outline,
              onPressed: page < totalPages && !busy
                  ? () => onPage(page + 1)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
