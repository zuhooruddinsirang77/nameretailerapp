import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import '../utils/error_messages.dart';
import 'button.dart';

/// Centred, friendly "nothing here yet" view.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
    this.tint,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = tint ?? p.brandText;
    return _CenteredMessage(
      icon: icon,
      iconColor: color,
      iconBackground: p.tint(color, light: 0.1, dark: 0.16),
      title: title,
      message: message,
      actions: [
        if (actionLabel != null && onAction != null)
          AppButton(label: actionLabel!, onPressed: onAction),
        if (secondaryLabel != null && onSecondary != null)
          AppButton(
            label: secondaryLabel!,
            onPressed: onSecondary,
            variant: AppButtonVariant.text,
          ),
      ],
    );
  }
}

/// Error view with a retry action. Distinguishes "offline" from other errors.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.compact = false,
  });

  final Object? error;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  /// Smaller inline version for use inside cards / sections.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final info = describeError(error);
    final color = info.offline ? p.warningText : p.dangerText;
    final icon = info.offline
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;
    final shownTitle = title ?? info.title;
    final shownMessage = message ?? info.message;
    final retry = onRetry == null
        ? null
        : AppButton(
            label: 'Try again',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            variant: compact
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
          );

    if (compact) {
      return Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpace.sm),
            Text(
              shownTitle,
              style: context.text.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              shownMessage,
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (retry != null) ...[const SizedBox(height: AppSpace.md), retry],
          ],
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      child: _CenteredMessage(
        icon: icon,
        iconColor: color,
        iconBackground: info.offline ? p.warningSoft : p.dangerSoft,
        title: shownTitle,
        message: shownMessage,
        actions: [?retry],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    required this.actions,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // Scrollable so it never overflows with large text or short viewports.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: AppRadius.brLg,
                        border: Border.all(
                          color: iconColor.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Icon(icon, size: 32, color: iconColor),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: context.text.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      message,
                      style: context.text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xl),
                      for (final a in actions) ...[
                        a,
                        const SizedBox(height: AppSpace.xs),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
