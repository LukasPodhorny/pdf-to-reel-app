import 'package:flutter/material.dart';
import '../../../constants.dart';

/// Custom horizontal slider used to pick the number of reels to generate.
/// Purely presentational — emits [onChanged] with the new integer value.
class ReelCountSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const ReelCountSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<ReelCountSlider> createState() => _ReelCountSliderState();
}

class _ReelCountSliderState extends State<ReelCountSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _thumbAnim;
  bool _isDragging = false;
  double _animatedFraction = 0.0;

  int get _steps => widget.max - widget.min;

  @override
  void initState() {
    super.initState();
    _thumbAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );
    _animatedFraction = _fractionFor(widget.value);
  }

  @override
  void didUpdateWidget(ReelCountSlider old) {
    super.didUpdateWidget(old);
    if (!_isDragging && old.value != widget.value) {
      _animatedFraction = _fractionFor(widget.value);
    }
  }

  @override
  void dispose() {
    _thumbAnim.dispose();
    super.dispose();
  }

  double _fractionFor(int v) => (v - widget.min) / _steps;

  int _valueFromFraction(double f) =>
      (widget.min + (f * _steps).round()).clamp(widget.min, widget.max);

  void _handleDown(double localX, double trackWidth) {
    setState(() => _isDragging = true);
    _thumbAnim.forward();
    _update(localX, trackWidth);
  }

  void _handleUpdate(double localX, double trackWidth) {
    _update(localX, trackWidth);
  }

  void _handleEnd() {
    _thumbAnim.reverse();
    setState(() => _isDragging = false);
  }

  void _update(double localX, double trackWidth) {
    final raw = (localX / trackWidth).clamp(0.0, 1.0);
    var newVal = _valueFromFraction(raw);
    if (newVal < 1) newVal = 1;
    final snapped = _fractionFor(newVal);
    setState(() => _animatedFraction = snapped);
    if (newVal != widget.value) {
      widget.onChanged(newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 8.0;
              final trackWidth = constraints.maxWidth - horizontalPadding * 2;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onHorizontalDragStart: (d) => _handleDown(
                    d.localPosition.dx - horizontalPadding,
                    trackWidth,
                  ),
                  onHorizontalDragUpdate: (d) => _handleUpdate(
                    d.localPosition.dx - horizontalPadding,
                    trackWidth,
                  ),
                  onHorizontalDragEnd: (_) => _handleEnd(),
                  onTapDown: (d) {
                    _handleDown(
                      d.localPosition.dx - horizontalPadding,
                      trackWidth,
                    );
                    Future.microtask(() => _handleEnd());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 14,
                    ),
                    child: AnimatedBuilder(
                      animation: _thumbAnim,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(trackWidth, 20),
                          painter: _SliderTrackPainter(
                            fraction: _animatedFraction,
                            steps: _steps,
                            thumbScale: 1.0 + _thumbAnim.value * 0.35,
                            isDragging: _isDragging,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${widget.value} reels',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _SliderTrackPainter extends CustomPainter {
  final double fraction;
  final int steps;
  final double thumbScale;
  final bool isDragging;

  _SliderTrackPainter({
    required this.fraction,
    required this.steps,
    required this.thumbScale,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const trackHeight = 4.0;
    const thumbRadius = 8.0;
    final trackR = Radius.circular(trackHeight / 2);

    final inactivePaint = Paint()..color = AppColors.surface3;
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        cy - trackHeight / 2,
        size.width,
        cy + trackHeight / 2,
        trackR,
      ),
      inactivePaint,
    );

    final thumbX = fraction * size.width;
    final activePaint = Paint()..color = AppColors.neonGreen;
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        cy - trackHeight / 2,
        thumbX,
        cy + trackHeight / 2,
        trackR,
      ),
      activePaint,
    );

    if (isDragging) {
      final glowPaint = Paint()
        ..color = AppColors.neonGreen.withValues(alpha: 0.18);
      canvas.drawCircle(
        Offset(thumbX, cy),
        thumbRadius * thumbScale + 8,
        glowPaint,
      );
    }

    final r = thumbRadius * thumbScale;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(thumbX, cy + 1), r, shadowPaint);
    final thumbPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(Offset(thumbX, cy), r, thumbPaint);
    final innerPaint = Paint()..color = AppColors.neonGreen;
    canvas.drawCircle(Offset(thumbX, cy), r * 0.35, innerPaint);
  }

  @override
  bool shouldRepaint(_SliderTrackPainter old) =>
      fraction != old.fraction ||
      thumbScale != old.thumbScale ||
      isDragging != old.isDragging;
}
