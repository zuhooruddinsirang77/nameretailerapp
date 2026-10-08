import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../marketplace/models/placement_options.dart';
import '../../marketplace/models/product.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';

class ConfigurePlacementSheet extends ConsumerStatefulWidget {
  final Product product;
  final PlacementOptions? options;

  const ConfigurePlacementSheet({
    super.key,
    required this.product,
    this.options,
  });

  @override
  ConsumerState<ConfigurePlacementSheet> createState() =>
      _ConfigurePlacementSheetState();
}

class _ConfigurePlacementSheetState
    extends ConsumerState<ConfigurePlacementSheet> {
  int _writingWords = 0; // 0, 500, 750, 1000
  final _urlController = TextEditingController();
  final _keywordController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _articleController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _urlController.dispose();
    _keywordController.dispose();
    _instructionsController.dispose();
    _articleController.dispose();
    super.dispose();
  }

  int get _writingPriceCents {
    if (_writingWords == 0) return 0;
    if (widget.options != null) {
      final opt = widget.options!.writingOptions.firstWhere(
        (o) => o.words == _writingWords,
        orElse: () => WritingOption(words: _writingWords, priceCents: 0),
      );
      return opt.priceCents;
    }
    return _writingWords == 500
        ? 3500
        : _writingWords == 750
            ? 5000
            : 6500;
  }

  int get _totalPriceCents => widget.product.priceCents + _writingPriceCents;

  Future<void> _savePlacement() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to save placements to your planning cart.'),
          backgroundColor: AppColors.warning,
        ),
      );
      context.push('/login');
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final cartItem = CartItem(
      productId: widget.product.id,
      productVersion: widget.product.version,
      writingWords: _writingWords,
      domain: widget.product.domain,
      placementCents: widget.product.priceCents,
      writingCents: _writingPriceCents,
      totalCents: _totalPriceCents,
      status: 'ready',
      options: widget.options,
      brief: PlacementBrief(
        promotedUrl: _urlController.text.trim(),
        keyword: _keywordController.text.trim(),
        specialRequirements: _instructionsController.text.trim(),
        articleText: _articleController.text.trim(),
      ),
    );

    final success = await ref.read(cartProvider.notifier).saveItem(cartItem);
    setState(() => _saving = false);

    if (mounted) {
      Navigator.of(context).pop();
      if (success) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Formatters.cleanDomain(widget.product.domain)} added to planning cart.',
            ),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update cart. Please check network connection.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanDomain = Formatters.cleanDomain(widget.product.domain);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXl)),
      ),
      padding: EdgeInsets.only(
        top: AppDimens.space16,
        left: AppDimens.space20,
        right: AppDimens.space20,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.space20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab Handle
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
            const SizedBox(height: 14),

            // Modal Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CUSTOMIZE PLACEMENT',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cleanDomain,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Writing Service Package
            Text(
              'Editorial Writing Package',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Select whether you supply the draft or want professional article creation.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),

            _buildWritingOption(
              words: 0,
              title: 'Provide My Own Article',
              subtitle: 'You supply pre-written article ready for editorial review',
              priceCents: 0,
            ),
            _buildWritingOption(
              words: 500,
              title: '500-Word Standard Placement',
              subtitle: 'Researched & written specifically for this publication niche',
              priceCents: widget.options?.writingOptions.firstWhere((o) => o.words == 500, orElse: () => WritingOption(words: 500, priceCents: 3500)).priceCents ?? 3500,
            ),
            _buildWritingOption(
              words: 750,
              title: '750-Word Long-Form Article',
              subtitle: 'In-depth topical article with editorial context & natural flow',
              priceCents: widget.options?.writingOptions.firstWhere((o) => o.words == 750, orElse: () => WritingOption(words: 750, priceCents: 5000)).priceCents ?? 5000,
            ),
            _buildWritingOption(
              words: 1000,
              title: '1,000-Word Comprehensive Authority Guide',
              subtitle: 'Authoritative deep-dive with subheadings and thorough analysis',
              priceCents: widget.options?.writingOptions.firstWhere((o) => o.words == 1000, orElse: () => WritingOption(words: 1000, priceCents: 6500)).priceCents ?? 6500,
            ),
            const SizedBox(height: 18),

            // Placement Brief Fields
            Text(
              'Placement Brief & Anchor Text',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: const InputDecoration(
                labelText: 'Target URL to Promoted Page',
                hintText: 'https://example.com/target-landing-page',
                prefixIcon: Icon(Icons.link_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _keywordController,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: const InputDecoration(
                labelText: 'Target Keyword / Anchor Text',
                hintText: 'e.g. enterprise CRM software',
                prefixIcon: Icon(Icons.text_fields_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _instructionsController,
              maxLines: 2,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: const InputDecoration(
                labelText: 'Editorial Guidelines / Notes (Optional)',
                hintText: 'Any specific talking points, brand rules, or instructions…',
              ),
            ),
            const SizedBox(height: 10),

            if (_writingWords == 0) ...[
              TextField(
                controller: _articleController,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 13.5,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                decoration: const InputDecoration(
                  labelText: 'Paste Supplied Article Content',
                  hintText: 'Paste your headline and body content here…',
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Pricing summary card
            Container(
              padding: const EdgeInsets.all(AppDimens.space14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkCard : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Base Placement Fee:',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(widget.product.priceCents),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (_writingWords > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Writing Package ($_writingWords words):',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(_writingPriceCents),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Planning Rate:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        Formatters.formatCurrency(_totalPriceCents),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentEmerald,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Save CTA Button
            AppButton(
              text: 'Save to Planning Cart',
              icon: Icons.shopping_bag_outlined,
              isLoading: _saving,
              size: AppButtonSize.large,
              isFullWidth: true,
              onPressed: _savePlacement,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingOption({
    required int words,
    required String title,
    required String subtitle,
    required int priceCents,
  }) {
    final isSelected = _writingWords == words;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _writingWords = words);
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08)
              : (isDark ? AppColors.surfaceDarkCard : Colors.white),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected
                  ? AppColors.accent
                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                priceCents == 0 ? 'Included' : '+${Formatters.formatCurrency(priceCents)}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.accent : AppColors.accentEmerald,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
