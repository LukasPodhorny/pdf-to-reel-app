import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 1. Changed to ConsumerStatefulWidget to manage the ScrollController
class ProfileSelector extends ConsumerStatefulWidget {
  const ProfileSelector({super.key});

  @override
  ConsumerState<ProfileSelector> createState() => _ProfileSelectorState();
}

class _ProfileSelectorState extends ConsumerState<ProfileSelector> {
  // 2. Add a ScrollController for the horizontal scrollbar
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndices = ref.watch(selectedProfileIndicesProvider);

    return Container(
      height: 84,
      margin: const EdgeInsets.symmetric(horizontal: 18.0),

      // 1. THE PAD FIX: Removed left/right padding from the parent!
      // This allows the mask and list to stretch all the way to the 0px edge.
      padding: const EdgeInsets.only(top: 0, bottom: 2, left: 2, right: 2),

      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface1, width: 1.0),
      ),

      // 2. THE CURVE FIX: Forces the fade and avatars to respect the curved borders
      clipBehavior: Clip.antiAlias,

      child: RawScrollbar(
        controller: _scrollController,
        thumbColor: AppColors.surface2,
        radius: const Radius.circular(8),
        thickness: 3,

        // 3. THE SCROLLBAR FIX: Keeps the little thumb bar exactly 15px away
        // from the edges so it doesn't look stretched or broken.
        padding: const EdgeInsets.only(bottom: 5, left: 15, right: 15),

        thumbVisibility: true,
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              // Roughly targets the first and last ~15 pixels for the fade
              stops: [-0.0, 0.05, 0.95, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,

          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,

            // THE FIX: Added 'top: 4' to give the popping animation breathing room!
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 12,
              left: 15,
              right: 15,
            ),

            itemCount: 6,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isSelected = selectedIndices.contains(index);

              // 1. THE POP FIX: Shrinks unselected items slightly, bounces selected ones up
              return AnimatedScale(
                scale: isSelected ? 1.05 : 0.95,
                duration: const Duration(milliseconds: 200),
                curve: Curves
                    .easeOutBack, // Gives it that satisfying "spring" feel
                // 2. THE BORDER FIX: Smoothly  the border changes and adds a glow
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  // Compensates exactly for the border width difference (1.5 margin + 1.0 border = 2.5 border) to prevent layout shifts
                  margin: EdgeInsets.all(isSelected ? 0.0 : 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.surface1,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                    //boxShadow: isSelected
                    //    ? [
                    //        BoxShadow(
                    //          color: Colors.white.withOpacity(0.25),
                    //          blurRadius: 8,
                    //          spreadRadius: 1,
                    //        ),
                    //      ]
                    //    : [],
                  ),
                  child: Stack(
                    // 1. THE OVERFLOW FIX: Tells the Stack to stop chopping off
                    // widgets that float outside its normal boundaries!
                    clipBehavior: Clip.none,

                    children: [
                      // The Base Avatar
                      Container(
                        width: 62,
                        height: 62,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            SafeNetworkImage(
                              'https://upload.wikimedia.org/wikipedia/commons/0/06/Elon_Musk%2C_2018_%28cropped%29.jpg',
                              fit: BoxFit.cover,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.white.withOpacity(0.25),
                                onTap: () {
                                  final current = ref.read(
                                    selectedProfileIndicesProvider,
                                  );
                                  if (current.contains(index)) {
                                    ref
                                        .read(
                                          selectedProfileIndicesProvider
                                              .notifier,
                                        )
                                        .state = {...current}
                                      ..remove(index);
                                  } else {
                                    ref
                                        .read(
                                          selectedProfileIndicesProvider
                                              .notifier,
                                        )
                                        .state = {...current}
                                      ..add(index);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. THE DIMMING FIX: Smoothly darkens avatars that are NOT selected
                      // THE DIMMING FIX: Smoothly darkens avatars that are NOT selected
                      IgnorePointer(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                        ),
                      ),

                      // 4. THE BADGE FIX: A checkmark that springs into existence
                      /*
                        Positioned(
                          bottom: 40,
                          right: -2,
                          child: AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut, // Very bouncy!
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .neonGreen, // Use your app's primary color here
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface1,
                                  width: 3.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ),

                        */
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 0),
                          curve: Curves.elasticOut, // Very bouncy!
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors
                                  .neonGreen, // Use your app's primary color here
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/checkmark.svg', // Make sure this matches your file path!
                              width: 10,
                              height: 10,
                              // This safely applies AppColors.surface1 to the entire SVG shape
                              colorFilter: const ColorFilter.mode(
                                AppColors.surface1,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
