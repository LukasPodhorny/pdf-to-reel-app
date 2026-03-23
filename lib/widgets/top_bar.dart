import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdftoreel/safe_network_image.dart';
import '../../constants.dart';
import '../ui_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);
    final diamondCount = ref.watch(diamondCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Profile Placeholder
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
                // 1. THE FIX: Forces the child image to obey the BoxShape.circle
                clipBehavior: Clip.antiAlias,

                child: SafeNetworkImage(
                  'https://lh3.googleusercontent.com/a/ACg8ocLOt8f8l8oCHwobmVRCCBZrkAcdmwHakrZ2c0tkFlB5a4-TG59a=s576-c-no',
                  // 2. EXTRA TIP: Add fit: BoxFit.cover so the image fills the
                  // entire circle perfectly without stretching or leaving empty space!
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Center: Custom Toggle
            Container(
              height: 38,
              width: 180,
              clipBehavior: Clip
                  .antiAlias, // strictly crops everything to the rounded bounds
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

            // Right: Diamond Count
            Row(
              children: [
                Text(
                  "$diamondCount",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                SvgPicture.asset(
                  'assets/icons/credit.svg', // Make sure this matches your file path!
                  width: 12,
                  height: 12,
                  // This safely applies AppColors.surface1 to the entire SVG shape
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
