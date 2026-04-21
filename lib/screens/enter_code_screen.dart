import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';

class EnterCodeScreen extends ConsumerStatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  ConsumerState<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends ConsumerState<EnterCodeScreen> {
  bool _isChecking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final authService = ref.read(authServiceProvider);
    await authService.reloadUser();

    if (authService.currentUser?.emailVerified ?? false) {
      _timer?.cancel();
      if (mounted) {
        ref.read(needsVerificationProvider.notifier).state = false;
      }
    }
  }

  Future<void> _resendEmail() async {
    try {
      await ref.read(authServiceProvider).currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.read(authServiceProvider).currentUser?.email;

    return AuthLayout(
      title: 'Verify your email',
      subtitle: email != null
          ? "We've sent a verification link to $email. Click the link in the email to continue."
          : "We've sent you a verification link. Click it in your inbox to continue.",
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface1.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.surface3.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.neonGreen,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Waiting for verification…',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neonGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ActionPillButton(
          text: 'I have verified',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: _isChecking
              ? null
              : () async {
                  setState(() => _isChecking = true);
                  await _checkEmailVerified();
                  if (mounted) {
                    setState(() => _isChecking = false);
                    if (!(ref
                            .read(authServiceProvider)
                            .currentUser
                            ?.emailVerified ??
                        false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Email not verified yet. Please check your inbox.',
                          ),
                        ),
                      );
                    }
                  }
                },
        ),
        const SizedBox(height: 12),
        ActionPillButton(
          text: 'Resend email',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.surface3,
          onPressed: _resendEmail,
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
              ref.read(needsVerificationProvider.notifier).state = false;
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Back to login',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (_isChecking)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: AppLoadingIndicator()),
          ),
      ],
    );
  }
}
