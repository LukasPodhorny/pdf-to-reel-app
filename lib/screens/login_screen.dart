import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdftoreel/constants.dart';
import 'package:pdftoreel/services/auth_service.dart';
import 'home_screen.dart';
import 'create_account_screen.dart';
import 'email_login_screen.dart';
import '../widgets/action_pill_button.dart';

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
      // Navigation is handled by StreamBuilder in main.dart
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 190,
                  height: 182,
                  colorFilter: const ColorFilter.mode(
                    AppColors.neonGreen,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 30.0,
                bottom: 30.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ActionPillButton(
                      text: 'Continue with Google',
                      backgroundColor: AppColors.neonGreen,
                      textColor: AppColors.background,
                      fontWeight: FontWeight.w600,
                      icon: SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 23,
                        height: 23,
                      ),
                      onPressed: _isLoading ? null : _loginWithGoogle,
                    ),
                    const SizedBox(height: 16.0),
                    ActionPillButton(
                      text: 'Sign up with email',
                      backgroundColor: AppColors.surface2,
                      textColor: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      icon: SvgPicture.asset(
                        'assets/icons/mail.svg',
                        width: 22,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ActionPillButton(
                      text: 'Log in',
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      borderColor: AppColors.textSecondary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailLoginScreen(),
                          ),
                        );
                      },
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Center(child: AppLoadingIndicator()),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
