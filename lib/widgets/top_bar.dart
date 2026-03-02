import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../ui_providers.dart';

class TopBar extends ConsumerWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);
    final diamondCount = ref.watch(diamondCountProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Profile Placeholder
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.surface1,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),

            // Center: Custom Toggle
            Container(
              height: 46,
              width: 220,
              // 👇 PADDING REMOVED HERE 👇
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surface2, width: 1.5),
              ),
              child: Stack(
                children: [
                  // 1. SLIDING BACKGROUND PILL
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: isGenerateMode
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.surface3,
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. FOREGROUND TEXT OPTIONS
                  Row(
                    children: [
                      Expanded(
                        child: _buildToggleOption(
                          "generate",
                          true,
                          isGenerateMode,
                          ref,
                        ),
                      ),
                      Expanded(
                        child: _buildToggleOption(
                          "videos",
                          false,
                          isGenerateMode,
                          ref,
                        ),
                      ),
                    ],
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
                const SizedBox(width: 6),
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
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

  Widget _buildToggleOption(
    String text,
    bool isForGenerate,
    bool currentMode,
    WidgetRef ref,
  ) {
    bool isActive = currentMode == isForGenerate;
    return GestureDetector(
      onTap: () =>
          ref.read(isGenerateModeProvider.notifier).state = isForGenerate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
