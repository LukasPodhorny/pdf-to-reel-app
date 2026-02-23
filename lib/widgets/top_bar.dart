import 'package:flutter/material.dart';
import '../../constants.dart';

class TopBar extends StatelessWidget {
  final bool isGenerateMode;
  final ValueChanged<bool> onToggle;

  const TopBar({
    super.key,
    required this.isGenerateMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Color(0xFFD6D6D6),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
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
                          color: AppColors.element,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. FOREGROUND TEXT OPTIONS
                  Row(
                    children: [
                      Expanded(child: _buildToggleOption("generate", true)),
                      Expanded(child: _buildToggleOption("videos", false)),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Diamond Count
            Row(
              children: [
                const Text(
                  "100",
                  style: TextStyle(
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

  Widget _buildToggleOption(String text, bool isForGenerate) {
    bool isActive = isGenerateMode == isForGenerate;
    return GestureDetector(
      onTap: () => onToggle(isForGenerate),
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
