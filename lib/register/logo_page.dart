import 'package:flutter/material.dart';
import 'package:diplomka/core/services/session_service.dart';
import 'package:diplomka/home/home_page.dart';
import 'package:diplomka/register/onboarding_page.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  bool _checking = false;

  Future<void> _onLogoTap() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final hasSession = await SessionService.instance.tryRestoreSession();
      if (!mounted) return;
      if (hasSession) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _checking ? null : _onLogoTap,
        child: SizedBox.expand(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/Register/Logo/transparent-Photoroom 1.png',
                  width: 300,
                  height: 300,
                ),
                if (_checking)
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
