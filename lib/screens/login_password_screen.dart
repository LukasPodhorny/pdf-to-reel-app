import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';

class LoginPasswordScreen extends ConsumerStatefulWidget {
  const LoginPasswordScreen({super.key});

  @override
  ConsumerState<LoginPasswordScreen> createState() =>
      _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends ConsumerState<LoginPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = ref.read(loginEmailProvider);
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmailAndPassword(email, password);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = ref.read(loginEmailProvider);
    if (email.isEmpty) return;

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(loginEmailProvider);

    return AuthLayout(
      title: 'Enter password',
      subtitle: email.isNotEmpty ? 'Signing in as $email' : null,
      children: [
        MinimalistInputField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ActionPillButton(
          text: 'Log in',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: _isLoading ? null : () => _login(),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: AppLoadingIndicator()),
          ),
      ],
    );
  }
}
