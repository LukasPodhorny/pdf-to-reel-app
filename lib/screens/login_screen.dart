import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pdftoreel/constants.dart';
import 'home_screen.dart';
import 'create_account_screen.dart';
import 'email_login_screen.dart';
import '../widgets/action_pill_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Darkest background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top section with Logo
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/icons/logo.png',
                  width: 190,
                  height: 182,
                ),
              ),
            ),

            // Bottom section with buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 30.0,
                bottom: 30.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface1, // Slightly lighter dark background
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Continue with Google Button
                    ActionPillButton(
                      text: 'Continue with Google',
                      backgroundColor: AppColors.neonGreen, // Bright Green
                      textColor: AppColors.background,
                      fontWeight: FontWeight.w600,
                      // Note: You might want to use a Google logo asset here instead of an Icon
                      icon: SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 23,
                        height: 23,
                        // If you want to force a color on the SVG, uncomment the line below:
                        // colorFilter: const ColorFilter.mode(Color(0xFF3CD249), BlendMode.srcIn),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Sign up with email Button
                    ActionPillButton(
                      text: 'Sign up with email',
                      backgroundColor: AppColors.surface2, // Dark Gray
                      textColor: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      icon: SvgPicture.asset(
                        'assets/icons/mail.svg',
                        width: 22,
                        // If you want to force a color on the SVG, uncomment the line below:
                        // colorFilter: const ColorFilter.mode(Color(0xFF3CD249), BlendMode.srcIn),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Log in Button
                    ActionPillButton(
                      text: 'Log in',
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      borderColor: AppColors.textSecondary, // Outline Color
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailLoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
