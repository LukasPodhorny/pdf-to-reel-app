import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/video_generator_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF to Reel',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromRGBO(30, 30, 30, 1),
        useMaterial3: true,
      ),
      home: const VideoGeneratorScreen(),
    );
  }
}
