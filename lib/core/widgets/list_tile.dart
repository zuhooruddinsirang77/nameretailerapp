import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'card.dart';

/// Settings-style row: icon tile, title, supporting text, trailing widget.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = destructive ? p.dangerText : (iconColor ?? p.brandText);
    return Semantics(
      button: onTap != null,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: destructive ? p.dangerSoft : p.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: tone),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.text.titleSmall?.copyWith(
                          color: destructive ? p.dangerText : p.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.text.bodySmall?.copyWith(
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  Icon(Icons.chevron_right_rounded, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card that groups [AppListTile]s with hairline dividers.
class AppListGroup extends StatelessWidget {
  const AppListGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: AppSpace.lg + 32 + AppSpace.md,
                color: p.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
