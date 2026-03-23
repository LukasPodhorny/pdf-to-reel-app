import 'package:flutter/material.dart';
import '../widgets/auth_layout.dart';
import '../widgets/action_pill_button.dart';
import '../widgets/minimalist_input_field.dart';
import 'home_screen.dart';
import '../constants.dart';

class LoginPasswordScreen extends StatelessWidget {
  const LoginPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Enter password',
      children: [
        const MinimalistInputField(
          hintText: 'Password',
          isPassword: true,
        ),
        const SizedBox(height: 32),
        ActionPillButton(
          text: 'Log in',
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
          fontWeight: FontWeight.w600,
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
