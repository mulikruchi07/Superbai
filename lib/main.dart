import 'package:flutter/material.dart';
import 'package:superbai/splash_screen.dart';
import 'package:superbai/theme.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuperBai App',
      theme: appTheme, // Apply your custom theme
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}