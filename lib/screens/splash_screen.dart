import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:checkpoint6/screens/intro_screen.dart';
import 'package:checkpoint6/core/auth_guard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndIntro();
  }

Future<void> _checkAuthAndIntro() async {
  await Future.delayed(const Duration(seconds: 3));

  final prefs = await SharedPreferences.getInstance();
  final bool introSeen = prefs.getBool('intro_seen') ?? false;

  if (!context.mounted) return;

  if (!introSeen) {
    // 1. Se NUNCA viu a intro, vai para IntroScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const IntroScreen()),
    );
  } else {
    // 2. Se JÁ VIU a intro, vai para o AuthGuard
    // (e o AuthGuard decide se mostra Login ou Home)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGuard()),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Lottie.asset(
          'assets/animations/Enter Password.json', 
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}