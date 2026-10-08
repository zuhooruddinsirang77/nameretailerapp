import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/formatters.dart';

/// Monogram tile for a publication. The tint is derived from the domain so
/// the same site always has the same colour, without any network image.
class DomainAvatar extends StatelessWidget {
  const DomainAvatar({super.key, required this.domain, this.size = 44});

  final String domain;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final clean = Formatters.cleanDomain(domain);
    final palette = [
      p.metricDa,
      p.metricDr,
      p.metricTraffic,
      p.metricTrust,
      p.warningText,
      p.brandText,
    ];
    final hash = clean.codeUnits.fold<int>(
      7,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    final color = palette[hash % palette.length];
    final letter = clean.isEmpty ? '?' : clean.characters.first.toUpperCase();

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Solid (blended over the surface) so it reads the same on any
          // background, including the dark detail hero and during Hero flights.
          color: Color.alphaBlend(
            p.tint(color, light: 0.12, dark: 0.2),
            p.surface,
          ),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(
          letter,
          style: context.text.headlineSmall?.copyWith(
            color: color,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
