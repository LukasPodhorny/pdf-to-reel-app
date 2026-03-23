import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pdftoreel/constants.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VideoCarousel extends StatefulWidget {
  const VideoCarousel({super.key});

  @override
  State<VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  // 1. THE PHYSICS ENGINE: This listens to the exact, sub-pixel scroll
  // percentage of the carousel without lagging or rebuilding the entire screen.
  final ValueNotifier<double> _pageNotifier = ValueNotifier<double>(0.0);

  // Layout cache to prevent the carousel from shrinking when the bottom text field expands or the keyboard opens
  double? _cachedMaxHeight;
  double? _cachedMaxWidth;

  @override
  void dispose() {
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Update cache only if screen width changes (rotation) or we get MORE space.
        // This ignores vertical shrinking caused by the keyboard or text field growing!
        if (_cachedMaxHeight == null ||
            _cachedMaxWidth != constraints.maxWidth ||
            constraints.maxHeight > _cachedMaxHeight!) {
          _cachedMaxHeight = constraints.maxHeight;
          _cachedMaxWidth = constraints.maxWidth;
        }

        final carouselHeight = _cachedMaxHeight! - 50;
        final cardWidth = carouselHeight * (9 / 16);
        const desiredGap = 20.0;

        double dynamicFraction =
            (cardWidth + desiredGap) / constraints.maxWidth;
        dynamicFraction = dynamicFraction.clamp(0.1, 1.0);

        return OverflowBox(
          minHeight: _cachedMaxHeight,
          maxHeight: _cachedMaxHeight,
          alignment: Alignment
              .topCenter, // Anchors to the top so it doesn't shift upwards
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: 5,
                options: CarouselOptions(
                  height: carouselHeight,
                  enlargeCenterPage: true,
                  viewportFraction: dynamicFraction,
                  enableInfiniteScroll: true,
                  enlargeFactor: 0.15,
                  clipBehavior: Clip.none,

                  // 2. THE SCROLL LISTENER: Fires 60 times a second as you drag.
                  // We use modulo (%) 5 to map the infinite scroll back to 0.0 - 5.0
                  onScrolled: (value) {
                    if (value != null) {
                      _pageNotifier.value = value % 5;
                    }
                  },

                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex =
                          index; // Keeps the dots at the bottom working
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  // 3. THE FRAME-BY-FRAME BUILDER: This only rebuilds the cards
                  // themselves, keeping the app buttery smooth!
                  return ValueListenableBuilder<double>(
                    valueListenable: _pageNotifier,
                    builder: (context, pageValue, child) {
                      // --- THE PARALLAX MATH ---
                      // Calculates how far away this specific card is from the exact center.
                      // 0.0 means dead center. 1.0 means pushed exactly one slot to the side.
                      double diff = (pageValue - index) % 5;
                      double distance = diff <= 2.5 ? diff : 5.0 - diff;

                      // 4. THE CONTINUOUS OPACITY:
                      // As distance increases from 0 to 1, fade goes from 0.0 to 0.7.
                      const double fade = 0.6;
                      double fadeOpacity = (distance * fade).clamp(0.0, fade);

                      // As distance increases from 0 to 1, glow drops from 0.3 to 0.0.
                      const double glow = 0.0;
                      //_scale = 0.1
                      double glowOpacity = (glow - (distance * glow)).clamp(
                        0.0,
                        glow,
                      );

                      return Center(
                        // We removed AnimatedContainer because our math above acts as the animation!
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: glowOpacity > 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.textPrimary.withOpacity(
                                        glowOpacity,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[900],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  SafeNetworkImage(
                                    'https://picsum.photos/seed/${index}minecraft/400/600',
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 11,
                                    right: 9,
                                    child: Row(
                                      children: [
                                        Text(
                                          "12",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 10.0,
                                                color: Color.fromARGB(
                                                  150,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 10.0,
                                                color: Color.fromARGB(
                                                  150,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: SvgPicture.asset(
                                            'assets/icons/credit.svg', // Make sure this matches your file path!
                                            width: 12,
                                            height: 12,
                                            // This safely applies AppColors.surface1 to the entire SVG shape
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // THE FADE OVERLAY: Powered by our frame-by-frame math
                                  IgnorePointer(
                                    child: Container(
                                      color: AppColors.background.withOpacity(
                                        fadeOpacity,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = _currentIndex == index;
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
