import 'package:flutter/material.dart';

void showRegisterError(BuildContext context, String message) {
  final text = message.trim().isEmpty || message == 'Error'
      ? 'Неизвестная ошибка. См. консоль браузера (F12).'
      : message;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text, maxLines: 4),
        backgroundColor: const Color(0xFFB91C1C),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showRegisterSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E1B4B),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void showRegisterWarning(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3),
        backgroundColor: const Color(0xFF92400E),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
