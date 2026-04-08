import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdftoreel/constants.dart';
import 'package:pdftoreel/services/auth_service.dart';
import 'create_account_screen.dart';
import 'email_login_screen.dart';

/// Desktop login screen with centered card layout
class DesktopLoginScreen extends ConsumerStatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  ConsumerState<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends ConsumerState<DesktopLoginScreen> {
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surface1,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 80,
                    height: 80,
                    colorFilter: const ColorFilter.mode(
                      AppColors.neonGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  const Text(
                    'PDF to Reel',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  const Text(
                    'Create engaging videos with AI',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Google Sign In Button
                  _DesktopActionButton(
                    text: 'Continue with Google',
                    backgroundColor: AppColors.neonGreen,
                    textColor: AppColors.background,
                    fontWeight: FontWeight.w600,
                    icon: SvgPicture.asset(
                      'assets/icons/google.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  // Sign up with email
                  _DesktopActionButton(
                    text: 'Sign up with email',
                    backgroundColor: AppColors.surface2,
                    textColor: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    icon: SvgPicture.asset(
                      'assets/icons/mail.svg',
                      width: 24,
                      height: 24,
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
                  const SizedBox(height: 16),
                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: AppColors.surface3),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: AppColors.surface3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Log in button
                  _DesktopActionButton(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop action button with hover effects
class _DesktopActionButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final Widget? icon;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final bool isLoading;

  const _DesktopActionButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
    this.icon,
    this.onPressed,
    this.borderColor,
    this.isLoading = false,
  });

  @override
  State<_DesktopActionButton> createState() => _DesktopActionButtonState();
}

class _DesktopActionButtonState extends State<_DesktopActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final bgColor = _isHovered && !isDisabled
        ? AppColors.surface2
        : widget.backgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 12),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 16,
                          fontWeight: widget.fontWeight,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
