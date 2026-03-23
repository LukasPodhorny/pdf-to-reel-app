import 'package:flutter/material.dart';
import 'package:pdftoreel/safe_network_image.dart';
import '../constants.dart';
import '../screens/login_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Occupies roughly 2/3 of horizontal space
    final width = MediaQuery.of(context).size.width * (2 / 3);

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
              child: Column(
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
                    child: SafeNetworkImage(
                      'https://lh3.googleusercontent.com/a/ACg8ocLOt8f8l8oCHwobmVRCCBZrkAcdmwHakrZ2c0tkFlB5a4-TG59a=s576-c-no',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'user@example.com',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
              onTap: () {
                // Clear the navigation stack and go back to LoginScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
