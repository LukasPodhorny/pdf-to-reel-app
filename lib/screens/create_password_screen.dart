import 'package:flutter/material.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'enter_code_screen.dart';
import '../constants.dart';

class CreatePasswordScreen extends StatelessWidget {
  const CreatePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create password',
      children: [
        const MinimalistInputField(
          hintText: 'Password',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        const MinimalistInputField(
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EnterCodeScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
