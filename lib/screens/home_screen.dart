import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../widgets/top_bar.dart'; // Make sure to import it!
import '../widgets/profile_drawer.dart';
import 'video_generator_screen.dart';
import 'videos_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const ProfileDrawer(),
      // We handle the safe area here once for the whole app
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. THE TOP BAR LIVES HERE NOW!
            // It will never be destroyed, so the animation will be flawless.
            const TopBar(),
            const SizedBox(height: 20),

            // 2. ONLY THE CONTENT SWAPS BELOW IT
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Generate Screen
                  IgnorePointer(
                    ignoring: !isGenerateMode,
                    child: AnimatedOpacity(
                      opacity: isGenerateMode ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: const VideoGeneratorScreen(),
                    ),
                  ),
                  // Videos Screen
                  IgnorePointer(
                    ignoring: isGenerateMode,
                    child: AnimatedOpacity(
                      opacity: isGenerateMode ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: const VideosScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
