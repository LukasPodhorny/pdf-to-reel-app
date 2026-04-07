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
      // 1. Set verification flag BEFORE signup
      // This prevents the StreamBuilder in main.dart from jumping to HomeScreen immediately
      ref.read(needsVerificationProvider.notifier).state = true;

      // 2. Create the user
      await ref.read(authServiceProvider).createUserWithEmailAndPassword(email, password);
      
      // 3. Clear navigation stack
      // The StreamBuilder in main.dart will now automatically show the EnterCodeScreen
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Reset verification flag on error
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
      children: [
        MinimalistInputField(
          controller: _passwordController,
          hintText: 'Password',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        MinimalistInputField(
          controller: _confirmPasswordController,
          hintText: 'Confirm password',
          isPassword: true,
        ),
        const SizedBox(height: 32),
        ActionPillButton(
          text: 'Continue',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.textSecondary,
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
