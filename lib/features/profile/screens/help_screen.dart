import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final items = <({IconData icon, Color color, String title, String body})>[
      (
        icon: Icons.people_outline_rounded,
        color: p.brandText,
        title: 'Audience before raw scores',
        body:
            'Evaluate topical relevance, target country and language fit first. DR, DA, TF and estimated visits are useful signals, but they do not guarantee editorial fit or specific ranking results.',
      ),
      (
        icon: Icons.edit_note_rounded,
        color: p.successText,
        title: 'Content and placement separation',
        body:
            'Placement fees secure editorial review and publishing on the chosen site. If you add our writing service (500, 750 or 1,000 words), the article is written from your brief to match the site’s editorial standards.',
      ),
      (
        icon: Icons.timelapse_rounded,
        color: p.warningText,
        title: 'Turnaround expectations',
        body:
            'Typical turnaround is 3 to 5 business days from when your brief is confirmed. Editorial schedules can shift around local holidays and weekends.',
      ),
      (
        icon: Icons.shield_outlined,
        color: p.metricDr,
        title: 'Planning cart vs. order draft',
        body:
            'Adding to your cart saves your configuration privately. Creating an order draft reserves your proposal for 7 days without taking payment.',
      ),
      (
        icon: Icons.link_rounded,
        color: p.brandText,
        title: 'DoFollow link guidelines',
        body:
            'Publications typically allow up to 2 DoFollow links in natural editorial context. Over-optimised anchors, promotional disclaimers or off-topic landing pages may be rejected.',
      ),
      (
        icon: Icons.support_agent_outlined,
        color: p.successText,
        title: 'Need a custom volume or tier?',
        body:
            'For bulk campaigns or outreach not in the catalog, send an inquiry and our team will coordinate a tailored plan.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Buyer guide & FAQ')),
      body: ListView(
        padding: context.pagePadding(top: AppSpace.sm),
        children: [
          const ScreenIntro(
            eyebrow: 'Help & guidance',
            icon: Icons.help_outline_rounded,
            title: 'Buy with confidence.',
            message: 'Answers to the questions buyers ask most.',
          ),
          const SizedBox(height: AppSpace.lg),
          for (var i = 0; i < items.length; i++) ...[
            _FaqTile(
              icon: items[i].icon,
              color: items[i].color,
              title: items[i].title,
              body: items[i].body,
              initiallyExpanded: i == 0,
            ),
            const SizedBox(height: AppSpace.md),
          ],
          const SizedBox(height: AppSpace.sm),
          AppCard(
            tone: AppCardTone.brand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Still have a question?', style: context.text.titleMedium),
                const SizedBox(height: AppSpace.xs),
                Text(
                  'Send us your question and our team will get back to you.',
                  style: context.text.bodySmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                AppButton(
                  label: 'Contact us',
                  icon: Icons.mail_outline_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/inquiry'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.initiallyExpanded,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          expansionAnimationStyle: AnimationStyle(
            duration: AppMotion.of(context),
          ),
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpace.lg,
            0,
            AppSpace.lg,
            AppSpace.lg,
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.tint(color),
              borderRadius: AppRadius.brMd,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          title: Text(title, style: context.text.titleSmall),
          children: [Text(body, style: context.text.bodyMedium)],
        ),
      ),
    );
  }
}
