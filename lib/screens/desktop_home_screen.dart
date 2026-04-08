import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../widgets/desktop_sidebar.dart';
import 'desktop_generate_screen.dart';
import 'desktop_account_screen.dart';
import 'videos_screen.dart';

/// Desktop home screen with sidebar navigation and content area
class DesktopHomeScreen extends ConsumerWidget {
  const DesktopHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(desktopTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          DesktopSidebar(onLogout: () {}),
          Expanded(
            child: _buildContent(activeTab),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DesktopTab activeTab) {
    switch (activeTab) {
      case DesktopTab.generate:
        return const DesktopGenerateScreen();
      case DesktopTab.videos:
        return const VideosScreen();
      case DesktopTab.account:
        return const DesktopAccountScreen();
    }
  }
}
