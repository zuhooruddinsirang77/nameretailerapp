import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

enum MessageTone { info, success, warning, danger }

/// In-flow banner for notices, validation summaries and request errors.
class InlineMessage extends StatelessWidget {
  const InlineMessage({
    super.key,
    required this.message,
    this.title,
    this.tone = MessageTone.info,
    this.icon,
    this.action,
  });

  final String message;
  final String? title;
  final MessageTone tone;
  final IconData? icon;

  /// Optional trailing widget, typically a [TextButton].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color bg, Color fg, Color line, IconData defaultIcon) = switch (tone) {
      MessageTone.info => (
          p.infoSoft,
          p.infoText,
          p.info.withValues(alpha: 0.3),
          Icons.info_outline_rounded,
        ),
      MessageTone.success => (
          p.successSoft,
          p.successText,
          p.success.withValues(alpha: 0.35),
          Icons.check_circle_outline_rounded,
        ),
      MessageTone.warning => (
          p.warningSoft,
          p.warningText,
          p.warning.withValues(alpha: 0.4),
          Icons.warning_amber_rounded,
        ),
      MessageTone.danger => (
          p.dangerSoft,
          p.dangerText,
          p.danger.withValues(alpha: 0.35),
          Icons.error_outline_rounded,
        ),
    };

    return Semantics(
      container: true,
      liveRegion: tone == MessageTone.danger || tone == MessageTone.success,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon ?? defaultIcon, size: 20, color: fg),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: context.text.titleSmall?.copyWith(color: fg),
                    ),
                  Text(
                    message,
                    style: context.text.bodySmall?.copyWith(
                      color: p.text,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
