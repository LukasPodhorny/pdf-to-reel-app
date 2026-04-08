import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../safe_network_image.dart';

/// Desktop account screen matching the Figma design:
/// - Profile info (avatar, credits, tier, email) at top
/// - Pricing cards below
class DesktopAccountScreen extends ConsumerWidget {
  const DesktopAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          userProfileAsync.when(
            data: (profile) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.surface2,
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
                          size: 36,
                        ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Credits + tier
                    Row(
                      children: [
                        Text(
                          '${profile.credits}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SvgPicture.asset(
                          'assets/icons/credit.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'free tier',
                          style: TextStyle(
                            color: AppColors.freeTierPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      profile.email ?? 'No email',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (err, _) =>
                Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 32),
          const Divider(color: AppColors.surface2, height: 1),
          const SizedBox(height: 32),

          // Upgrade section
          const Text(
            'Upgrade your plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Coming soon...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Pricing cards
          /*
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 700
                  ? 300.0
                  : (constraints.maxWidth - 24) / 2;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const _PricingCard(
                      title: 'PDF to Reel Pro',
                      price: '10\$ / month',
                      features: ['250 credits per month', 'Fastest generation'],
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const _PricingCard(
                      title: 'PDF to Reel ULTRA',
                      price: '25\$ / month',
                      features: ['250 credits per month', 'Fastest generation'],
                    ),
                  ),
                ],
              );
            },
          ),
          */
        ],
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  final String title;
  final String price;
  final List<String> features;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.surface4 : AppColors.surface2,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Features list (price first, then features)
            _bulletItem(widget.price),
            ...widget.features.map((f) => _bulletItem(f)),
            const SizedBox(height: 16),
            // Subscribe button
            _SubscribeButton(),
          ],
        ),
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeButton extends StatefulWidget {
  @override
  State<_SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscriptions coming soon!')),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.neonGreen.withValues(alpha: 0.85)
                : AppColors.neonGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Subscribe now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
