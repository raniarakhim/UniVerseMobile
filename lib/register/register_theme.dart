import 'package:flutter/material.dart';

/// Стили регистрации/логина по макету Figma.
class RegisterTheme {
  RegisterTheme._();

  static const String fontFamily = 'SpaceGrotesk';

  static const Color pageBackground = Color(0xFFF8F7FF);
  static const Color primary = Color(0xFF1E1B4B);
  static const Color screenTitle = Color(0xFF293032);
  static const Color bodyText = Color(0xFF0F0E2A);
  static const Color hint = Color(0xFFA09DC5);
  static const Color muted = Color(0xFF5C6672);
  static const Color inputBorder = Color(0xFFEDE9FE);
  static const Color googleButtonBg = Color(0xFFF1F0F9);
  static const Color orLine = Color(0xFF6B7280);

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 41 / 32,
    color: screenTitle,
  );

  static const double orLineWidth = 50;

  static Widget orDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: orLineWidth,
          child: Divider(color: orLine, thickness: 0.5),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'OR',
            style: captionMuted.copyWith(
              fontSize: 11,
              height: 18 / 11,
              color: orLine,
            ),
          ),
        ),
        SizedBox(
          width: orLineWidth,
          child: Divider(color: orLine, thickness: 0.5),
        ),
      ],
    );
  }

  static Widget? passwordVisibilitySuffix({
    required bool show,
    required bool obscured,
    required VoidCallback onToggle,
  }) {
    if (!show) return null;
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: muted,
        size: 20,
      ),
    );
  }

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
    color: bodyText,
  );

  static const TextStyle fieldHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 15 / 12,
    color: hint,
  );

  static const TextStyle captionLink = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 15 / 12,
    color: primary,
  );

  static const TextStyle captionMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 15 / 12,
    color: muted,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 20 / 16,
  );

  /// Иллюстрации на экранах Login / Sign Up и т.д.
  static const double illustrationHeight = 280;

  static const TextStyle footerMuted = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
    color: muted,
  );

  static const TextStyle footerAction = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: primary,
  );

  static InputDecoration fieldDecoration(String hintText, {Widget? suffixIcon}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: inputBorder, width: 1),
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: fieldHint,
      filled: true,
      fillColor: pageBackground,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      isDense: true,
    );
  }

  static const double buttonHeight = 48;

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: const Size.fromHeight(buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    textStyle: buttonText.copyWith(color: Colors.white),
  );
}
