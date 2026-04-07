import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/top_bar.dart';
import 'video_generator_screen.dart';
import 'videos_screen.dart';

/// Desktop home screen with sidebar navigation and full-width content area
class DesktopHomeScreen extends ConsumerStatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  ConsumerState<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends ConsumerState<DesktopHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Fixed sidebar
          DesktopSidebar(
            onLogout: () {
              // Navigation is handled by StreamBuilder in main.dart
            },
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top bar spanning full width
                Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 32,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(color: AppColors.surface2, width: 1),
                    ),
                  ),
                  child: const TopBar(),
                ),
                // Content area - directly render the screens without wrapper
                Expanded(
                  child: IndexedStack(
                    index: isGenerateMode ? 0 : 1,
                    children: const [VideoGeneratorScreen(), VideosScreen()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
