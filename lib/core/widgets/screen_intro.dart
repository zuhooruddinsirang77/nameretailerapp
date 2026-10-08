import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// A compact introduction that keeps the first useful action within reach.
class ScreenIntro extends StatelessWidget {
  const ScreenIntro({
    super.key,
    required this.title,
    required this.message,
    this.eyebrow,
    this.icon,
  });

  final String title;
  final String message;
  final String? eyebrow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null || icon != null) ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: p.brandText),
                const SizedBox(width: AppSpace.sm),
              ],
              if (eyebrow != null)
                Expanded(
                  child: Text(
                    eyebrow!,
                    style: context.text.labelMedium?.copyWith(
                      color: p.brandText,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
        ],
        Semantics(
          header: true,
          child: Text(title, style: context.text.headlineLarge),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(message, style: context.text.bodyMedium),
      ],
    );
  }
}
