import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'login_password_screen.dart';
import '../constants.dart';
import '../ui_providers.dart';
import '../services/auth_service.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final exists = await ref.read(authServiceProvider).checkIfUserExists(email);

      if (mounted) {
        if (exists) {
          ref.read(loginEmailProvider.notifier).state = email;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPasswordScreen(),
            ),
          );
        } else {
          setState(() => _errorMessage = 'No account found with this email.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Error checking email. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Enter your email to continue.',
      children: [
        MinimalistInputField(
          controller: _emailController,
          hintText: 'Email address',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        ActionPillButton(
          text: 'Continue',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: _isLoading ? null : _onContinue,
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
