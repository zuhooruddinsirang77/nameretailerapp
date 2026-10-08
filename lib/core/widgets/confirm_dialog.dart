import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'button.dart';

/// Asks the user to confirm an action. Resolves to `true` only when the
/// primary button is pressed; dismissing or cancelling yields `false`.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      icon: icon,
    ),
  );
  return result ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tone = destructive ? p.dangerText : p.brandText;
    final toneBg = destructive ? p.dangerSoft : p.brandSoft;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xl,
        vertical: AppSpace.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: toneBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tone, size: 28),
                ),
                const SizedBox(height: AppSpace.lg),
              ],
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
              const SizedBox(height: AppSpace.xl),
              AppButton(
                label: confirmLabel,
                variant: destructive
                    ? AppButtonVariant.danger
                    : AppButtonVariant.primary,
                expand: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                },
              ),
              const SizedBox(height: AppSpace.sm),
              AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.text,
                expand: true,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success / informational dialog with a single acknowledgement button.
Future<void> showNoticeDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String buttonLabel,
  IconData icon = Icons.check_circle_rounded,
  bool success = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final p = ctx.palette;
      final tone = success ? p.successText : p.brandText;
      return Dialog(
        insetPadding: const EdgeInsets.all(AppSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: success ? p.successSoft : p.brandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tone, size: 34),
                ),
                const SizedBox(height: AppSpace.lg),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    title,
                    style: ctx.text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  message,
                  style: ctx.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpace.xl),
                AppButton(
                  label: buttonLabel,
                  expand: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
