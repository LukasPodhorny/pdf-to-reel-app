import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/profile_selector.dart';
import '../widgets/custom_slider.dart';
import '../widgets/video_carousel.dart';
import '../widgets/bottom_input_area.dart';

class VideoGeneratorScreen extends ConsumerStatefulWidget {
  const VideoGeneratorScreen({super.key});

  @override
  ConsumerState<VideoGeneratorScreen> createState() =>
      _VideoGeneratorScreenState();
}

class _VideoGeneratorScreenState extends ConsumerState<VideoGeneratorScreen> {
  double _restingBottomInputHeight = 192;

  void _onBottomInputHeightChanged(double height) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisible) return;
    if ((height - _restingBottomInputHeight).abs() > 1) {
      setState(() {
        _restingBottomInputHeight = height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: _restingBottomInputHeight),
                child: Column(
                  children: [
                    const ProfileSelector(),
                    const CustomSlider(),
                    const Expanded(child: VideoCarousel()),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Transform.translate(
                offset: Offset(0, -keyboardHeight),
                child: BottomInputArea(
                  onHeightChanged: _onBottomInputHeightChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
