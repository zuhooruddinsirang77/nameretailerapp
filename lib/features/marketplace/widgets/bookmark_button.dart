import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../models/product.dart';
import '../providers/shortlist_provider.dart';

/// Shortlist toggle. 48dp target, animated state, announces its state to
/// screen readers and tells the user when the oldest saved item was dropped.
class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(
      shortlistProvider.select((l) => l.any((p) => p.id == product.id)),
    );
    final p = context.palette;
    final domain = Formatters.cleanDomain(product.domain);

    return IconButton(
      tooltip: saved
          ? 'Remove $domain from shortlist'
          : 'Save $domain to shortlist',
      isSelected: saved,
      onPressed: () {
        HapticFeedback.lightImpact();
        final notifier = ref.read(shortlistProvider.notifier);
        final full =
            !saved &&
            ref.read(shortlistProvider).length >= ShortlistNotifier.limit;
        notifier.toggle(product);
        if (full) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  'Your shortlist holds ${ShortlistNotifier.limit} publications – the oldest one was replaced.',
                ),
              ),
            );
        }
      },
      icon: AnimatedSwitcher(
        duration: AppMotion.of(context, AppMotion.fast),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(saved),
          color: saved ? p.warning : p.textMuted,
          size: 26,
        ),
      ),
    );
  }
}
