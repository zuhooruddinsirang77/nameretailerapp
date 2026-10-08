import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../../marketplace/data/product_repository.dart';
import '../../marketplace/providers/product_provider.dart';
import '../../marketplace/providers/shortlist_provider.dart';
import '../../marketplace/widgets/product_card.dart';

final featuredProductsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts(ProductFilterParams(sort: 'drDesc', pageSize: 6));
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  static const _topics = [
    'Business',
    'Technology',
    'Marketing',
    'Finance',
    'Health',
    'Travel',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(productFilterProvider.notifier).state = ProductFilterParams(
      query: query.trim(),
      page: 1,
    );
    context.go('/marketplace');
  }

  void _filterTopic(String topic) {
    HapticFeedback.selectionClick();
    ref.read(productFilterProvider.notifier).state = ProductFilterParams(
      category: topic,
      page: 1,
    );
    context.go('/marketplace');
  }

  Future<void> _refresh() async {
    ref.invalidate(featuredProductsProvider);
    try {
      await ref.read(featuredProductsProvider.future);
    } catch (_) {
      // The featured section displays the retry action.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final shortlistCount = ref.watch(shortlistProvider.select((l) => l.length));
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: p.heroStart,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: p.heroStart,
              foregroundColor: HeroPanel.on,
              toolbarHeight: 68,
              titleSpacing: AppSpace.gutter,
              title: Row(
                children: [
                  const BrandMark(size: 30),
                  const SizedBox(width: AppSpace.sm),
                  Flexible(
                    child: Text(
                      'NameRetailer',
                      style: context.text.titleLarge?.copyWith(
                        color: HeroPanel.on,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Saved publications',
                  style: IconButton.styleFrom(foregroundColor: HeroPanel.on),
                  icon: CountBadge(
                    count: shortlistCount,
                    semanticLabel: '$shortlistCount saved',
                    child: const Icon(Icons.favorite_border_rounded, size: 22),
                  ),
                  onPressed: () => context.push('/shortlist'),
                ),
                IconButton(
                  tooltip: 'Planning cart',
                  style: IconButton.styleFrom(foregroundColor: HeroPanel.on),
                  icon: CountBadge(
                    count: cartCount,
                    semanticLabel: '$cartCount in cart',
                    child: const Icon(Icons.shopping_bag_outlined, size: 22),
                  ),
                  onPressed: () => context.go('/cart'),
                ),
                const SizedBox(width: AppSpace.xs),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            SliverToBoxAdapter(
              child: HeroPanel(
                radius: 0,
                padding: context.pagePadding(
                  top: AppSpace.sm,
                  bottom: AppSpace.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Overline(
                      'Direct guest-post placements',
                      color: HeroPanel.onMuted,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Semantics(
                      header: true,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Find your next\n'),
                            const TextSpan(
                              text: 'perfect placement.',
                              style: TextStyle(color: HeroPanel.accent),
                            ),
                          ],
                        ),
                        style: context.text.displayLarge?.copyWith(
                          color: HeroPanel.on,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      'Discover trusted publishers for your next big idea. Plan, publish and grow with confidence.',
                      style: context.text.bodyMedium?.copyWith(
                        color: HeroPanel.onMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Theme(
                      data: AppThemeForSearch.of(context),
                      child: AppSearchField(
                        controller: _searchController,
                        hint: 'Search a domain or niche…',
                        onSubmitted: _search,
                        fillColor: Colors.white,
                        trailing: Padding(
                          padding: const EdgeInsets.all(AppSpace.xs),
                          child: IconButton.filled(
                            tooltip: 'Search',
                            onPressed: () => _search(_searchController.text),
                            style: IconButton.styleFrom(
                              backgroundColor: p.brand,
                              foregroundColor: p.onBrand,
                              minimumSize: const Size.square(
                                AppSpace.minTarget,
                              ),
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    _TopicRail(topics: _topics, onSelected: _filterTopic),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: p.background,
                  borderRadius: AppRadius.sheetTop,
                ),
                child: Padding(
                  padding: context.pagePadding(top: AppSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TrustTiles(),
                      const SizedBox(height: AppSpace.xl),
                      SectionHeader(
                        title: 'Featured publishers',
                        actionLabel: 'See all',
                        onAction: () => context.go('/marketplace'),
                      ),
                      const SizedBox(height: AppSpace.md),
                      const _FeaturedSection(),
                      const SizedBox(height: AppSpace.xl),
                      const AppCard(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Stat(value: '56,000+', label: 'Live domains'),
                            _Stat(value: '80+', label: 'Countries'),
                            _Stat(value: '3–5 days', label: 'Turnaround'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      AppCard(
                        tone: AppCardTone.brand,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'A little help finding the right fit?',
                              style: context.text.titleMedium,
                            ),
                            const SizedBox(height: AppSpace.sm),
                            Text(
                              'Tell us your niche, audience and campaign goals. Our team can help you find the right publishers.',
                              style: context.text.bodySmall,
                            ),
                            const SizedBox(height: AppSpace.md),
                            AppButton(
                              label: 'Send an inquiry',
                              icon: Icons.mail_outline_rounded,
                              variant: AppButtonVariant.secondary,
                              onPressed: () => context.push('/inquiry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White search well stays legible on the navy hero in either app theme.
abstract final class AppThemeForSearch {
  static ThemeData of(BuildContext context) => Theme.of(context).copyWith(
    textTheme: Theme.of(context).textTheme.apply(
      bodyColor: AppPalette.light.text,
      displayColor: AppPalette.light.text,
    ),
    inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
      prefixIconColor: AppPalette.light.textMuted,
      hintStyle: context.text.bodyMedium?.copyWith(
        color: AppPalette.light.textMuted,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.brPill,
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _TopicRail extends StatelessWidget {
  const _TopicRail({required this.topics, required this.onSelected});
  final List<String> topics;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: (MediaQuery.textScalerOf(context).scale(20) + 24).clamp(48, 100),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: topics.length,
      separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
      itemBuilder: (context, i) => Center(
        child: ActionChip(
          label: Text(topics[i]),
          onPressed: () => onSelected(topics[i]),
          color: WidgetStatePropertyAll(
            i == 0 ? Colors.white : HeroPanel.onFaint,
          ),
          backgroundColor: i == 0 ? Colors.white : HeroPanel.onFaint,
          side: const BorderSide(color: HeroPanel.onFaint),
          labelStyle: context.text.labelMedium?.copyWith(
            color: i == 0 ? context.palette.heroStart : HeroPanel.on,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.sm,
            vertical: AppSpace.sm,
          ),
        ),
      ),
    ),
  );
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProductsProvider);
    return AnimatedSwitcher(
      duration: AppMotion.of(context),
      child: featured.when(
        loading: () => const SkeletonLoader(
          semanticLabel: 'Loading featured publishers',
          child: Column(
            children: [
              SkeletonBox(height: 132, radius: AppRadius.lg),
              SizedBox(height: AppSpace.sm),
              SkeletonBox(height: 132, radius: AppRadius.lg),
            ],
          ),
        ),
        error: (err, _) => AppCard(
          child: ErrorState(
            error: err,
            compact: true,
            onRetry: () => ref.invalidate(featuredProductsProvider),
          ),
        ),
        data: (page) => page.data.isEmpty
            ? const AppCard(
                tone: AppCardTone.sunken,
                child: Text(
                  'No featured publishers right now. Check back soon.',
                ),
              )
            : Column(
                children: [
                  for (var i = 0; i < page.data.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpace.sm),
                    ProductCard(
                      product: page.data[i],
                      onTap: () => context.push('/domain/${page.data[i].id}'),
                      onPlan: () => showPlacementSheet(context, page.data[i]),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TrustTiles extends StatelessWidget {
  const _TrustTiles();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = [
      (
        icon: Icons.sell_outlined,
        label: 'Trusted\npublishers',
        color: p.brandText,
      ),
      (icon: Icons.bolt_rounded, label: 'Clear\npricing', color: p.metricDr),
      (
        icon: Icons.shield_outlined,
        label: 'Private\nplanning',
        color: p.brandText,
      ),
      (
        icon: Icons.people_alt_outlined,
        label: 'Expert\nsupport',
        color: p.successText,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = MediaQuery.textScalerOf(context).scale(1) > 1.4 ? 2 : 4;
        final width =
            (constraints.maxWidth - AppSpace.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: AppCard(
                  tone: AppCardTone.sunken,
                  radius: AppRadius.md,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.xs,
                    vertical: AppSpace.md,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: p.tint(item.color),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.color, size: 20),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: context.text.labelSmall?.copyWith(
                          color: p.text,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: context.text.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.palette.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
