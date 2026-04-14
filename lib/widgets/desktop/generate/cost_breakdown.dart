import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import '../../../ui_providers.dart';

/// Template cost / reel count / total cost summary shown at the
/// bottom of the configuration panel.
class CostBreakdown extends ConsumerWidget {
  const CostBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTemplate = ref.watch(selectedTemplateProvider);
    final reelCount = ref.watch(reelCountProvider).toInt();
    final templateCost = selectedTemplate?.credits ?? 0;
    final totalCost = templateCost * reelCount;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _CostRow(label: 'template cost:', value: '$templateCost'),
              const SizedBox(height: 8),
              _CostRow(label: 'number of reels:', value: 'x $reelCount'),
            ],
          ),
        ),
        const Divider(color: AppColors.surface3, height: 24, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _CostRow(
            label: 'total:',
            value: '$totalCost',
            showCredit: true,
            isBold: true,
          ),
        ),
      ],
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showCredit;
  final bool isBold;

  const _CostRow({
    required this.label,
    required this.value,
    this.showCredit = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (showCredit) ...[
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/icons/credit.svg',
                width: 10,
                height: 10,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
