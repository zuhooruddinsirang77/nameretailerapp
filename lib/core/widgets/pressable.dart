import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Adds a subtle scale-down press response to any tappable child. The scale is
/// skipped when the user has asked the OS to reduce motion.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.975,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        !context.mounted || !MediaQuery.disableAnimationsOf(context);
    return Listener(
      behavior: widget.behavior,
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: (_down && animate) ? widget.scale : 1,
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
