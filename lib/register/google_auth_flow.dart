import 'package:flutter/material.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/home/home_page.dart';
import 'package:diplomka/register/register_helpers.dart';

Future<void> runGoogleSignIn(BuildContext context) async {
  try {
    final result = await AuthService.instance.signInWithGoogle();
    if (!context.mounted) return;
    if (result.firestoreWarning != null) {
      showRegisterWarning(context, result.firestoreWarning!);
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  } on AuthException catch (e) {
    if (context.mounted) showRegisterError(context, e.message);
  } catch (e) {
    if (context.mounted) {
      showRegisterError(context, 'Не удалось войти через Google: $e');
    }
  }
}
