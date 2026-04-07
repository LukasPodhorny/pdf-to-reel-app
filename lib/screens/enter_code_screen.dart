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
    // Auto-check every 3 seconds
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
    return AuthLayout(
      title: 'Verify email',
      children: [
        const Text(
          "We've sent a verification link to your email address. Please click the link in the email to continue.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 32),
        ActionPillButton(
          text: 'I have verified',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: _isChecking ? null : () async {
            setState(() => _isChecking = true);
            await _checkEmailVerified();
            if (mounted) {
              setState(() => _isChecking = false);
              if (!(ref.read(authServiceProvider).currentUser?.emailVerified ?? false)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email not verified yet. Please check your inbox.')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 16),
        ActionPillButton(
          text: 'Resend email',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.textSecondary,
          onPressed: _resendEmail,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Allow going back to login
            ref.read(authServiceProvider).signOut();
            ref.read(needsVerificationProvider.notifier).state = false;
          },
          child: const Text(
            'Back to login',
            style: TextStyle(color: AppColors.textSecondary),
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
