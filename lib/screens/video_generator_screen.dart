import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/profile_selector.dart';
import '../../widgets/custom_slider.dart';
import '../../widgets/video_carousel.dart';
import '../../widgets/bottom_input_area.dart';

class VideoGeneratorScreen extends ConsumerStatefulWidget {
  const VideoGeneratorScreen({super.key});

  @override
  ConsumerState<VideoGeneratorScreen> createState() =>
      _VideoGeneratorScreenState();
}

class _VideoGeneratorScreenState extends ConsumerState<VideoGeneratorScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tracks the keyboard height dynamically
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Prevents the base layout from squishing when the keyboard opens
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const ProfileSelector(),
                const CustomSlider(),
                const Expanded(child: VideoCarousel()),

                // Reserves the resting space for the BottomInputArea (~192px)
                // so the carousel doesn't overlap it when the keyboard is closed.
                const SizedBox(height: 192),
              ],
            ),

            // THE FRONT LAYER FIX: Completely detaches the input area from the Column.
            // It now anchors to the bottom and grows UPWARDS freely over the carousel!
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardHeight,
              child: const BottomInputArea(),
            ),
          ],
        ),
      ),
    );
  }
}
