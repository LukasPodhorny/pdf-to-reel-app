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
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Prevents resizing the background when keyboard opens
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Background Layer (Static) ---
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const TopBar(),
                const SizedBox(height: 20),
                const ProfileSelector(),
                const CustomSlider(),
                Expanded(child: VideoCarousel(controller: _pageController)),
                const SizedBox(height: 160),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: const BottomInputArea(),
          ),
        ],
      ),
    );
  }
}
