import 'package:flutter/material.dart';

/// Общие отступы для экранов регистрации/авторизации.
abstract final class RegisterLayout {
  static const double horizontalPadding = 24;
  static const double topPadding = 8;
  static const double spacingAfterBack = 12;
}

/// Кнопка «назад» на одном уровне на всех экранах.
class RegisterBackButton extends StatelessWidget {
  const RegisterBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 48, height: 48),
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
