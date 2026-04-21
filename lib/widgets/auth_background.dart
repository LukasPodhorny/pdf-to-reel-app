import 'dart:math' as math;
import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _MarbledPainter(),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _MarbledPainter extends CustomPainter {
  static const Color _base = Color(0xFF141414);
  // Non-base bands use a low alpha so the base shows through — soft, marbled
  // tint rather than solid stripes.
  static const List<Color> _palette = [
    _base,
    Color.fromARGB(110, 0x1B, 0x22, 0x30),
    Color.fromARGB(110, 0x1E, 0x16, 0x16),
    Color.fromARGB(110, 0x23, 0x1B, 0x2C),
  ];

  // Virtual reference canvas — waves and bands are sized against this so
  // smaller viewports crop the pattern instead of squishing it.
  static const double _virtualWidth = 1600;
  static const double _virtualBandHeight = 170;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _base);

    final xOffset = (_virtualWidth - size.width) / 2;
    final bandCount = (size.height / _virtualBandHeight).ceil() + 2;

    for (int i = -1; i <= bandCount; i++) {
      final topSeed = i.toDouble();
      final bottomSeed = (i + 1).toDouble();
      final topY = i * _virtualBandHeight;
      final bottomY = (i + 1) * _virtualBandHeight;

      final path = Path()..moveTo(-24, topY + _wave(-24 + xOffset, topSeed));
      for (double x = -24; x <= size.width + 24; x += 6) {
        path.lineTo(x, topY + _wave(x + xOffset, topSeed));
      }
      for (double x = size.width + 24; x >= -24; x -= 6) {
        path.lineTo(x, bottomY + _wave(x + xOffset, bottomSeed));
      }
      path.close();

      final idx = ((i % _palette.length) + _palette.length) % _palette.length;
      canvas.drawPath(path, Paint()..color = _palette[idx]);
    }
  }

  double _wave(double virtualX, double seed) {
    final s1 = math.sin(virtualX / _virtualWidth * math.pi * 1.3 + seed * 0.9);
    final s2 = math.sin(virtualX / _virtualWidth * math.pi * 3.2 + seed * 1.7);
    final s3 = math.sin(virtualX / _virtualWidth * math.pi * 7.0 + seed * 2.3);
    return s1 * _virtualBandHeight * 0.55 +
        s2 * _virtualBandHeight * 0.18 +
        s3 * _virtualBandHeight * 0.06;
  }

  @override
  bool shouldRepaint(covariant _MarbledPainter oldDelegate) => false;
}
