import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../constants.dart';
import '../../../ui_providers.dart';
import '../../../services/video_service.dart';
import '../../carousel_video_player.dart';
import '../../template_tag_pills.dart';

/// Full-height template carousel with arrows and page indicator.
/// Owns its CarouselSliderController and syncs the selected template
/// into [selectedTemplateNameProvider] / [selectedTemplateProvider].
class TemplateCarousel extends ConsumerStatefulWidget {
  const TemplateCarousel({super.key});

  @override
  ConsumerState<TemplateCarousel> createState() => _TemplateCarouselState();
}

class _TemplateCarouselState extends ConsumerState<TemplateCarousel> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesListProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(
            child: Text(
              'No templates available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.read(selectedTemplateNameProvider) == null &&
              templates.isNotEmpty) {
            ref.read(selectedTemplateNameProvider.notifier).state =
                templates[_currentIndex].name;
            ref.read(selectedTemplateProvider.notifier).state =
                templates[_currentIndex];
          }
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = constraints.maxHeight * 0.82;
            final cardWidth = carouselHeight * (9 / 16);
            const desiredGap = 20.0;
            double dynamicFraction =
                (cardWidth + desiredGap) / constraints.maxWidth;
            dynamicFraction = dynamicFraction.clamp(0.15, 0.55);

            // Chrome WASM workaround: Wrap the entire carousel in Transform + ClipRect + Opacity
            // to force proper stacking context for HtmlElementView-based video players.
            // This prevents video elements from rendering above overlapping panels
            // during initialization and scrolling, which is a known Chrome WASM rendering bug.
            // Transform.translate with zero offset forces a new compositing layer.
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: carouselHeight,
                  // Additional ClipRect to ensure videos don't overflow their bounds
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Transform.translate forces a new compositing layer
                        // Opacity(0.9999) forces a new render layer
                        // Combined, these fix the z-index/stacking issue in Chrome WASM
                        Transform.translate(
                          offset: const Offset(0, 0),
                          child: Opacity(
                            opacity: 0.9999,
                            child: Center(
                              child: CarouselSlider.builder(
                                carouselController: _carouselController,
                                itemCount: templates.length,
                                options: CarouselOptions(
                                  height: carouselHeight,
                                  enlargeCenterPage: true,
                                  viewportFraction: dynamicFraction,
                                  enableInfiniteScroll: true,
                                  enlargeFactor: 0.18,
                                  clipBehavior: Clip.hardEdge,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  onPageChanged: (index, reason) {
                                    setState(() => _currentIndex = index);
                                    ref
                                        .read(
                                          selectedTemplateNameProvider.notifier,
                                        )
                                        .state = templates[index]
                                        .name;
                                    ref
                                            .read(
                                              selectedTemplateProvider.notifier,
                                            )
                                            .state =
                                        templates[index];
                                  },
                                ),
                                itemBuilder: (context, index, realIndex) {
                                  final template = templates[index];
                                  double diff = (_currentIndex - index)
                                      .abs()
                                      .toDouble();
                                  if (diff > templates.length / 2) {
                                    diff = templates.length - diff;
                                  }
                                  const double fade = 0.6;
                                  final fadeOpacity = (diff * fade).clamp(
                                    0.0,
                                    fade,
                                  );

                                  return Center(
                                    child: AspectRatio(
                                      aspectRatio: 9 / 16,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        clipBehavior: Clip.hardEdge,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            color: Colors.grey[900],
                                          ),
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.basic,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                              CarouselVideoPlayer(
                                                isSelected:
                                                    _currentIndex == index,
                                                videoUrl: template.previewUrl,
                                                thumbnailUrl: '',
                                              ),
                                              if (_currentIndex == index)
                                                Positioned(
                                                  top: 11,
                                                  left: 11,
                                                  right: 60,
                                                  child: TemplateTagPills(
                                                    template: template,
                                                  ),
                                                ),
                                              Positioned(
                                                top: 11,
                                                right: 9,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '${template.credits}',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 10,
                                                            color:
                                                                Color.fromARGB(
                                                                  150,
                                                                  0,
                                                                  0,
                                                                  0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    SvgPicture.asset(
                                                      'assets/icons/credit.svg',
                                                      width: 12,
                                                      height: 12,
                                                      colorFilter:
                                                          const ColorFilter.mode(
                                                            AppColors
                                                                .textPrimary,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IgnorePointer(
                                                child: Container(
                                                  color: AppColors.background
                                                      .withValues(
                                                        alpha: fadeOpacity,
                                                      ),
                                                ),
                                              ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CarouselArrow(
                              flipped: true,
                              onTap: () => _carouselController.previousPage(),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _CarouselArrow(
                              flipped: false,
                              onTap: () => _carouselController.nextPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(templates.length, (index) {
                      final isActive = _currentIndex == index;
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: isActive ? 28 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.surface1,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, _) => Center(
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _CarouselArrow extends StatefulWidget {
  final bool flipped;
  final VoidCallback onTap;

  const _CarouselArrow({required this.flipped, required this.onTap});

  @override
  State<_CarouselArrow> createState() => _CarouselArrowState();
}

class _CarouselArrowState extends State<_CarouselArrow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isHovered
                ? AppColors.surface3
                : AppColors.surface2.withValues(alpha: 0.8),
          ),
          child: Center(
            child: Transform.flip(
              flipX: widget.flipped,
              child: SvgPicture.asset(
                'assets/icons/carousel_arrow.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
