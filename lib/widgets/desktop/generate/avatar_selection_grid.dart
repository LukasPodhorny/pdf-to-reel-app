import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import '../../../models/reel_models.dart';
import '../../../safe_network_image.dart';
import '../../../services/video_service.dart';
import '../../../ui_providers.dart';

/// Searchable grid of avatars used in the desktop configuration panel.
/// Reads the avatar list + selection directly from providers.
class AvatarSelectionGrid extends ConsumerStatefulWidget {
  const AvatarSelectionGrid({super.key});

  @override
  ConsumerState<AvatarSelectionGrid> createState() =>
      _AvatarSelectionGridState();
}

class _AvatarSelectionGridState extends ConsumerState<AvatarSelectionGrid> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarsAsync = ref.watch(avatarsListProvider);
    final selectedNames = ref.watch(selectedAvatarNamesProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surface3, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: (val) => setState(() => _query = val),
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
          const SizedBox(height: 12),
          Expanded(
            child: avatarsAsync.when(
              data: (avatars) {
                final q = _query.toLowerCase();
                final List<Avatar> filtered = q.isEmpty
                    ? avatars
                    : avatars.where((Avatar a) {
                        final displayName =
                            a.data['name']?.toString() ?? a.name;
                        return displayName.toLowerCase().contains(q);
                      }).toList();

                return ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thickness: WidgetStatePropertyAll(3),
                    radius: const Radius.circular(1.5),
                    thumbColor: WidgetStatePropertyAll(
                      AppColors.surface3.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(right: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final avatar = filtered[index];
                        final isSelected = selectedNames.contains(avatar.name);
                        final displayName =
                            avatar.data['name']?.toString() ?? avatar.name;

                        return _AvatarGridItem(
                          avatar: avatar,
                          isSelected: isSelected,
                          displayName: displayName,
                          onTap: () {
                            final current = ref.read(
                              selectedAvatarNamesProvider,
                            );
                            if (current.contains(avatar.name)) {
                              ref
                                  .read(selectedAvatarNamesProvider.notifier)
                                  .state = {...current}
                                ..remove(avatar.name);
                            } else if (current.length >= kMaxSelectedAvatars) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You can select up to $kMaxSelectedAvatars avatars',
                                  ),
                                ),
                              );
                            } else {
                              ref
                                  .read(selectedAvatarNamesProvider.notifier)
                                  .state = {...current}
                                ..add(avatar.name);
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              },
              loading: () => const Center(child: AppLoadingIndicator()),
              error: (err, _) =>
                  const Center(child: Icon(Icons.error, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarGridItem extends StatefulWidget {
  final Avatar avatar;
  final bool isSelected;
  final String displayName;
  final VoidCallback onTap;

  const _AvatarGridItem({
    required this.avatar,
    required this.isSelected,
    required this.displayName,
    required this.onTap,
  });

  @override
  State<_AvatarGridItem> createState() => _AvatarGridItemState();
}

class _AvatarGridItemState extends State<_AvatarGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.displayName,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: widget.isSelected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              margin: EdgeInsets.all(widget.isSelected ? 0.0 : 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? Colors.white : Colors.transparent,
                  width: widget.isSelected ? 2.5 : 1.0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
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
                          widget.avatar.staticFaceUrl ??
                              widget.avatar.faceUrl ??
                              '',
                          fit: BoxFit.cover,
                        ),
                        if (_isHovered)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.neonGreen,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/checkmark.svg',
                          width: 8,
                          height: 8,
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
          ),
        ),
      ),
    );
  }
}
