import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants.dart';
import '../../../ui_providers.dart';
import 'avatar_selection_grid.dart';
import 'cost_breakdown.dart';
import 'reel_count_slider.dart';

/// Right-hand configuration panel on the desktop generate screen:
/// reel-count slider, avatar grid and cost breakdown.
class ConfigurationPanel extends ConsumerWidget {
  const ConfigurationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelCount = ref.watch(reelCountProvider);

    return Container(
      color: AppColors.surface1,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ReelCountSlider(
            value: reelCount.toInt(),
            min: 0,
            max: 7,
            onChanged: (val) {
              if (val < 1) return;
              ref.read(reelCountProvider.notifier).state = val.toDouble();
            },
          ),
          const SizedBox(height: 24),
          const Expanded(child: AvatarSelectionGrid()),
          const SizedBox(height: 16),
          const CostBreakdown(),
        ],
      ),
    );
  }
}
