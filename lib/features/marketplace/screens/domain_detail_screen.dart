import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../cart/screens/configure_placement_sheet.dart';
import '../models/placement_options.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/product_card.dart';

class DomainDetailScreen extends ConsumerWidget {
  const DomainDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(productId));
    final product = detailAsync.valueOrNull?['product'] as Product?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publication'),
        actions: [
          if (product != null) BookmarkButton(product: product),
          const SizedBox(width: AppSpace.xs),
        ],
      ),
      body: detailAsync.when(
        loading: () => const DetailSkeleton(),
        error: (err, _) => ErrorState(
          error: err,
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
        data: (data) => _DetailBody(
          product: data['product'] as Product,
          options: data['options'] as PlacementOptions?,
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.product, required this.options});

  final Product product;
  final PlacementOptions? options;

  Future<void> _visit() async {
    final uri = Uri.parse(
      product.domain.startsWith('http')
          ? product.domain
          : 'https://${product.domain}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final domain = Formatters.cleanDomain(product.domain);
    final m = product.metrics;
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.6
        ? 1
        : context.isWide
        ? 4
        : 2;
    final padding = context.pagePadding(top: AppSpace.sm);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: padding,
            children: [
              FadeSlideIn(
                child: _Header(
                  product: product,
                  domain: domain,
                  onVisit: _visit,
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              const SectionHeader(
                title: 'Authority',
                subtitle: 'How strongly search engines trust this site',
              ),
              const SizedBox(height: AppSpace.md),
              _MetricGrid(
                columns: columns,
                children: [
                  MetricTile(
                    kind: MetricKind.dr,
                    value: m.dr,
                    icon: Icons.star_outline_rounded,
                    gauge: true,
                  ),
                  MetricTile(
                    kind: MetricKind.da,
                    value: m.da,
                    icon: Icons.shield_outlined,
                    gauge: true,
                  ),
                  MetricTile(
                    kind: MetricKind.tf,
                    value: m.tf,
                    icon: Icons.verified_outlined,
                    gauge: true,
                  ),
                  MetricTile(
                    kind: MetricKind.ur,
                    value: m.ur,
                    icon: Icons.link_rounded,
                    gauge: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              const SectionHeader(
                title: 'Audience & links',
                subtitle: 'Reach and backlink profile',
              ),
              const SizedBox(height: AppSpace.md),
              _MetricGrid(
                columns: columns,
                children: [
                  MetricTile(
                    kind: MetricKind.traffic,
                    value: m.traffic,
                    icon: Icons.trending_up_rounded,
                  ),
                  MetricTile(
                    kind: MetricKind.refDomains,
                    value: m.referringDomains,
                    icon: Icons.hub_outlined,
                  ),
                  MetricTile(
                    kind: MetricKind.backlinks,
                    value: m.backlinks,
                    icon: Icons.all_inclusive_rounded,
                  ),
                  _RiskTile(score: m.spamScore),
                ],
              ),
              const SizedBox(height: AppSpace.xl),
              const SectionHeader(
                title: 'Placement requirements',
                subtitle: 'What to expect when you publish here',
              ),
              const SizedBox(height: AppSpace.md),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _TermRow(
                      icon: Icons.link_rounded,
                      label: 'Link attribute',
                      value: product.linkType,
                    ),
                    Divider(height: 1, color: p.border),
                    _TermRow(
                      icon: Icons.schedule_rounded,
                      label: 'Turnaround',
                      value: product.turnaround,
                    ),
                    Divider(height: 1, color: p.border),
                    _TermRow(
                      icon: Icons.translate_rounded,
                      label: 'Language',
                      value: product.language,
                    ),
                    Divider(height: 1, color: p.border),
                    _TermRow(
                      icon: Icons.description_outlined,
                      label: 'Editorial guidelines',
                      value: product.requirements.isNotEmpty
                          ? product.requirements
                          : 'Standard editorial fit required. Articles must be informational and follow the publisher’s niche standards.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              const InlineMessage(
                message:
                    'Metrics are periodically refreshed. Always confirm content relevance and anchor fit before publishing.',
              ),
              const SizedBox(height: AppSpace.lg),
            ],
          ),
        ),
        PriceSummaryBar(
          label: 'Placement from',
          cents: product.priceCents,
          actionLabel: 'Plan placement',
          actionIcon: Icons.assignment_turned_in_outlined,
          leading: IconButton.outlined(
            tooltip: 'Send an inquiry about $domain',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/inquiry?domain=${Uri.encodeComponent(domain)}');
            },
            icon: const Icon(Icons.mail_outline_rounded),
            style: IconButton.styleFrom(
              minimumSize: const Size.square(AppSpace.minTarget + 4),
              side: BorderSide(color: p.borderStrong),
            ),
          ),
          onAction: () {
            HapticFeedback.mediumImpact();
            showPlacementSheet(context, product, options: options);
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.product,
    required this.domain,
    required this.onVisit,
  });

  final Product product;
  final String domain;
  final VoidCallback onVisit;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: domainHeroTag(product.id),
                flightShuttleBuilder: (_, _, _, _, toContext) => Material(
                  type: MaterialType.transparency,
                  child: (toContext.widget as Hero).child,
                ),
                child: DomainAvatar(domain: product.domain, size: 52),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: context.text.labelMedium?.copyWith(
                        color: p.brandText,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Semantics(
                      header: true,
                      child: Text(
                        domain,
                        style: context.text.headlineMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              TagChip(label: product.country, icon: Icons.public_rounded),
              TagChip(label: product.language, icon: Icons.translate_rounded),
              TagChip(label: product.turnaround, icon: Icons.schedule_rounded),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _VisitButton(domain: domain, onTap: onVisit),
        ],
      ),
    );
  }
}

class _VisitButton extends StatelessWidget {
  const _VisitButton({required this.domain, required this.onTap});

  final String domain;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Visit publication',
      trailingIcon: Icons.open_in_new_rounded,
      variant: AppButtonVariant.outline,
      expand: true,
      semanticLabel: 'Visit $domain in your browser',
      onPressed: onTap,
    );
  }
}

/// Lays children out in equal-height rows of [columns] without fixed aspect
/// ratios, so tiles grow with text size.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(
        i,
        (i + columns).clamp(0, children.length),
      );
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) const SizedBox(width: AppSpace.md),
                Expanded(
                  child: j < slice.length ? slice[j] : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
      if (i + columns < children.length) {
        rows.add(const SizedBox(height: AppSpace.md));
      }
    }
    return Column(children: rows);
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.score});

  final int? score;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final high = (score ?? 0) > 30;
    return Stack(
      children: [
        MetricTile(
          kind: MetricKind.spam,
          value: score,
          icon: Icons.security_outlined,
          title: 'Spam score',
          gauge: true,
        ),
        if (score != null)
          Positioned(
            top: AppSpace.sm,
            right: AppSpace.sm,
            child: ExcludeSemantics(
              child: Icon(
                high ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                size: 18,
                color: high ? p.dangerText : p.successText,
              ),
            ),
          ),
      ],
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: p.brandText),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.text.labelMedium?.copyWith(
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: context.text.bodyMedium?.copyWith(color: p.text),
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
