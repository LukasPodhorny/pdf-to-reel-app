import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../safe_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/video_service.dart';
import '../models/reel_models.dart';

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

  void _openAvatarSearch(List<Avatar> avatars) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AvatarSearchSheet(avatars: avatars),
    );
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
                itemCount: avatars.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 5),
                itemBuilder: (context, index) {
                  // First item is the search button
                  if (index == 0) {
                    return Container(
                      width: 62,
                      height: 62,
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface2,
                        border: Border.all(
                          color: AppColors.surface3,
                          width: 1.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.white.withValues(alpha: 0.25),
                          onTap: () => _openAvatarSearch(avatars),
                          child: const Center(
                            child: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final avatar = avatars[index - 1];
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
                              image: DecorationImage(
                                image: AssetImage('assets/images/minecraft_bg.jpg'),
                                fit: BoxFit.cover,
                              ),
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

class _AvatarSearchSheet extends ConsumerStatefulWidget {
  final List<Avatar> avatars;

  const _AvatarSearchSheet({required this.avatars});

  @override
  ConsumerState<_AvatarSearchSheet> createState() => _AvatarSearchSheetState();
}

class _AvatarSearchSheetState extends ConsumerState<_AvatarSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNames = ref.watch(selectedAvatarNamesProvider);
    final query = _searchQuery.toLowerCase();
    final filtered = query.isEmpty
        ? widget.avatars
        : widget.avatars.where((a) {
            final displayName = a.data['name']?.toString() ?? a.name;
            return displayName.toLowerCase().contains(query);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surface3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search field
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surface3, width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'search for avatars...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Avatar grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final avatar = filtered[index];
                final isSelected = selectedNames.contains(avatar.name);
                final displayName = avatar.data['name']?.toString() ?? avatar.name;

                return Tooltip(
                  message: displayName,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Border container (on top of image)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/minecraft_bg.jpg'),
                              fit: BoxFit.cover,
                            ),
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
                                  splashColor: Colors.white.withValues(alpha: 0.25),
                                  onTap: () {
                                    final current = ref.read(selectedAvatarNamesProvider);
                                    if (current.contains(avatar.name)) {
                                      ref
                                          .read(selectedAvatarNamesProvider.notifier)
                                          .state = {...current}..remove(avatar.name);
                                    } else {
                                      ref
                                          .read(selectedAvatarNamesProvider.notifier)
                                          .state = {...current}..add(avatar.name);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
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
                              width: 12,
                              height: 12,
                              colorFilter: const ColorFilter.mode(
                                AppColors.surface1,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
