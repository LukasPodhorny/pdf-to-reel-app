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
      width: double.infinity,
      height: 54.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          disabledBackgroundColor: backgroundColor.withOpacity(0.4),
          disabledForegroundColor: textColor.withOpacity(0.5),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
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
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: fontWeight,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
