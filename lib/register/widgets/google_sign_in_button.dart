import 'package:flutter/material.dart';
import 'package:diplomka/register/register_theme.dart';
import 'package:diplomka/register/widgets/google_logo.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Login with Google',
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool loading;

  /// Ближе к центрированному тексту (меньше зазор между иконкой и надписью).
  static const double _iconLeftPadding = 40;
  static const double _iconSize = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: RegisterTheme.buttonHeight,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: RegisterTheme.googleButtonBg,
          foregroundColor: RegisterTheme.primary,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: RegisterTheme.primary,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: _iconLeftPadding),
                      child: const GoogleLogo(size: _iconSize),
                    ),
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: RegisterTheme.buttonText.copyWith(color: RegisterTheme.primary),
                  ),
                ],
              ),
      ),
    );
  }
}
