import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';

/// Desktop sidebar navigation widget for web/desktop layouts
class DesktopSidebar extends ConsumerWidget {
  /// Callback when logout is pressed
  final VoidCallback? onLogout;

  const DesktopSidebar({super.key, this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerateMode = ref.watch(isGenerateModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 1100;

    return Container(
      width: isCompact ? 72 : 240,
      color: AppColors.surface1,
      child: Column(
        children: [
          // Logo section
          _buildLogo(isCompact),
          const Divider(color: AppColors.surface3, height: 1),
          const SizedBox(height: 16),
          // Navigation items
          Expanded(
            child: _buildNavigation(context, ref, isGenerateMode, isCompact),
          ),
          // Logout button at bottom
          _buildLogoutButton(context, ref, isCompact),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isCompact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: isCompact
          ? SvgPicture.asset(
              'assets/icons/logo.svg',
              width: 36,
              height: 36,
              colorFilter: const ColorFilter.mode(
                AppColors.neonGreen,
                BlendMode.srcIn,
              ),
            )
          : Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 32,
                  height: 32,
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
              ],
            ),
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    WidgetRef ref,
    bool isGenerateMode,
    bool isCompact,
  ) {
    return Column(
      children: [
        _NavItem(
          icon: Icons.add_circle_outline,
          label: 'Generate',
          isSelected: isGenerateMode,
          isCompact: isCompact,
          onTap: () {
            ref.read(isGenerateModeProvider.notifier).state = true;
          },
        ),
        const SizedBox(height: 4),
        _NavItem(
          icon: Icons.video_library_outlined,
          label: 'My Videos',
          isSelected: !isGenerateMode,
          isCompact: isCompact,
          onTap: () {
            ref.read(isGenerateModeProvider.notifier).state = false;
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    WidgetRef ref,
    bool isCompact,
  ) {
    return _NavItem(
      icon: Icons.logout,
      label: 'Logout',
      isSelected: false,
      isCompact: isCompact,
      isDestructive: true,
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
          await ref.read(authServiceProvider).signOut();
          onLogout?.call();
        }
      },
    );
  }
}

/// Navigation item widget for the sidebar
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final bool isDestructive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isSelected
        ? AppColors.neonGreen.withValues(alpha: 0.15)
        : _isHovered
        ? AppColors.surface2
        : Colors.transparent;

    final iconColor = widget.isDestructive
        ? AppColors.accentPink
        : widget.isSelected
        ? AppColors.neonGreen
        : AppColors.textSecondary;

    final textColor = widget.isDestructive
        ? AppColors.accentPink
        : widget.isSelected
        ? AppColors.neonGreen
        : AppColors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 8 : 12,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.isCompact
              ? Tooltip(
                  message: widget.label,
                  preferBelow: false,
                  child: Icon(widget.icon, color: iconColor, size: 24),
                )
              : Row(
                  children: [
                    Icon(widget.icon, color: iconColor, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
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
