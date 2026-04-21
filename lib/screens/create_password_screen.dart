import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = ref.read(signupEmailProvider);
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      ref.read(needsVerificationProvider.notifier).state = true;
      await ref.read(authServiceProvider).createUserWithEmailAndPassword(email, password);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ref.read(needsVerificationProvider.notifier).state = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create password',
      subtitle: 'Pick something at least 6 characters long.',
      children: [
        MinimalistInputField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 12),
        MinimalistInputField(
          controller: _confirmPasswordController,
          hintText: 'Confirm password',
          isPassword: true,
          prefixIcon: Icons.lock_outline,
        ),
        const SizedBox(height: 24),
        ActionPillButton(
          text: 'Create account',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: _isLoading ? null : () => _signUp(),
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
