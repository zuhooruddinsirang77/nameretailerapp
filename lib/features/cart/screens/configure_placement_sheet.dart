import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../marketplace/models/placement_options.dart';
import '../../marketplace/models/product.dart';
import '../models/cart.dart';
import '../providers/cart_provider.dart';

/// Opens the "Plan placement" sheet for [product].
Future<void> showPlacementSheet(
  BuildContext context,
  Product product, {
  PlacementOptions? options,
}) {
  return showAppSheetRaw<void>(
    context,
    builder: (_) => ConfigurePlacementSheet(product: product, options: options),
  );
}

class ConfigurePlacementSheet extends ConsumerStatefulWidget {
  const ConfigurePlacementSheet({
    super.key,
    required this.product,
    this.options,
  });

  final Product product;
  final PlacementOptions? options;

  @override
  ConsumerState<ConfigurePlacementSheet> createState() =>
      _ConfigurePlacementSheetState();
}

class _ConfigurePlacementSheetState
    extends ConsumerState<ConfigurePlacementSheet> {
  final _formKey = GlobalKey<FormState>();
  int _writingWords = 0; // 0, 500, 750, 1000
  final _urlController = TextEditingController();
  final _keywordController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _articleController = TextEditingController();
  final _keywordFocus = FocusNode();
  final _notesFocus = FocusNode();
  final _articleFocus = FocusNode();
  bool _saving = false;

  static const _defaultPrices = {500: 3500, 750: 5000, 1000: 6500};

  @override
  void dispose() {
    _urlController.dispose();
    _keywordController.dispose();
    _instructionsController.dispose();
    _articleController.dispose();
    _keywordFocus.dispose();
    _notesFocus.dispose();
    _articleFocus.dispose();
    super.dispose();
  }

  int _priceFor(int words) {
    if (words == 0) return 0;
    final fallback = _defaultPrices[words] ?? 0;
    final opts = widget.options;
    if (opts != null) {
      return opts.writingOptions
          .firstWhere(
            (o) => o.words == words,
            orElse: () => WritingOption(words: words, priceCents: 0),
          )
          .priceCents;
    }
    return fallback;
  }

  int get _writingPriceCents => _priceFor(_writingWords);

  int get _totalPriceCents => widget.product.priceCents + _writingPriceCents;

  String? _validateUrl(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    final looksValid = RegExp(
      r'^(https?://)?([\w-]+\.)+[a-zA-Z]{2,}(:\d+)?(/\S*)?$',
    ).hasMatch(value);
    return looksValid
        ? null
        : 'Enter a full link, e.g. https://example.com/page';
  }

  Future<void> _savePlacement() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please sign in to save placements to your planning cart.',
          ),
        ),
      );
      context.push('/login');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
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

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final domainName = Formatters.cleanDomain(widget.product.domain);
    final success = await ref.read(cartProvider.notifier).saveItem(cartItem);
    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.of(context).pop();
    if (success) {
      HapticFeedback.lightImpact();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$domainName added to your planning cart.'),
            action: SnackBarAction(
              label: 'View cart',
              onPressed: () => router.go('/cart'),
            ),
          ),
        );
    } else {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              "We couldn't update your cart. Check your connection and try again.",
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final domainName = Formatters.cleanDomain(widget.product.domain);
    final writing = _writingPriceCents;

    final packages = <({int words, String title, String subtitle})>[
      (
        words: 0,
        title: 'I will provide the article',
        subtitle: 'Supply a finished draft for editorial review',
      ),
      (
        words: 500,
        title: '500-word article',
        subtitle: 'Written for this publication’s niche',
      ),
      (
        words: 750,
        title: '750-word long-form',
        subtitle: 'In-depth, with editorial context',
      ),
      (
        words: 1000,
        title: '1,000-word authority guide',
        subtitle: 'Subheadings and thorough analysis',
      ),
    ];

    return AppSheetFrame(
      title: 'Plan placement',
      subtitle: domainName,
      footer: PriceActionRow(
        label: 'Total',
        cents: _totalPriceCents,
        caption: writing > 0
            ? '${Formatters.formatCurrency(widget.product.priceCents)} placement + ${Formatters.formatCurrency(writing)} writing'
            : 'Placement fee only',
        actionLabel: 'Save to cart',
        actionIcon: Icons.shopping_bag_outlined,
        loading: _saving,
        onAction: _savePlacement,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Article content'),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Choose whether you supply the content or we write it.',
              style: context.text.bodySmall?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: AppSpace.md),
            for (final pkg in packages) ...[
              ChoiceTile(
                selected: _writingWords == pkg.words,
                title: pkg.title,
                subtitle: pkg.subtitle,
                semanticLabel:
                    '${pkg.title}. ${pkg.subtitle}. ${_priceFor(pkg.words) == 0 ? 'Included' : Formatters.formatCurrency(_priceFor(pkg.words))}',
                trailing: _PriceTag(
                  cents: _priceFor(pkg.words),
                  selected: _writingWords == pkg.words,
                ),
                onTap: () => setState(() => _writingWords = pkg.words),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            const SizedBox(height: AppSpace.lg),
            const SectionHeader(title: 'Placement brief'),
            const SizedBox(height: AppSpace.xs),
            Text(
              'Tell the publisher what to link to and how.',
              style: context.text.bodySmall?.copyWith(color: p.textMuted),
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: _urlController,
              label: 'Page to promote',
              hint: 'https://example.com/landing-page',
              icon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.url],
              validator: _validateUrl,
              onSubmitted: (_) => _keywordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: _keywordController,
              focusNode: _keywordFocus,
              label: 'Anchor text / keyword',
              hint: 'e.g. enterprise CRM software',
              icon: Icons.text_fields_rounded,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _notesFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: _instructionsController,
              focusNode: _notesFocus,
              label: 'Notes for the editor (optional)',
              hint: 'Talking points, brand rules, tone…',
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: _writingWords == 0
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: (_) => _writingWords == 0
                  ? _articleFocus.requestFocus()
                  : FocusScope.of(context).unfocus(),
            ),
            MotionSize(
              duration: AppMotion.of(context, AppMotion.base),
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: _writingWords == 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpace.md),
                      child: AppTextField(
                        controller: _articleController,
                        focusNode: _articleFocus,
                        label: 'Your article',
                        hint: 'Paste the headline and body here…',
                        minLines: 4,
                        maxLines: 8,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.cents, required this.selected});

  final int cents;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? p.surface : p.surfaceAlt,
        borderRadius: AppRadius.brSm,
      ),
      child: Text(
        cents == 0 ? 'Included' : '+${Formatters.formatCurrency(cents)}',
        style: context.text.labelMedium?.copyWith(
          color: cents == 0 ? p.textSecondary : p.price,
        ),
      ),
    );
  }
}
