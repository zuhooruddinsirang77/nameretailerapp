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
import '../widgets/featured_card.dart';

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

  static const List<({String name, IconData icon})> _quickTopics = [
    (name: 'Business', icon: Icons.business_center_outlined),
    (name: 'Technology', icon: Icons.memory_outlined),
    (name: 'Marketing', icon: Icons.campaign_outlined),
    (name: 'Finance', icon: Icons.account_balance_outlined),
    (name: 'Health', icon: Icons.health_and_safety_outlined),
    (name: 'Travel', icon: Icons.flight_takeoff_outlined),
    (name: 'E-commerce', icon: Icons.shopping_bag_outlined),
    (name: 'Education', icon: Icons.school_outlined),
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
      // The section renders its own error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortlistCount = ref.watch(shortlistProvider.select((l) => l.length));
    final cartCount = ref.watch(cartItemCountProvider);
    final padding = context.pagePadding(top: AppSpace.sm);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: (MediaQuery.textScalerOf(context).scale(42) + 12)
                  .clamp(68, double.infinity),
              titleSpacing: AppSpace.gutter,
              title: Row(
                children: [
                  const BrandMark(size: 36),
                  const SizedBox(width: AppSpace.md),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NameRetailer',
                          style: context.text.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Publisher marketplace',
                          style: context.text.labelSmall?.copyWith(
                            color: context.palette.textMuted,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Saved publications',
                  icon: CountBadge(
                    count: shortlistCount,
                    semanticLabel: '$shortlistCount saved',
                    child: const Icon(Icons.bookmark_border_rounded),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/shortlist');
                  },
                ),
                IconButton(
                  tooltip: 'Planning cart',
                  icon: CountBadge(
                    count: cartCount,
                    semanticLabel: '$cartCount in cart',
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/cart');
                  },
                ),
                const SizedBox(width: AppSpace.xs),
              ],
            ),
            SliverPadding(
              padding: padding,
              sliver: SliverList.list(
                children: [
                  FadeSlideIn(
                    child: _Hero(
                      controller: _searchController,
                      onSearch: _search,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),
                  SectionHeader(
                    title: 'Browse by niche',
                    subtitle: 'Find publishers in your industry',
                    actionLabel: 'All',
                    onAction: () => context.go('/marketplace'),
                  ),
                  const SizedBox(height: AppSpace.md),
                  _TopicRail(topics: _quickTopics, onSelected: _filterTopic),
                  const SizedBox(height: AppSpace.xl),
                  SectionHeader(
                    title: 'Featured publishers',
                    subtitle: 'Leading publications by Domain Rating',
                    actionLabel: 'See all',
                    onAction: () => context.go('/marketplace'),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _FeaturedSection(horizontalInset: padding.left),
            ),
            SliverPadding(
              padding: padding.copyWith(top: AppSpace.xl),
              sliver: SliverList.list(
                children: [
                  const SectionHeader(
                    title: 'Why buyers choose us',
                    subtitle: 'Built for agencies, brands and SEO teams',
                  ),
                  const SizedBox(height: AppSpace.md),
                  const _ValueProps(),
                  const SizedBox(height: AppSpace.xl),
                  AppCard(
                    tone: AppCardTone.brand,
                    child: _HelpBanner(
                      onInquire: () => context.push('/inquiry'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Overline('Direct guest-post placements', color: p.brandText),
        const SizedBox(height: AppSpace.md),
        Semantics(
          header: true,
          child: Text(
            'Your next placement\nstarts here.',
            style: context.text.displayMedium,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Discover publishers that fit your audience, with clear metrics and placement pricing.',
          style: context.text.bodyMedium,
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: AppSearchField(
                controller: controller,
                hint: 'Search a domain or niche',
                onSubmitted: onSearch,
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            IconButton.filled(
              tooltip: 'Search',
              onPressed: () => onSearch(controller.text),
              style: IconButton.styleFrom(
                minimumSize: const Size.square(AppSpace.minTarget + 4),
                backgroundColor: p.brand,
                foregroundColor: p.onBrand,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brLg,
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        const AppCard(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.md,
            vertical: AppSpace.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroStat(value: '56,000+', label: 'Live domains'),
              _HeroDivider(),
              _HeroStat(value: '80+', label: 'Countries'),
              _HeroDivider(),
              _HeroStat(value: '3–5 days', label: 'Avg turnaround'),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$value $label',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                color: context.palette.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
    color: context.palette.border,
  );
}

class _TopicRail extends StatelessWidget {
  const _TopicRail({required this.topics, required this.onSelected});

  final List<({String name, IconData icon})> topics;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // Height follows the user's text size so labels never clip.
    final height = MediaQuery.textScalerOf(context).scale(24) + 24;
    return SizedBox(
      height: height.clamp(AppSpace.minTarget, 120),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: topics.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
        itemBuilder: (context, i) {
          final t = topics[i];
          return Semantics(
            button: true,
            label: 'Browse ${t.name} publications',
            excludeSemantics: true,
            child: Pressable(
              onTap: () => onSelected(t.name),
              child: Material(
                color: p.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.brMd,
                  side: BorderSide(color: p.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelected(t.name),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.lg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.icon, size: 18, color: p.brandText),
                        const SizedBox(width: AppSpace.sm),
                        Text(t.name, style: context.text.labelLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedSection extends ConsumerWidget {
  const _FeaturedSection({required this.horizontalInset});

  final double horizontalInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProductsProvider);

    return AnimatedSwitcher(
      duration: AppMotion.of(context),
      child: featured.when(
        loading: () => SkeletonLoader(
          key: const ValueKey('loading'),
          semanticLabel: 'Loading featured publishers',
          child: _Rail(
            inset: horizontalInset,
            children: const [FeaturedCardSkeleton(), FeaturedCardSkeleton()],
          ),
        ),
        error: (err, _) => Padding(
          key: const ValueKey('error'),
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: AppCard(
            child: ErrorState(
              error: err,
              compact: true,
              onRetry: () => ref.invalidate(featuredProductsProvider),
            ),
          ),
        ),
        data: (page) {
          if (page.data.isEmpty) {
            return Padding(
              key: const ValueKey('empty'),
              padding: EdgeInsets.symmetric(horizontal: horizontalInset),
              child: const AppCard(
                tone: AppCardTone.sunken,
                child: Text(
                  'No featured publishers right now. Check back soon.',
                ),
              ),
            );
          }
          return _Rail(
            key: const ValueKey('data'),
            inset: horizontalInset,
            children: [
              for (final product in page.data)
                FeaturedCard(
                  product: product,
                  onTap: () => context.push('/domain/${product.id}'),
                  onPlan: () => showPlacementSheet(context, product),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Content-sized rail; cards grow naturally with the system text size.
class _Rail extends StatelessWidget {
  const _Rail({super.key, required this.inset, required this.children});

  final double inset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: inset),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpace.md),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ValueProps extends StatelessWidget {
  const _ValueProps();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const items = [
      (
        icon: Icons.verified_user_outlined,
        title: 'Direct publisher placements',
        body:
            'Real publications with authentic traffic, indexed pages and DoFollow options.',
      ),
      (
        icon: Icons.price_check_outlined,
        title: 'Transparent pricing',
        body:
            'Placement and optional writing (500w–1000w) are quoted clearly, with no hidden fees.',
      ),
      (
        icon: Icons.assignment_turned_in_outlined,
        title: 'An organised planning cart',
        body:
            'Draft anchor text, target URLs and publisher notes before you order.',
      ),
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: p.border),
            Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.brandSoft,
                      borderRadius: AppRadius.brMd,
                    ),
                    child: Icon(items[i].icon, size: 20, color: p.brandText),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].title, style: context.text.titleSmall),
                        const SizedBox(height: 2),
                        Text(items[i].body, style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpBanner extends StatelessWidget {
  const _HelpBanner({required this.onInquire});

  final VoidCallback onInquire;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.support_agent_rounded, color: p.brandText),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                'Need custom placement help?',
                style: context.text.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          'Tell us about niche requirements or high-volume orders and our team will line up the right publishers.',
          style: context.text.bodySmall?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: AppSpace.md),
        AppButton(
          label: 'Send an inquiry',
          icon: Icons.mail_outline_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: onInquire,
        ),
      ],
    );
  }
}
