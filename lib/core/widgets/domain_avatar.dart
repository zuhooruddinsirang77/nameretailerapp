import 'package:flutter/material.dart';

import '../utils/formatters.dart';
import 'brand_artwork.dart';

/// Abstract publication artwork, deterministically coloured by domain.
class DomainAvatar extends StatelessWidget {
  const DomainAvatar({super.key, required this.domain, this.size = 44});

  final String domain;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clean = Formatters.cleanDomain(domain);
    final hash = clean.codeUnits.fold<int>(
      7,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.16),
          child: BrandArtwork(seed: hash),
        ),
      ),
    );
  }
}
