import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../widgets/top_bar.dart';
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const TopBar(),
            const SizedBox(height: 20),
            Expanded(
              child: IndexedStack(
                index: isGenerateMode ? 0 : 1,
                children: const [VideoGeneratorScreen(), VideosScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
