import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'pressable.dart';

/// Selectable card for mutually exclusive choices (writing package, payment
/// method, sort order). Announced as a radio button.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.semanticLabel,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? leadingIcon;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dur = AppMotion.of(context, AppMotion.fast);

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: semanticLabel ?? (subtitle == null ? title : '$title. $subtitle'),
      excludeSemantics: true,
      onTap: onTap,
      child: Pressable(
        onTap: onTap,
        scale: 0.985,
        child: AnimatedContainer(
          duration: dur,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            color: selected ? p.brandSoft : p.surface,
            borderRadius: AppRadius.brMd,
            border: Border.all(
              color: selected ? p.brand : p.borderStrong,
              width: selected ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadius.brMd,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpace.minTarget + 8,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.md + 2,
                    vertical: AppSpace.md,
                  ),
                  child: Row(
                    children: [
                      _RadioDot(selected: selected, duration: dur),
                      const SizedBox(width: AppSpace.md),
                      if (leadingIcon != null) ...[
                        Icon(
                          leadingIcon,
                          size: 22,
                          color: selected ? p.brandText : p.textSecondary,
                        ),
                        const SizedBox(width: AppSpace.sm),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: context.text.titleSmall),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: context.text.bodySmall?.copyWith(
                                  color: p.textMuted,
                                ),
                              ),
                            ],
                            if (trailing != null &&
                                MediaQuery.textScalerOf(context).scale(1) >
                                    1.3) ...[
                              const SizedBox(height: AppSpace.sm),
                              trailing!,
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null &&
                          MediaQuery.textScalerOf(context).scale(1) <= 1.3) ...[
                        const SizedBox(width: AppSpace.sm),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.duration});

  final bool selected;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedContainer(
      duration: duration,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? p.brand : p.borderStrong,
          width: selected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        duration: duration,
        scale: selected ? 1 : 0,
        curve: AppMotion.spring,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
