import 'package:flutter/material.dart';

class ActionPillButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final Widget? icon;
  final VoidCallback? onPressed;
  final FontWeight fontWeight;

  const ActionPillButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
    this.borderColor,
    this.icon,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Automatically stretches to fill padded parent
      height: 57.0, // Fixed height for uniformity
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1.0)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 12.0)],
            Text(
              text,
              style: TextStyle(fontSize: 17.0, fontWeight: fontWeight),
            ),
          ],
        ),
      ),
    );
  }
}
