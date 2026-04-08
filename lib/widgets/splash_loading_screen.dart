import 'package:flutter/material.dart';
import '../constants.dart';

class SplashLoadingScreen extends StatelessWidget {
  const SplashLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'PDF TO REEL',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
