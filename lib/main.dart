import 'package:flutter/material.dart';
import 'package:M360/screen/login_screen.dart';
import 'package:M360/screen/splash_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M360',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login':(_)=> const LoginScreen(),

      },
    );
  }
}
