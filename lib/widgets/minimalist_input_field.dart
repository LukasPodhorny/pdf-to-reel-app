import 'package:flutter/material.dart';
import '../constants.dart';

class MinimalistInputField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;

  const MinimalistInputField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword,
      obscuringCharacter: '●',
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textPrimary.withOpacity(0.4),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.surface1, // Slightly lighter dark background
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
