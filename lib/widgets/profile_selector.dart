import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';

class ProfileSelector extends ConsumerWidget {
  const ProfileSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndices = ref.watch(selectedProfileIndicesProvider);
    return Container(
      // 1. INCREASED HEIGHT: Was 85, now 110 to fit larger avatars
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF212121), // The dark grey background container
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E2E2E), // Correct hex color syntax
          width: 1.5,
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: 6,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedIndices.contains(index);

          // 2. INTERACTION: Wrap in GestureDetector to make it clickable
          return GestureDetector(
            onTap: () {
              final current = ref.read(selectedProfileIndicesProvider);
              if (current.contains(index)) {
                ref.read(selectedProfileIndicesProvider.notifier).state = {
                  ...current,
                }..remove(index);
              } else {
                ref.read(selectedProfileIndicesProvider.notifier).state = {
                  ...current,
                }..add(index);
              }
            },
            child: Container(
              // 3. INCREASED AVATAR SIZE: Was 50, now 80
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(
                3,
              ), // Slightly thicker gap for larger size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ) // Thicker border
                    : null,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey, // Fallback color
                ),
                clipBehavior: Clip.antiAlias, // Cuts the image into a circle
                child: SafeNetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/0/06/Elon_Musk%2C_2018_%28cropped%29.jpg',
                  fit: BoxFit
                      .cover, // Forces image to fill the circle without distorting
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
