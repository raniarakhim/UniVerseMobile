import 'package:flutter/material.dart';
import 'package:diplomka/register/onboarding_page.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingPage()),
          );
        },
        child: SizedBox.expand(
          child: Center(
            child: Image.asset(
              'assets/Register/Logo/transparent-Photoroom 1.png',
              width: 300,
              height: 300,
            ),
          ),
        ),
      ),
    );
  }
}
