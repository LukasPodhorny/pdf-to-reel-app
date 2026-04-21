import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdftoreel/constants.dart';
import 'package:pdftoreel/services/auth_service.dart';
import 'create_account_screen.dart';
import 'email_login_screen.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/auth_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _Brand(),
                  const Spacer(flex: 4),
                  _AuthActions(
                    isLoading: _isLoading,
                    onGoogle: _isLoading ? null : _loginWithGoogle,
                    onEmailSignup: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    onLogin: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailLoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const _TermsFootnote(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 120,
          height: 120,
          colorFilter: const ColorFilter.mode(
            AppColors.neonGreen,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'PDF to Reel',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Turn your documents into\nshort-form videos with AI.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _AuthActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onGoogle;
  final VoidCallback onEmailSignup;
  final VoidCallback onLogin;

  const _AuthActions({
    required this.isLoading,
    required this.onGoogle,
    required this.onEmailSignup,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ActionPillButton(
          text: 'Continue with Google',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          icon: SvgPicture.asset(
            'assets/icons/google.svg',
            width: 22,
            height: 22,
          ),
          onPressed: onGoogle,
        ),
        const SizedBox(height: 12),
        ActionPillButton(
          text: 'Sign up with email',
          backgroundColor: AppColors.surface2,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          icon: SvgPicture.asset(
            'assets/icons/mail.svg',
            width: 20,
          ),
          onPressed: onEmailSignup,
        ),
        const SizedBox(height: 20),
        const _OrDivider(),
        const SizedBox(height: 20),
        ActionPillButton(
          text: 'Log in',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.surface3,
          onPressed: onLogin,
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: AppLoadingIndicator()),
          ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: AppColors.surface3.withOpacity(0.5)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: AppColors.surface3.withOpacity(0.5)),
        ),
      ],
    );
  }
}

class _TermsFootnote extends StatelessWidget {
  const _TermsFootnote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'By continuing you agree to our Terms & Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 12,
        height: 1.4,
      ),
    );
  }
}

