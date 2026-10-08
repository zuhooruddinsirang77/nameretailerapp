import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../../marketplace/data/product_repository.dart';
import '../../marketplace/providers/product_provider.dart';
import '../../marketplace/providers/shortlist_provider.dart';
import '../../marketplace/widgets/product_card.dart';

final featuredProductsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts(
    ProductFilterParams(sort: 'drDesc', pageSize: 6),
  );
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _quickTopics = const [
    {'name': 'Business', 'icon': Icons.business_center_outlined},
    {'name': 'Technology', 'icon': Icons.memory_outlined},
    {'name': 'Marketing', 'icon': Icons.campaign_outlined},
    {'name': 'Finance', 'icon': Icons.account_balance_outlined},
    {'name': 'Health', 'icon': Icons.health_and_safety_outlined},
    {'name': 'Travel', 'icon': Icons.flight_takeoff_outlined},
    {'name': 'E-commerce', 'icon': Icons.shopping_bag_outlined},
    {'name': 'Education', 'icon': Icons.school_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    ref.read(productFilterProvider.notifier).state =
        ProductFilterParams(query: query.trim(), page: 1);
    context.go('/marketplace');
  }

  void _filterTopic(String topic) {
    HapticFeedback.selectionClick();
    ref.read(productFilterProvider.notifier).state =
        ProductFilterParams(category: topic, page: 1);
    context.go('/marketplace');
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredProductsProvider);
    final shortlistCount = ref.watch(shortlistProvider).length;
    final cartCount = ref.watch(cartItemCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppDimens.space16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/logo_emblem.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NameRetailer',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  'Customer Marketplace',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: shortlistCount > 0,
              label: Text('$shortlistCount'),
              backgroundColor: AppColors.accentAmber,
              child: const Icon(Icons.bookmark_border_rounded),
            ),
            tooltip: 'Saved Publications',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/shortlist');
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppColors.accentEmerald,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            tooltip: 'Planning Cart',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/cart');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF131D33), const Color(0xFF0F172A)]
                        : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: AppColors.accentEmerald, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'DIRECT GUEST-POST PLACEMENTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Find the right publication for your next placement.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search 56,000+ real publishers with verified DR, DA, and transparent placement pricing.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Search Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: AppColors.textSecondaryLight, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: _search,
                              textInputAction: TextInputAction.search,
                              style: const TextStyle(
                                color: AppColors.textPrimaryLight,
                                fontSize: 13.5,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search domain, niche, or keyword…',
                                hintStyle: TextStyle(
                                  color: AppColors.textMutedLight,
                                  fontSize: 13.5,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            child: ElevatedButton(
                              onPressed: () => _search(_searchController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Explore',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Marketplace Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatPill('56,000+', 'Live Domains', isDark),
                    const SizedBox(width: 8),
                    _buildStatPill('80+', 'Countries', isDark),
                    const SizedBox(width: 8),
                    _buildStatPill('3–5 Days', 'Avg Turnaround', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Browse by Niche / Category
              AppSectionHeader(
                title: 'Browse by Publication Niche',
                subtitle: 'Filter top sites by industry and audience',
                actionText: 'View All',
                onActionTap: () => context.go('/marketplace'),
              ),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickTopics.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final topic = _quickTopics[index];
                    return ActionChip(
                      avatar: Icon(
                        topic['icon'] as IconData,
                        size: 16,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                      label: Text(topic['name'] as String),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      backgroundColor: isDark ? AppColors.surfaceDarkCard : Colors.white,
                      side: BorderSide(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      onPressed: () => _filterTopic(topic['name'] as String),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Featured Authority Publishers
              AppSectionHeader(
                title: 'Featured Authority Publishers',
                subtitle: 'High Domain Rating (DR) ready for guest placements',
                actionText: 'See All (56K+)',
                onActionTap: () => context.go('/marketplace'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: featuredAsync.when(
                  loading: () => Column(
                    children: List.generate(3, (_) => const ProductCardSkeleton()),
                  ),
                  error: (err, _) => AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 36, color: AppColors.accentAmber),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load featured publications',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please verify network connection and tap to retry.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Try Again',
                          icon: Icons.refresh,
                          size: AppButtonSize.small,
                          onPressed: () => ref.refresh(featuredProductsProvider),
                        ),
                      ],
                    ),
                  ),
                  data: (page) => Column(
                    children: page.data.map((product) {
                      return ProductCard(
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
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer Guarantees Section
              AppSectionHeader(
                title: 'Why Buyers Choose NameRetailer',
                subtitle: 'Built for agencies, brands, and SEO teams',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildFeatureCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Direct Publisher Placements',
                      description:
                          'Real publications with authentic traffic, indexed pages, and DoFollow link options.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      icon: Icons.price_check_outlined,
                      title: 'Transparent Pricing Structure',
                      description:
                          'Base placement and custom writing packages (500w–1000w) quoted clearly with no hidden fees.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Organized Planning Cart',
                      description:
                          'Draft and refine anchor text, target URLs, and special publisher notes prior to ordering.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Need Custom Domain Support Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDarkCard
                      : AppColors.accent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: AppColors.accent, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Custom Placement Help?',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Submit an inquiry for specific niche requirements or high-volume orders.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Inquire',
                      size: AppButtonSize.small,
                      variant: AppButtonVariant.subtle,
                      onPressed: () => context.push('/inquiry'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String value, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDarkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
            width: 1,
          ),
          boxShadow: AppDimens.shadowSubtle(isDark),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    height: 1.4,
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
