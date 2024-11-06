import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sokeconsulting/login.dart';
import 'package:sokeconsulting/palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Set system UI mode to immersive (full screen without system overlays)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Delayed navigation after 10 seconds to the LoginScreen
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Restore system UI mode when disposing
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.midnight, Palette.royalblue],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/sokesplash-removebg-preview.png', 
            width: 250.0, 
            height: 250.0, 
          ),
        ),
      ),
    );
  }
}
