import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/profile_selector.dart';
import '../../widgets/custom_slider.dart';
import '../../widgets/video_carousel.dart';
import '../../widgets/bottom_input_area.dart';

class VideoGeneratorScreen extends StatefulWidget {
  const VideoGeneratorScreen({super.key});

  @override
  State<VideoGeneratorScreen> createState() => _VideoGeneratorScreenState();
}

class _VideoGeneratorScreenState extends State<VideoGeneratorScreen> {
  bool _isGenerateMode = true;
  double _reelCount = 4;
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
                TopBar(
                  isGenerateMode: _isGenerateMode,
                  onToggle: (val) => setState(() => _isGenerateMode = val),
                ),
                const SizedBox(height: 20),
                const ProfileSelector(),
                CustomSlider(
                  value: _reelCount,
                  onChanged: (val) => setState(() => _reelCount = val),
                ),
                Expanded(
                  child: VideoCarousel(controller: _pageController),
                ),
                const SizedBox(height: 160),
              ],
            ),
          ),

          // --- Floating Input Layer (Dynamic) ---
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