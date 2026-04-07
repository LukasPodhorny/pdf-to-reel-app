import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdftoreel/safe_network_image.dart';
import '../constants.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../ui_providers.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width * (2 / 3);
    final userProfileAsync = ref.watch(userProfileProvider);
    final authService = ref.watch(authServiceProvider);
    final currentUser = authService.currentUser;

    return Drawer(
      width: width,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: userProfileAsync.when(
                data: (profile) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.surface1,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: currentUser?.photoURL != null
                          ? SafeNetworkImage(
                              currentUser!.photoURL!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.email ?? 'No email',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Credits: ${profile.credits}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(
                  child: AppLoadingIndicator(),
                ),
                error: (err, stack) => const Text('Error loading profile'),
              ),
            ),

            const Spacer(),
            const Divider(color: AppColors.surface1, thickness: 1, height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              leading: const Icon(Icons.logout, color: AppColors.textPrimary),
              title: const Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                // 1. Close the drawer immediately
                Navigator.of(context).pop();

                // 2. Clear all local state providers to prevent data leaking between users
                ref.read(needsVerificationProvider.notifier).state = false;
                ref.read(selectedAvatarNamesProvider.notifier).state = {};
                ref.read(selectedTemplateNameProvider.notifier).state = null;
                ref.read(uploadedFileKeysProvider.notifier).state = [];

                // 3. Sign out from Firebase and Google
                await authService.signOut();

                // The StreamBuilder in main.dart will detect the null user and show the LoginScreen.
              },
            ),
          ],
        ),
      ),
    );
  }
}
