import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';

class CustomSlider extends ConsumerWidget {
  const CustomSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(reelCountProvider);

    // --- CUSTOMIZATION PANEL ---
    // Tweak these numbers to get your exact perfect vibe!
    const double trackThickness = 7.0;

    // Tweak thumb sizes here!
    const double idleThumbWidth = 19.0;
    const double idleThumbHeight = 19.0;
    const double activeThumbWidth = 10.0;
    const double activeThumbHeight = 28.0;

    const double trackGap =
        0.0; // The empty space between the pink track and the white handle

    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 25,
        top: 13.5,
        bottom: 13.5,
      ),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.neonGreen,
                inactiveTrackColor: AppColors.surface1,
                thumbColor: AppColors.textPrimary,
                trackHeight: trackThickness,
                tickMarkShape: SliderTickMarkShape.noTickMark,

                // 1. THE GAP FIX: Our custom track that cuts a clean space around the thumb
                trackShape: const CustomGapTrackShape(
                  gap: trackGap,
                  thumbWidth: idleThumbWidth,
                ),

                // 2. THE ANIMATED THUMB FIX: Our custom pill that morphs and glows
                thumbShape: const CustomAnimatedThumbShape(
                  idleWidth: idleThumbWidth,
                  idleHeight: idleThumbHeight,
                  activeWidth: activeThumbWidth,
                  activeHeight: activeThumbHeight,
                ),

                // We can disable the default circle overlay because we built
                // a custom, better-looking glow directly into the thumb shape below!
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value.clamp(1.0, 7.0),
                min: 0,
                max: 7,
                divisions: 7,
                onChanged: (val) {
                  if (val < 1.0) return;
                  ref.read(reelCountProvider.notifier).state = val;
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${value.toInt()} reels",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CUSTOM TRACK SHAPE (Controls the customizable gap)
// ============================================================================
class CustomGapTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final double gap;
  final double thumbWidth;

  const CustomGapTrackShape({required this.gap, required this.thumbWidth});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Canvas canvas = context.canvas;
    final trackRadius = Radius.circular(trackRect.height / 2);

    // Setting spacing to 0 means the active and inactive tracks meet exactly
    // at the center of the thumb, leaving absolutely no gap.
    final double spacing = 0.0;

    // --- DRAW LEFT SIDE (Active) ---
    // Always fill at least one step so the minimum (1 reel) looks filled.
    final double oneStep = trackRect.width / 7;
    final activeRight = (thumbCenter.dx - spacing).clamp(
      trackRect.left + oneStep,
      trackRect.right,
    );
    if (activeRight > trackRect.left) {
      final activeRect = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        activeRight,
        trackRect.bottom,
      );
      final activePaint = Paint()..color = sliderTheme.activeTrackColor!;
      final activeRRect = RRect.fromRectAndCorners(
        activeRect,
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        topRight: Radius.zero,
        bottomRight: Radius.zero,
      );
      canvas.drawRRect(activeRRect, activePaint);
    }

    // --- DRAW RIGHT SIDE (Inactive) ---
    final inactiveLeft = thumbCenter.dx + spacing;
    if (inactiveLeft < trackRect.right) {
      final inactiveRect = Rect.fromLTRB(
        inactiveLeft,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      );
      final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor!;
      final inactiveRRect = RRect.fromRectAndCorners(
        inactiveRect,
        topRight: trackRadius,
        bottomRight: trackRadius,
        topLeft: Radius.zero,
        bottomLeft: Radius.zero,
      );
      canvas.drawRRect(inactiveRRect, inactivePaint);
    }
  }
}

// ============================================================================
// CUSTOM ANIMATED THUMB SHAPE (Controls the thumb's size and drag animation)
// ============================================================================
class CustomAnimatedThumbShape extends SliderComponentShape {
  final double idleWidth;
  final double idleHeight;
  final double activeWidth;
  final double activeHeight;

  const CustomAnimatedThumbShape({
    required this.idleWidth,
    required this.idleHeight,
    required this.activeWidth,
    required this.activeHeight,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(activeWidth, activeHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Smoothly interpolate between idle and active states based on interaction
    final double currentWidth =
        idleWidth + (activeWidth - idleWidth) * activationAnimation.value;
    final double currentHeight =
        idleHeight + (activeHeight - idleHeight) * activationAnimation.value;

    final Rect thumbRect = Rect.fromCenter(
      center: center,
      width: currentWidth,
      height: currentHeight,
    );

    final RRect rRect = RRect.fromRectAndRadius(
      thumbRect,
      Radius.circular(currentWidth / 2),
    );

    // Draw the main thumb
    final Paint thumbPaint = Paint()..color = sliderTheme.thumbColor!;
    canvas.drawRRect(rRect, thumbPaint);
  }
}
