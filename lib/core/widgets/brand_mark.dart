import 'package:flutter/material.dart';

/// The folded blue N, rendered locally at any display size.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40, this.raised = false});

  final double size;
  final bool raised;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'NameRetailer logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: const _BrandMarkPainter()),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    final left = Path()
      ..moveTo(4, 13)
      ..lineTo(12, 5)
      ..lineTo(12, 33)
      ..quadraticBezierTo(12, 38, 7, 36)
      ..lineTo(4, 34)
      ..quadraticBezierTo(2, 33, 2, 29)
      ..lineTo(2, 18)
      ..quadraticBezierTo(2, 15, 4, 13)
      ..close();
    final right = Path()
      ..moveTo(28, 7)
      ..quadraticBezierTo(28, 2, 33, 4)
      ..lineTo(36, 6)
      ..quadraticBezierTo(38, 7, 38, 11)
      ..lineTo(38, 24)
      ..quadraticBezierTo(38, 27, 36, 29)
      ..lineTo(28, 37)
      ..close();
    final fold = Path()
      ..moveTo(12, 5)
      ..lineTo(36, 29)
      ..lineTo(28, 37)
      ..lineTo(4, 13)
      ..close();
    const rect = Rect.fromLTWH(0, 0, 40, 40);
    canvas.drawPath(
      left,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF009DFF), Color(0xFF0054E9)],
        ).createShader(rect),
    );
    canvas.drawPath(
      right,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF087CFF), Color(0xFF003BAB)],
        ).createShader(rect),
    );
    canvas.drawPath(
      fold,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF005BEB), Color(0xFF00C8F8)],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) => false;
}
