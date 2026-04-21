import 'package:flutter/material.dart';
import '../constants.dart';

class MinimalistInputField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final IconData? prefixIcon;

  const MinimalistInputField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.prefixIcon,
  });

  @override
  State<MinimalistInputField> createState() => _MinimalistInputFieldState();
}

class _MinimalistInputFieldState extends State<MinimalistInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused
              ? AppColors.neonGreen.withOpacity(0.7)
              : AppColors.surface3.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(0.12),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _obscure : false,
        keyboardType: widget.keyboardType,
        cursorColor: AppColors.neonGreen,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.35),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: focused
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  size: 20,
                )
              : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
