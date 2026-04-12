import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../safe_network_image.dart';

/// Desktop sidebar matching the Figma design:
/// - Logo + credits at top
/// - generate / videos nav
/// - account / log out at bottom
/// - 1px border on right edge
class DesktopSidebar extends ConsumerWidget {
  final VoidCallback? onLogout;

  const DesktopSidebar({super.key, this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(desktopTabProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        border: Border(right: BorderSide(color: AppColors.surface3, width: 1)),
      ),
      child: Column(
        children: [
          // Logo + credits header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    AppColors.neonGreen,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(width: 12),
                const Text(
                  'PDF to Reel',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 30),
                // Credits
                userProfileAsync.maybeWhen(
                  data: (profile) => Row(
                    children: [
                      Text(
                        '${profile.credits}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
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
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.surface3, height: 1),
          const SizedBox(height: 16),

          // Navigation items — use SVG icons from assets/icons/
          _SidebarNavItem(
            svgAsset: 'assets/icons/generate_icon.svg',
            label: 'generate',
            isSelected: activeTab == DesktopTab.generate,
            onTap: () {
              ref.read(desktopTabProvider.notifier).state = DesktopTab.generate;
              ref.read(isGenerateModeProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 4),
          _SidebarNavItem(
            svgAsset: 'assets/icons/video_icon.svg',
            label: 'videos',
            isSelected: activeTab == DesktopTab.videos,
            onTap: () {
              ref.read(selectedSeriesProvider.notifier).state = null;
              ref.read(desktopTabProvider.notifier).state = DesktopTab.videos;
              ref.read(isGenerateModeProvider.notifier).state = false;
            },
          ),

          const Spacer(),

          // Account
          Builder(builder: (context) {
            final photoUrl = ref.watch(authServiceProvider).currentUser?.photoURL;
            return _SidebarNavItem(
              svgAsset: 'assets/icons/account_icon.svg',
              label: 'account',
              isSelected: activeTab == DesktopTab.account,
              onTap: () {
                ref.read(desktopTabProvider.notifier).state = DesktopTab.account;
              },
              iconOverride: photoUrl != null
                  ? Container(
                      width: 22,
                      height: 22,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: SafeNetworkImage(photoUrl, fit: BoxFit.cover),
                    )
                  : null,
            );
          }),
          const SizedBox(height: 4),

          // Log out
          _SidebarNavItem(
            svgAsset: 'assets/icons/logout_icon.svg',
            label: 'log out',
            isSelected: false,
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.accentPink),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                ref.read(needsVerificationProvider.notifier).state = false;
                ref.read(selectedAvatarNamesProvider.notifier).state = {};
                ref.read(selectedTemplateNameProvider.notifier).state = null;
                ref.read(uploadedFileKeysProvider.notifier).state = [];
                await ref.read(authServiceProvider).signOut();
                onLogout?.call();
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final String svgAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? iconOverride;

  const _SidebarNavItem({
    required this.svgAsset,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconOverride,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Selected = neonGreen at 20% opacity background, white text/icon
    // Hovered = surface2 background
    final backgroundColor = widget.isSelected
        ? AppColors.neonGreen.withValues(alpha: 0.20)
        : _isHovered
        ? AppColors.surface2
        : AppColors.surface2.withValues(alpha: 0);

    final contentColor = widget.isSelected
        ? AppColors.textPrimary
        : AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              widget.iconOverride ?? SvgPicture.asset(
                widget.svgAsset,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 15,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
