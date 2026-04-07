import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/enter_code_screen.dart';
import 'screens/desktop_login_screen.dart';
import 'screens/desktop_home_screen.dart';
import 'constants.dart';
import 'services/auth_service.dart';
import 'ui_providers.dart';
import 'firebase_options.dart';
import 'widgets/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We listen to authStateChanges directly.
    // Riverpod's StreamProvider is cleaner, but using authStateChanges stream is fine too.
    final authService = ref.watch(authServiceProvider);
    final needsVerification = ref.watch(needsVerificationProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF to Reel',
      theme: AppTheme.darkTheme,
      home: StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          // If Firebase is still calculating the auth state, show a splash screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: AppLoadingIndicator()));
          }

          final user = snapshot.data;

          if (user != null) {
            // User is logged in.
            if (needsVerification && !user.emailVerified) {
              return ResponsiveLayout(
                mobileWidget: const EnterCodeScreen(),
                desktopWidget:
                    const EnterCodeScreen(), // Verification stays simple
              );
            }
            // Logic for verification screen:
            // If the user signed up but hasn't verified, show verification.
            // Note: Google users are automatically verified.
            return ResponsiveLayout(
              mobileWidget: const HomeScreen(),
              desktopWidget: const DesktopHomeScreen(),
            );
          }

          // User is NOT logged in.
          return ResponsiveLayout(
            mobileWidget: const LoginScreen(),
            desktopWidget: const DesktopLoginScreen(),
          );
        },
      ),
    );
  }
}
