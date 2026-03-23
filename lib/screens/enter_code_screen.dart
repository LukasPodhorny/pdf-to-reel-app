import 'package:flutter/material.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'home_screen.dart';
import '../constants.dart';

class EnterCodeScreen extends StatelessWidget {
  const EnterCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Enter code',
      children: [
        const MinimalistInputField(
          hintText: 'Verification code',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 32),
        ActionPillButton(
          text: 'Continue',
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          borderColor: AppColors.textSecondary,
          onPressed: () {
            // Clears navigation stack and enters the app
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
