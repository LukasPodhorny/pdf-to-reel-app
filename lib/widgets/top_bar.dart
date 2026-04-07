import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdftoreel/safe_network_image.dart';
import '../../constants.dart';
import '../ui_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Profile Picture
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.surface1,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: currentUser?.photoURL != null
                    ? SafeNetworkImage(
                        currentUser!.photoURL!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.person, color: AppColors.textSecondary, size: 24),
              ),
            ),

            // Center: Custom Toggle
            Container(
              height: 38,
              width: 180,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Material(
                      color: isGenerateMode
                          ? AppColors.surface2
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          ref.read(isGenerateModeProvider.notifier).state =
                              true;
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: _buildToggleOption(
                          "generate",
                          true,
                          isGenerateMode,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: !isGenerateMode
                          ? AppColors.surface2
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          ref.read(isGenerateModeProvider.notifier).state =
                              false;
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: _buildToggleOption(
                          "videos",
                          false,
                          isGenerateMode,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right: Credit Count
            Row(
              children: [
                Text(
                  userProfileAsync.maybeWhen(
                    data: (profile) => "${profile.credits}",
                    orElse: () => "...",
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(
                  'assets/icons/credit.svg',
                  width: 12,
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isForGenerate, bool currentMode) {
    bool isActive = currentMode == isForGenerate;
    return Container(
      alignment: Alignment.center,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isActive ? AppColors.textPrimary : AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        child: Text(text),
      ),
    );
  }
}
