import 'package:flutter/material.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'create_password_screen.dart';
import '../constants.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create account',
      children: [
        const MinimalistInputField(
          hintText: 'Email address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        ActionPillButton(
          text: 'Continue',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.textSecondary, // Outline Color
          onPressed: () {
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
