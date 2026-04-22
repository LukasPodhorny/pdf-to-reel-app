import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'create_password_screen.dart';
import '../constants.dart';
import '../ui_providers.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create account',
      subtitle: 'Enter your email to continue.',
      children: [
        MinimalistInputField(
          controller: _emailController,
          hintText: 'Email address',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
        ),
        const SizedBox(height: 24),
        ActionPillButton(
          text: 'Continue',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
          onPressed: () {
            ref.read(signupEmailProvider.notifier).state = _emailController.text;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatePasswordScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
