import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../widgets/desktop/generate/configuration_panel.dart';
import '../widgets/desktop/generate/prompt_input_panel.dart';
import '../widgets/desktop/generate/template_carousel.dart';

/// Desktop generate screen with 2-panel layout:
/// Left: template carousel + prompt input (clipped to not overlap sidebar)
/// Right: configuration panel (slider, avatar grid, cost)
class DesktopGenerateScreen extends ConsumerWidget {
  const DesktopGenerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale the config panel with viewport width so it stays visually
    // balanced with the carousel on wide 16:9 monitors.
    final configWidth = (screenWidth * 0.175).clamp(320.0, 440.0);

    return Row(
      children: [
        Expanded(
          child: ClipRect(
            child: Column(
              children: const [
                Expanded(child: TemplateCarousel()),
                PromptInputPanel(),
              ],
            ),
          ),
        ),
        Container(
          width: configWidth,
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.surface3, width: 1),
            ),
          ),
          child: const ConfigurationPanel(),
        ),
      ],
    );
  }
}
