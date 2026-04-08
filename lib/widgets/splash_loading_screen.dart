import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';

class SplashLoadingScreen extends StatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  State<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated logo area
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 2 * pi,
                        child: CustomPaint(
                          size: const Size(140, 140),
                          painter: _ArcRingPainter(
                            progress: _rotateController.value,
                          ),
                        ),
                      );
                    },
                  ),
                  // Inner pulsing glow
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 0.85 + (_pulseController.value * 0.15);
                      final opacity = 0.3 + (_pulseController.value * 0.4);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withValues(alpha: opacity),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Center icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 0.9 + (_pulseController.value * 0.1);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface2,
                            border: Border.all(
                              color: AppColors.neonGreen.withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.neonGreen,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // App name
            const Text(
              'PDF to Reel',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Animated loading dots
            _AnimatedLoadingDots(controller: _dotsController),
          ],
        ),
      ),
    );
  }
}

class _ArcRingPainter extends CustomPainter {
  final double progress;

  _ArcRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw the arc segments
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // First arc - neon green
    paint.color = AppColors.neonGreen.withValues(alpha: 0.9);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 0.8,
      false,
      paint,
    );

    // Second arc - dimmer green
    paint.color = AppColors.neonGreen.withValues(alpha: 0.3);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + pi,
      pi * 0.5,
      false,
      paint,
    );

    // Third small arc - accent
    paint.color = AppColors.accentPink.withValues(alpha: 0.6);
    paint.strokeWidth = 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -pi / 2 + pi * 0.4,
      pi * 0.3,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AnimatedLoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedLoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Stagger the animation for each dot
            final delay = index * 0.25;
            final value = ((controller.value + delay) % 1.0);
            // Smooth bounce curve
            final opacity = 0.3 + 0.7 * (sin(value * pi)).clamp(0.0, 1.0);
            final yOffset = -4 * (sin(value * pi)).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonGreen.withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
