import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_tokens.dart';
import 'brand_artwork.dart';

/// Deep-ink gradient block with a soft brand glow. Content on it must use
/// white / [HeroPanel.onMuted] text colours.
class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.xl),
    this.radius = AppRadius.xl,
    this.mesh = true,
  });

  static const Color on = Colors.white;
  static const Color onMuted = Color(
    0xCCFFFFFF,
  ); // 80% white, ≥ 7:1 on hero ink
  static const Color onFaint = Color(0x29FFFFFF); // fills/hairlines

  final Widget child;
  static const Color accent = Color(0xFF00CEEE);
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool mesh;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final br = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.heroStart, p.heroEnd],
        ),
        boxShadow: AppElevation.medium(context.isDark),
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          children: [
            Positioned.fill(
              child: BrandArtwork(mesh: mesh, subtle: !mesh),
            ),
            // Decorative glow – excluded from semantics and hit testing.
            Positioned(
              top: -70,
              right: -50,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          p.brand.withValues(alpha: 0.38),
                          p.brand.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
