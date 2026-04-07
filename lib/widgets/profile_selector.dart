import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/video_service.dart';

class ProfileSelector extends ConsumerStatefulWidget {
  const ProfileSelector({super.key});

  @override
  ConsumerState<ProfileSelector> createState() => _ProfileSelectorState();
}

class _ProfileSelectorState extends ConsumerState<ProfileSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarsAsync = ref.watch(avatarsListProvider);
    final selectedNames = ref.watch(selectedAvatarNamesProvider);

    return Container(
      height: 84,
      margin: const EdgeInsets.symmetric(horizontal: 18.0),
      padding: const EdgeInsets.only(top: 0, bottom: 2, left: 2, right: 2),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surface2, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: RawScrollbar(
        controller: _scrollController,
        thumbColor: AppColors.surface2,
        radius: const Radius.circular(8),
        thickness: 3,
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
              stops: [-0.0, 0.05, 0.95, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: avatarsAsync.when(
            data: (avatars) {
              return ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                  top: 4,
                  bottom: 12,
                  left: 15,
                  right: 15,
                ),
                itemCount: avatars.length,
                separatorBuilder: (context, index) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  final avatar = avatars[index];
                  final isSelected = selectedNames.contains(avatar.name);

                  return AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      margin: EdgeInsets.all(isSelected ? 0.0 : 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : AppColors.surface1,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.background, // PNG background color
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                SafeNetworkImage(
                                  avatar.staticFaceUrl ?? avatar.faceUrl ?? '',
                                  fit: BoxFit.cover,
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.white.withOpacity(0.25),
                                    onTap: () {
                                      final current = ref.read(
                                        selectedAvatarNamesProvider,
                                      );
                                      if (current.contains(avatar.name)) {
                                        ref
                                            .read(
                                              selectedAvatarNamesProvider
                                                  .notifier,
                                            )
                                            .state = {...current}
                                          ..remove(avatar.name);
                                      } else {
                                        ref
                                            .read(
                                              selectedAvatarNamesProvider
                                                  .notifier,
                                            )
                                            .state = {...current}
                                          ..add(avatar.name);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: AppColors.neonGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/checkmark.svg',
                                  width: 10,
                                  height: 10,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.surface1,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: AppLoadingIndicator(),
            ),
            error: (err, stack) =>
                const Center(child: Icon(Icons.error, color: Colors.red)),
          ),
        ),
      ),
    );
  }
}
