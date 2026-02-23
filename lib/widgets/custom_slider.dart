import 'package:flutter/material.dart';
import '../constants.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const CustomSlider({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Changed horizontal padding from 24 -> 16 to match ProfileSelector margin
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accentPink,
                inactiveTrackColor: const Color(0xFF3A3A3C),
                thumbColor: Colors.white,

                // 1. THICKNESS & SHAPE
                trackHeight: 9, // Thick track
                // 2. REMOVE DOTS
                trackShape: const UniformTrackShape(),

                tickMarkShape: SliderTickMarkShape.noTickMark,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayColor: AppColors.accentPink.withOpacity(0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
              ),
              child: Slider(
                value: value,
                min: 1,
                max: 10,
                divisions: 9, // Snapping enabled, but dots hidden via Theme
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            "${value.toInt()} reels",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class UniformTrackShape extends RoundedRectSliderTrackShape {
  const UniformTrackShape();

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
    double additionalActiveTrackHeight = 4, // The sneaky default!
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      // Force the extra height to 0 to make both sides identical
      additionalActiveTrackHeight: 0.0,
    );
  }
}
