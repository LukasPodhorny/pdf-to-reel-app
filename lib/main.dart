import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart'; // <-- Update import
import 'screens/login_screen.dart';
import 'constants.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF to Reel',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(), // Start at the login screen
    );
  }
}
