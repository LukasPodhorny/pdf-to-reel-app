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
  static const List<Color> _palette = [
    _base,
    Color(0xFF1B2230),
    Color(0xFF1E1616),
    Color(0xFF231B2C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _base);

    const bandCount = 14;
    final bandHeight = size.height / bandCount;

    for (int i = -1; i <= bandCount; i++) {
      final topSeed = i.toDouble();
      final bottomSeed = (i + 1).toDouble();
      final topY = i * bandHeight;
      final bottomY = (i + 1) * bandHeight;

      final path = Path()
        ..moveTo(-24, topY + _wave(-24, topSeed, size, bandHeight));
      for (double x = -24; x <= size.width + 24; x += 6) {
        path.lineTo(x, topY + _wave(x, topSeed, size, bandHeight));
      }
      for (double x = size.width + 24; x >= -24; x -= 6) {
        path.lineTo(x, bottomY + _wave(x, bottomSeed, size, bandHeight));
      }
      path.close();

      final idx = ((i % _palette.length) + _palette.length) % _palette.length;
      canvas.drawPath(path, Paint()..color = _palette[idx]);
    }

    _paintGrain(canvas, size);
  }

  double _wave(double x, double seed, Size size, double bandHeight) {
    final w = size.width;
    final s1 = math.sin(x / w * math.pi * 1.3 + seed * 0.9);
    final s2 = math.sin(x / w * math.pi * 3.2 + seed * 1.7);
    final s3 = math.sin(x / w * math.pi * 7.0 + seed * 2.3);
    return s1 * bandHeight * 0.75 +
        s2 * bandHeight * 0.28 +
        s3 * bandHeight * 0.10;
  }

  void _paintGrain(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint();
    final count = (size.width * size.height / 900).round().clamp(500, 4500);
    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final bright = rnd.nextDouble();
      if (bright > 0.5) {
        paint.color = Color.fromARGB((bright * 44).toInt(), 255, 255, 255);
      } else {
        paint.color = Color.fromARGB((bright * 36).toInt(), 0, 0, 0);
      }
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MarbledPainter oldDelegate) => false;
}
