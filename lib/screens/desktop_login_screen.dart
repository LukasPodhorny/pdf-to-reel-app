import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdftoreel/constants.dart';
import 'package:pdftoreel/services/auth_service.dart';
import 'create_account_screen.dart';
import 'email_login_screen.dart';
import '../widgets/auth_background.dart';

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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 44,
                    vertical: 48,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface1,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.surface3.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          'assets/icons/logo.svg',
                          width: 64,
                          height: 64,
                          colorFilter: const ColorFilter.mode(
                            AppColors.neonGreen,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'PDF to Reel',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Turn one prompt into engaging videos with AI.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _DesktopActionButton(
                        text: 'Continue with Google',
                        backgroundColor: AppColors.neonGreen,
                        textColor: AppColors.background,
                        fontWeight: FontWeight.w600,
                        icon: SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 22,
                          height: 22,
                        ),
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 12),
                      _DesktopActionButton(
                        text: 'Sign up with email',
                        backgroundColor: AppColors.surface2,
                        textColor: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        icon: SvgPicture.asset(
                          'assets/icons/mail.svg',
                          width: 22,
                          height: 22,
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.surface3.withOpacity(0.5),
                            ),
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
                            child: Container(
                              height: 1,
                              color: AppColors.surface3.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DesktopActionButton(
                        text: 'Log in',
                        backgroundColor: Colors.transparent,
                        textColor: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        borderColor: AppColors.surface3,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmailLoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'By continuing you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
        ? Color.lerp(widget.backgroundColor, Colors.white, 0.06)
        : widget.backgroundColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 54,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1)
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
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
                          letterSpacing: 0.1,
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
