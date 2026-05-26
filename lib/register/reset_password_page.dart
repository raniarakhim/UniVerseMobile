import 'package:flutter/material.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/password_reset_service.dart';
import 'package:diplomka/register/login_page.dart';
import 'package:diplomka/register/models/password_reset_flow.dart';
import 'package:diplomka/register/register_back_button.dart';
import 'package:diplomka/register/register_helpers.dart';
import 'package:diplomka/register/register_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.channel,
    this.sessionId,
    this.resetToken,
    this.normalizedPhone,
  });

  final PasswordResetChannel channel;
  final String? sessionId;
  final String? resetToken;
  final String? normalizedPhone;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _passwordNotEmpty = false;
  bool _confirmNotEmpty = false;
  bool _saving = false;

  static const Color _primary = Color(0xFF1A1C3D);
  static const Color _inputFill = Color(0xFFF3F3FA);
  static const Color _hint = Color(0xFFA09DC5);
  static const Color _muted = Color(0xFF5C6672);

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_onPasswordChanged);
    _confirmCtrl.addListener(_onConfirmChanged);
  }

  void _onPasswordChanged() {
    final notEmpty = _passwordCtrl.text.isNotEmpty;
    if (notEmpty != _passwordNotEmpty) {
      setState(() => _passwordNotEmpty = notEmpty);
    }
  }

  void _onConfirmChanged() {
    final notEmpty = _confirmCtrl.text.isNotEmpty;
    if (notEmpty != _confirmNotEmpty) {
      setState(() => _confirmNotEmpty = notEmpty);
    }
  }

  @override
  void dispose() {
    _passwordCtrl.removeListener(_onPasswordChanged);
    _confirmCtrl.removeListener(_onConfirmChanged);
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 15),
      filled: true,
      fillColor: _inputFill,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Future<void> _reset() async {
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;
    if (password.length < 6) {
      showRegisterError(context, 'Пароль — минимум 6 символов');
      return;
    }
    if (password != confirm) {
      showRegisterError(context, 'Пароли не совпадают');
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.channel == PasswordResetChannel.email) {
        final sessionId = widget.sessionId;
        final resetToken = widget.resetToken;
        if (sessionId == null || resetToken == null) {
          throw AuthException('Сессия сброса недействительна');
        }
        await PasswordResetService.instance.completeEmailPasswordReset(
          sessionId: sessionId,
          resetToken: resetToken,
          newPassword: password,
        );
      } else {
        final phone = widget.normalizedPhone;
        if (phone == null) throw AuthException('Нет номера телефона');
        await PasswordResetService.instance.completePhonePasswordReset(
          normalizedPhone: phone,
          newPassword: password,
        );
      }

      if (!mounted) return;
      showRegisterSuccess(context, 'Пароль обновлён. Войдите с новым паролем.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showRegisterError(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              RegisterLayout.horizontalPadding,
              RegisterLayout.topPadding,
              RegisterLayout.horizontalPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RegisterBackButton(),
                const SizedBox(height: RegisterLayout.spacingAfterBack),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/Register/ResetPassword/Group 19.png',
                  width: double.infinity,
                  height: RegisterTheme.illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text('Reset Password', style: RegisterTheme.h2),
                const SizedBox(height: 32),
                const Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: _fieldDecoration(
                    'Create a password',
                    suffixIcon: RegisterTheme.passwordVisibilitySuffix(
                      show: _passwordNotEmpty,
                      obscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirm New Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: _fieldDecoration(
                    'Repeat your password',
                    suffixIcon: RegisterTheme.passwordVisibilitySuffix(
                      show: _confirmNotEmpty,
                      obscured: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
