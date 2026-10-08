import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'pressable.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

enum AppButtonSize { small, medium, large }

/// The one button for the app.
///
/// * `primary`   – the single main action on a screen
/// * `secondary` – tonal, for supporting actions
/// * `outline`   – neutral bordered action
/// * `text`      – low emphasis / inline
/// * `danger`    – destructive confirmation
///
/// Every size exposes at least a 48dp touch target. While [loading] the label
/// stays in place (so the layout does not jump) and taps are ignored.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null && !loading;
    final disabledLook = onPressed == null && !loading;

    final (Color bg, Color fg, BorderSide? border) = switch (variant) {
      AppButtonVariant.primary => (p.brand, p.onBrand, null),
      AppButtonVariant.secondary => (p.brandSoft, p.brandText, null),
      AppButtonVariant.outline => (
        Colors.transparent,
        p.text,
        BorderSide(color: p.borderStrong),
      ),
      AppButtonVariant.text => (Colors.transparent, p.brandText, null),
      AppButtonVariant.danger => (p.danger, Colors.white, null),
    };

    final bgColor =
        disabledLook &&
            variant != AppButtonVariant.text &&
            variant != AppButtonVariant.outline
        ? p.surfaceAlt
        : bg;
    final fgColor = disabledLook ? p.textMuted : fg;

    final (double height, double hPad, double iconSize) = switch (size) {
      AppButtonSize.small => (AppSpace.minTarget, AppSpace.md, 18),
      AppButtonSize.medium => (AppSpace.minTarget, AppSpace.lg, 20),
      AppButtonSize.large => (56, AppSpace.xl - 4, 22),
    };

    final style =
        (size == AppButtonSize.large
                ? context.text.labelLarge?.copyWith(fontSize: 15.5)
                : context.text.labelLarge)
            ?.copyWith(color: fgColor);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: SizedBox(
              width: iconSize - 4,
              height: iconSize - 4,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(fgColor),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: Icon(icon, size: iconSize, color: fgColor),
          ),
        Flexible(
          child: Text(
            label,
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailingIcon != null && !loading)
          Padding(
            padding: const EdgeInsets.only(left: AppSpace.sm),
            child: Icon(trailingIcon, size: iconSize, color: fgColor),
          ),
      ],
    );

    final visual = Pressable(
      onTap: enabled ? onPressed : null,
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brMd,
          side: border ?? BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height, minWidth: 64),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
              child: content,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: expand ? SizedBox(width: double.infinity, child: visual) : visual,
    );
  }
}

/// Square icon button with a guaranteed 48dp target and optional tonal fill.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.selectedIcon,
    this.color,
    this.filled = false,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      isSelected: selected,
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon ?? icon),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(AppSpace.minTarget),
        foregroundColor: color ?? p.text,
        backgroundColor: filled ? p.surface : null,
        side: filled ? BorderSide(color: p.borderStrong) : null,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),
    );
  }
}
