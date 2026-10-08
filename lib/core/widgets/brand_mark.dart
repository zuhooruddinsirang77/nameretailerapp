import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';

/// The NameRetailer emblem on a white tile (the artwork has a white ground, so
/// the tile keeps it crisp in dark mode too). Decoded at display size.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.raised = false});

  final double size;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Semantics(
      label: 'NameRetailer logo',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(color: p.border),
          boxShadow: raised ? AppElevation.medium(context.isDark) : null,
        ),
        child: Image.asset(
          'assets/images/logo_emblem.png',
          fit: BoxFit.contain,
          cacheWidth: (size * dpr).round(),
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
