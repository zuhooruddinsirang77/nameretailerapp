import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../data/product_repository.dart';
import '../models/facets.dart';
import '../providers/product_provider.dart';
import '../providers/shortlist_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_card.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<Map<String, String>> _sortOptions = const [
    {'key': 'domain', 'label': 'Publication Name (A–Z)'},
    {'key': 'priceAsc', 'label': 'Placement Price: Low to High'},
    {'key': 'priceDesc', 'label': 'Placement Price: High to Low'},
    {'key': 'drDesc', 'label': 'Domain Rating (DR): Highest First'},
    {'key': 'trafficDesc', 'label': 'Monthly Traffic: Highest First'},
  ];

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
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String val) {
    HapticFeedback.lightImpact();
    final current = ref.read(productFilterProvider);
    ref.read(productFilterProvider.notifier).state = current.copyWith(
      query: val.trim().isEmpty ? null : val.trim(),
      page: 1,
    );
  }

  void _openFilterSheet(ProductFacets facets) {
    HapticFeedback.lightImpact();
    final current = ref.read(productFilterProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialParams: current,
        facets: facets,
        onApply: (updated) {
          ref.read(productFilterProvider.notifier).state = updated;
        },
      ),
    );
  }

  void _showSortDialog() {
    HapticFeedback.lightImpact();
    final current = ref.read(productFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dividerDark : AppColors.cardBorderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded, size: 20, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Sort Publications',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ..._sortOptions.map((opt) {
                  final isSelected = current.sort == opt['key'];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    title: Text(
                      opt['label']!,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18)
                        : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                      ref.read(productFilterProvider.notifier).state =
                          current.copyWith(sort: opt['key']!, page: 1);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterParams = ref.watch(productFilterProvider);
    final productsAsync = ref.watch(productListProvider);
    final facetsAsync = ref.watch(facetsProvider);
    final shortlistCount = ref.watch(shortlistProvider).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Marketplace Catalog',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              '56,000+ Verified Domain Placements',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: shortlistCount > 0,
              label: Text('$shortlistCount'),
              backgroundColor: AppColors.accentAmber,
              child: const Icon(Icons.bookmark_outline_rounded),
            ),
            tooltip: 'Shortlist',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/shortlist');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDarkCard : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      border: Border.all(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                        width: 1,
                      ),
                      boxShadow: AppDimens.shadowSubtle(isDark),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(Icons.search, size: 18, color: AppColors.textMutedLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: _onSearchSubmitted,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search domain or niche…',
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMutedLight,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              _searchController.clear();
                              _onSearchSubmitted('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Filter button with active indicator
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? AppColors.surfaceDarkCard : Colors.white,
                        side: BorderSide(
                          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        ),
                      ),
                      onPressed: () {
                        facetsAsync.whenData((facets) => _openFilterSheet(facets));
                      },
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      tooltip: 'Filters',
                    ),
                    if (filterParams.hasActiveFilters)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 6),

                // Sort button
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? AppColors.surfaceDarkCard : Colors.white,
                    side: BorderSide(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                  ),
                  onPressed: _showSortDialog,
                  icon: const Icon(Icons.swap_vert_rounded, size: 20),
                  tooltip: 'Sort By',
                ),
              ],
            ),
          ),

          // Active Filter Chips Strip
          if (filterParams.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filterParams.query != null && filterParams.query!.isNotEmpty)
                      _buildActiveFilterTag(
                        'Keyword: "${filterParams.query}"',
                        () {
                          _searchController.clear();
                          ref.read(productFilterProvider.notifier).state =
                              filterParams.copyWith(query: null, page: 1);
                        },
                      ),
                    if (filterParams.category != null)
                      _buildActiveFilterTag(
                        'Topic: ${filterParams.category}',
                        () => ref.read(productFilterProvider.notifier).state =
                            filterParams.copyWith(category: null, page: 1),
                      ),
                    if (filterParams.country != null)
                      _buildActiveFilterTag(
                        'Country: ${filterParams.country}',
                        () => ref.read(productFilterProvider.notifier).state =
                            filterParams.copyWith(country: null, page: 1),
                      ),
                    if (filterParams.minDr != null)
                      _buildActiveFilterTag(
                        'DR ≥ ${filterParams.minDr}',
                        () => ref.read(productFilterProvider.notifier).state =
                            filterParams.copyWith(minDr: null, page: 1),
                      ),
                    if (filterParams.minDa != null)
                      _buildActiveFilterTag(
                        'DA ≥ ${filterParams.minDa}',
                        () => ref.read(productFilterProvider.notifier).state =
                            filterParams.copyWith(minDa: null, page: 1),
                      ),
                    if (filterParams.maxPrice != null)
                      _buildActiveFilterTag(
                        'Max: \$${filterParams.maxPrice!.toInt()}',
                        () => ref.read(productFilterProvider.notifier).state =
                            filterParams.copyWith(maxPrice: null, page: 1),
                      ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(productFilterProvider.notifier).state =
                            ProductFilterParams(sort: filterParams.sort);
                      },
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('Reset All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

          Divider(
            height: 1,
            color: isDark ? AppColors.cardBorderDark : AppColors.dividerLight,
          ),

          // Main Catalog Listing
          Expanded(
            child: productsAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (context, index) => const ProductCardSkeleton(),
              ),
              error: (err, _) => AppEmptyState(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to Load Catalog',
                description: err.toString(),
                actionText: 'Retry Connection',
                onActionTap: () => ref.refresh(productListProvider),
              ),
              data: (page) {
                if (page.data.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Publications Found',
                    description:
                        'No domain matched your active criteria. Try broadening your score ranges or search terms.',
                    actionText: 'Clear Filters',
                    onActionTap: () {
                      _searchController.clear();
                      ref.read(productFilterProvider.notifier).state = ProductFilterParams();
                    },
                  );
                }

                final totalPages = (page.total / page.pageSize).ceil();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productListProvider);
                  },
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Header count bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentEmerald,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${Formatters.formatMetric(page.total)} Publications Found',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Page ${page.page} of $totalPages',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List of Domain Cards
                      ...page.data.map(
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

                      // Pagination Navigation Row
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppButton(
                            text: 'Previous',
                            icon: Icons.chevron_left_rounded,
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                            onPressed: page.page > 1
                                ? () {
                                    ref.read(productFilterProvider.notifier).state =
                                        filterParams.copyWith(page: page.page - 1);
                                    _scrollController.animateTo(
                                      0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                : null,
                          ),
                          Text(
                            'Page ${page.page} of $totalPages',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          AppButton(
                            text: 'Next',
                            icon: Icons.chevron_right_rounded,
                            variant: AppButtonVariant.outline,
                            size: AppButtonSize.small,
                            onPressed: page.page < totalPages
                                ? () {
                                    ref.read(productFilterProvider.notifier).state =
                                        filterParams.copyWith(page: page.page + 1);
                                    _scrollController.animateTo(
                                      0,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
