import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Centres [child] and caps its width so layouts stay readable on tablets.
class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppSpace.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

extension PagePadding on BuildContext {
  /// Page padding whose horizontal inset grows on wide screens so scrolling
  /// content stays inside [AppSpace.maxContentWidth] while the scrollbar and
  /// overscroll still span the full width.
  EdgeInsets pagePadding({
    double top = AppSpace.lg,
    double bottom = AppSpace.xl,
    double maxWidth = AppSpace.maxContentWidth,
  }) {
    final w = MediaQuery.sizeOf(this).width;
    final side = ((w - maxWidth) / 2).clamp(AppSpace.gutter, double.infinity);
    return EdgeInsets.fromLTRB(
      side,
      top,
      side,
      bottom + MediaQuery.paddingOf(this).bottom,
    );
  }
}
