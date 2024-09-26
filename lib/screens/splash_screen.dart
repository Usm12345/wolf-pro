import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolfpak/components/logo.dart';
import 'package:wolfpak/components/mascot.dart';
import 'package:wolfpak/components/typography.dart';
import 'package:wolfpak/constants/gap.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const int splashScreenDuration = 3;

  @override
  void initState() {
    super.initState();
    _navigateBasedOnCondition();
  }

  Future<void> _navigateBasedOnCondition() async {
    Future delay =
        Future.delayed(const Duration(seconds: splashScreenDuration));
    bool isLoggedIn = await _checkSignInStatus();
    await delay;

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/sign-in');
    }
  }

  Future<bool> _checkSignInStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userUuid');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Mascot(height: 192),
                  gap32,
                  Logo(),
                  H1("Kelter Innovations"),
                  gap4,
                  Slogan(
                    "Leader in mobile, renewable power, and connectivity.",
                  ),
                ],
              ),
            ),
            Center(child: Small("www.kelterinnovations.com")),
          ],
        ),
      ),
    );
  }
}
