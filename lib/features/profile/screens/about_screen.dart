import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: context.pagePadding(top: AppSpace.lg),
        children: [
          AppCard(
            child: Row(
              children: [
                const BrandMark(size: 48),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'NameRetailer',
                          style: context.text.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Guest-post marketplace',
                        style: context.text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Built for quality placements',
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  'NameRetailer brings high-authority publications together with verified audience metrics, transparent pricing and optional bespoke copywriting, so marketing teams can scale guest-post campaigns with confidence.',
                  style: context.text.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          const _Pillar(
            icon: Icons.language_rounded,
            title: '56,000+ vetted publications',
            body:
                'Filter by topic, country, language and real Domain Authority, Domain Rating and organic traffic.',
          ),
          const SizedBox(height: AppSpace.md),
          const _Pillar(
            icon: Icons.edit_note_rounded,
            title: 'Content and placement, separated',
            body:
                'Placement fees are quoted up front. Optional 500, 750 or 1,000-word articles are written for your target publisher.',
          ),
          const SizedBox(height: AppSpace.md),
          const _Pillar(
            icon: Icons.lock_clock_outlined,
            title: 'Private 7-day planning drafts',
            body:
                'Build a media plan with live pricing and hold it as a draft without any pressure to pay.',
          ),
          const SizedBox(height: AppSpace.xl),
          AppCard(
            tone: AppCardTone.sunken,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 18,
                      color: p.successText,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Overline('Corporate entity', color: p.successText),
                  ],
                ),
                const SizedBox(height: AppSpace.sm),
                Text('Name Retailer FZE', style: context.text.titleMedium),
                const SizedBox(height: AppSpace.xs),
                Text(
                  '26 - G Hamriyah Freezone\nSharjah, United Arab Emirates\ninfo@nameretailer.com',
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Center(
            child: Text(
              'Customer mobile edition · v1.0.0',
              style: context.text.bodySmall?.copyWith(color: p.textMuted),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

class _Pillar extends StatelessWidget {
  const _Pillar({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
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
            child: Icon(icon, size: 20, color: p.brandText),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
