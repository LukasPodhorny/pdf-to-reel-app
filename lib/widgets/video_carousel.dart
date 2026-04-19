import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdftoreel/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../ui_providers.dart';
import '../services/video_service.dart';
import 'carousel_video_player.dart';
import 'template_tag_pills.dart';

class VideoCarousel extends ConsumerStatefulWidget {
  const VideoCarousel({super.key});

  @override
  ConsumerState<VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends ConsumerState<VideoCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  final ValueNotifier<double> _pageNotifier = ValueNotifier<double>(0.0);
  double? _restingAvailableHeight;

  @override
  void dispose() {
    _pageNotifier.dispose();
    super.dispose();
  }

  double _normalizePageValue(double value, int length) {
    if (length == 0) return 0;
    return ((value % length) + length) % length;
  }

  int _nearestIndexFromPage(double pageValue, int length) {
    if (length == 0) return 0;
    return _normalizePageValue(pageValue, length).round() % length;
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesListProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text("No templates available"));
        }

        // Initialize selected template if not set
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ref.read(selectedTemplateNameProvider) == null) {
            ref.read(selectedTemplateNameProvider.notifier).state =
                templates[_currentIndex].name;
            ref.read(selectedTemplateProvider.notifier).state =
                templates[_currentIndex];
          }
        });

        return LayoutBuilder(
          builder: (context, constraints) {
            const indicatorHeight = 50.0;
            final view = View.of(context);
            final keyboardVisible =
                view.viewInsets.bottom / view.devicePixelRatio > 0;
            if (!keyboardVisible) {
              _restingAvailableHeight = constraints.maxHeight;
            }
            final availableHeight = keyboardVisible && _restingAvailableHeight != null
                ? _restingAvailableHeight!
                : constraints.maxHeight;
            final carouselHeight = (availableHeight - indicatorHeight).clamp(
              120.0,
              double.infinity,
            );
            final cardWidth = carouselHeight * (9 / 16);
            const desiredGap = 20.0;

            double dynamicFraction =
                (cardWidth + desiredGap) / constraints.maxWidth;
            dynamicFraction = dynamicFraction.clamp(0.1, 1.0);

            // Wrapped the Column in OverflowBox to prevent RenderFlex overflow
            return OverflowBox(
              minHeight: availableHeight,
              maxHeight: availableHeight,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRect(
                    clipper: _HorizontalOnlyClipper(),
                    child: CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: templates.length,
                    options: CarouselOptions(
                      height: carouselHeight,
                      enlargeCenterPage: true,
                      viewportFraction: dynamicFraction,
                      enableInfiniteScroll: true,
                      enlargeFactor: 0.15,
                      clipBehavior: Clip.none,
                      onScrolled: (value) {
                        if (value != null) {
                          _pageNotifier.value =
                              _normalizePageValue(value, templates.length);
                        }
                      },
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                        ref.read(selectedTemplateNameProvider.notifier).state =
                            templates[index].name;
                        ref.read(selectedTemplateProvider.notifier).state =
                            templates[index];
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final template = templates[index];
                      return ValueListenableBuilder<double>(
                        valueListenable: _pageNotifier,
                        builder: (context, pageValue, child) {
                          double diff = (_currentIndex - index).abs().toDouble();
                          if (diff > templates.length / 2) {
                            diff = templates.length - diff;
                          }
                          const double fade = 0.6;
                          final fadeOpacity = (diff * fade).clamp(0.0, fade);

                          return Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[900],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.basic,
                                    child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CarouselVideoPlayer(
                                        isSelected: _currentIndex == index,
                                        videoUrl: template.previewUrl,
                                        thumbnailUrl: '',
                                      ),
                                      if (_currentIndex == index)
                                        Positioned(
                                          top: 9,
                                          left: 9,
                                          right: 50,
                                          child: TemplateTagPills(
                                            template: template,
                                            scale: 0.75,
                                          ),
                                        ),
                                      Positioned(
                                        top: 11,
                                        right: 9,
                                        child: Row(
                                          children: [
                                            Text(
                                              "${template.credits}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                shadows: <Shadow>[
                                                  Shadow(
                                                    offset: Offset(1.0, 1.0),
                                                    blurRadius: 10.0,
                                                    color: Color.fromARGB(
                                                        150, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    offset: Offset(1.0, 1.0),
                                                    blurRadius: 10.0,
                                                    color: Color.fromARGB(
                                                        150, 0, 0, 0),
                                                  ),
                                                ],
                                              ),
                                              child: SvgPicture.asset(
                                                'assets/icons/credit.svg',
                                                width: 12,
                                                height: 12,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  Colors.white,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IgnorePointer(
                                        child: Container(
                                          color: AppColors.background
                                              .withOpacity(fadeOpacity),
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
                      );
                    },
                  ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _pageNotifier,
                      builder: (context, pageValue, child) {
                        final selectedIndex =
                            _nearestIndexFromPage(pageValue, templates.length);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(templates.length, (index) {
                            final isSelected = selectedIndex == index;
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                width: isSelected ? 28 : 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.surface1,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (err, stack) =>
          Center(child: Text("Error loading templates: $err")),
    );
  }
}

// Clips only horizontally, allowing vertical overflow (needed so the
// enlargeCenterPage effect isn't vertically cropped, while still clipping
// off-screen HTML <video> platform views on Chrome web).
class _HorizontalOnlyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, -10000, size.width, size.height + 10000);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
