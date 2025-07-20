import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:superbai/splash_screen.dart';
import 'package:superbai/theme.dart';

// The main entry point of the application.
// It's now async to allow for Firebase initialization before running the app.
void main() async {
  // This is required to ensure that plugin services are initialized before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase. This must be done before any other Firebase services are used.
  await Firebase.initializeApp();

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
