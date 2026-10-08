import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Local, resolution-independent artwork that needs no image request.
class BrandArtwork extends StatelessWidget {
  const BrandArtwork({
    super.key,
    this.seed = 0,
    this.mesh = false,
    this.subtle = false,
  });

  final int seed;
  final bool mesh;
  final bool subtle;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ArtworkPainter(seed: seed, mesh: mesh, subtle: subtle),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

class _ArtworkPainter extends CustomPainter {
  const _ArtworkPainter({
    required this.seed,
    required this.mesh,
    required this.subtle,
  });

  final int seed;
  final bool mesh;
  final bool subtle;

  static const _palettes = [
    [Color(0xFF020D33), Color(0xFF064BD9), Color(0xFF56A5FF)],
    [Color(0xFF8981FF), Color(0xFFBBB6FF), Color(0xFF4B65F8)],
    [Color(0xFF087B60), Color(0xFF59CDB0), Color(0xFFB1EFE1)],
    [Color(0xFF03133C), Color(0xFF1359F7), Color(0xFF7975FF)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final colors = _palettes[seed % _palettes.length];
    canvas.save();
    canvas.clipRect(rect);
    if (mesh) {
      _paintMesh(canvas, size);
    } else {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.take(2).toList(),
          ).createShader(rect),
      );
      _paintRibbons(canvas, size, colors);
    }
    canvas.restore();
  }

  void _paintRibbons(Canvas canvas, Size size, List<Color> colors) {
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < 5; i++) {
      final shift = i * 0.19;
      final ribbon = Path()
        ..moveTo(-w * 0.25, h * (1.12 - shift))
        ..cubicTo(
          w * 0.16,
          h * (1.04 - shift),
          w * 0.34,
          h * (0.10 + shift),
          w * 0.64,
          h * (0.35 + shift),
        )
        ..cubicTo(
          w * 0.93,
          h * (0.61 + shift),
          w * 0.96,
          -h * 0.12,
          w * 1.26,
          -h * 0.19,
        )
        ..lineTo(w * 1.23, h * 0.21)
        ..cubicTo(
          w * 0.93,
          h * 0.30,
          w * 0.96,
          h * (0.91 + shift),
          w * 0.65,
          h * (0.66 + shift),
        )
        ..cubicTo(
          w * 0.35,
          h * (0.41 + shift),
          w * 0.20,
          h * (1.32 - shift),
          -w * 0.25,
          h * (1.40 - shift),
        )
        ..close();
      canvas.drawPath(
        ribbon,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[2].withValues(alpha: 0.68),
              colors[1].withValues(alpha: 0.12),
              colors[0].withValues(alpha: 0.76),
            ],
            stops: const [0, 0.46, 1],
          ).createShader(Offset.zero & size),
      );
      for (var j = 0; j < 7; j++) {
        final offset = shift + j * 0.016;
        final thread = Path()
          ..moveTo(-w * 0.25, h * (1.12 - offset))
          ..cubicTo(
            w * 0.16,
            h * (1.04 - offset),
            w * 0.34,
            h * (0.10 + offset),
            w * 0.64,
            h * (0.35 + offset),
          )
          ..cubicTo(
            w * 0.93,
            h * (0.61 + offset),
            w * 0.96,
            -h * 0.12,
            w * 1.26,
            -h * 0.19,
          );
        canvas.drawPath(
          thread,
          Paint()
            ..color = colors[2].withValues(alpha: j == 0 ? 0.40 : 0.10)
            ..style = PaintingStyle.stroke
            ..strokeWidth = j == 0 ? 0.8 : 0.4,
        );
      }
    }
    if (subtle) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF020D2C).withValues(alpha: 0.58),
      );
    }
  }

  void _paintMesh(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const blue = Color(0xFF1685FF);
    final points = [
      Offset(w * 0.83, h * 0.08),
      Offset(w * 1.08, h * 0.02),
      Offset(w * 0.87, h * 0.33),
      Offset(w * 1.05, h * 0.52),
      Offset(w * 0.69, h * 0.66),
      Offset(w * 0.55, h * 0.96),
      Offset(w * 0.97, h * 1.08),
      Offset(w * 0.76, h * 0.86),
    ];
    const triangles = [
      [0, 1, 2],
      [1, 2, 3],
      [2, 3, 4],
      [3, 4, 7],
      [4, 5, 7],
      [5, 6, 7],
      [3, 6, 7],
    ];
    for (var i = 0; i < triangles.length; i++) {
      final path = Path()
        ..addPolygon(triangles[i].map((index) => points[index]).toList(), true);
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              blue.withValues(alpha: i.isEven ? 0.20 : 0.07),
              blue.withValues(alpha: 0.025),
            ],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = blue.withValues(alpha: 0.26)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }
    for (final point in points) {
      canvas.drawCircle(
        point,
        math.min(w, h) * 0.006,
        Paint()..color = blue.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_ArtworkPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.mesh != mesh ||
      oldDelegate.subtle != subtle;
}
