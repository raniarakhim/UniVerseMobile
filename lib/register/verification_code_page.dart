import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/password_reset_service.dart';
import 'package:diplomka/register/models/password_reset_flow.dart';
import 'package:diplomka/register/register_back_button.dart';
import 'package:diplomka/register/register_helpers.dart';
import 'package:diplomka/register/register_theme.dart';
import 'package:diplomka/register/reset_password_page.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({super.key, required this.flow});

  final PasswordResetFlowArgs flow;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  static const Color _primary = Color(0xFF1B1E3D);
  static const Color _background = Color(0xFFF7F7F9);
  static const Color _secondary = Color(0xFF7D848D);
  static const Color _boxFill = Color(0xFFE5E9EF);
  static const _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 80;
  bool _verifying = false;
  bool _resending = false;

  PasswordResetFlowArgs get _flow => widget.flow;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 80);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() {});
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  String get _timerLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} min left';
  }

  String get _subtitle {
    if (_flow.channel == PasswordResetChannel.email) {
      return '6-значный код отправлен на ${_flow.maskedDestination}';
    }
    return '6-значный код из SMS отправлен на ${_flow.maskedDestination}';
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_code.length != _codeLength) {
      showRegisterError(context, 'Введите $_codeLength цифр');
      return;
    }

    setState(() => _verifying = true);
    try {
      if (_flow.channel == PasswordResetChannel.email) {
        final sessionId = _flow.sessionId;
        if (sessionId == null) throw AuthException('Нет сессии');
        final resetToken = await PasswordResetService.instance.verifyEmailOtp(
          sessionId: sessionId,
          code: _code,
        );
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              channel: PasswordResetChannel.email,
              sessionId: sessionId,
              resetToken: resetToken,
            ),
          ),
        );
      } else {
        final e164 = _flow.e164;
        final normalized = _flow.normalizedPhone;
        if (e164 == null || normalized == null) throw AuthException('Нет номера');
        await PasswordResetService.instance.verifyPhoneSmsAndSignIn(
          smsCode: _code,
          e164: e164,
        );
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(
              channel: PasswordResetChannel.phone,
              normalizedPhone: normalized,
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) showRegisterError(context, e.message);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    setState(() => _resending = true);
    try {
      if (_flow.channel == PasswordResetChannel.email) {
        final result = await PasswordResetService.instance.requestEmailOtp(_flow.target);
        if (mounted) {
          showRegisterSuccess(context, 'Новый код отправлен на ${result.maskedDestination}');
        }
      } else {
        final e164 = _flow.e164;
        if (e164 == null) throw AuthException('Нет номера');
        await PasswordResetService.instance.sendPhoneSmsCode(e164);
        if (mounted) showRegisterSuccess(context, 'SMS отправлено повторно');
      }
      _startTimer();
    } on AuthException catch (e) {
      if (mounted) showRegisterError(context, e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: RegisterBackButton(),
                ),
                const SizedBox(height: RegisterLayout.spacingAfterBack),
                Image.asset(
                  'assets/Register/VerificationCode/Group 19.png',
                  width: double.infinity,
                  height: RegisterTheme.illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verification code',
                  textAlign: TextAlign.center,
                  style: RegisterTheme.h2,
                ),
                const SizedBox(height: 12),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: _secondary,
                  ),
                ),
                if (_flow.devMode) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Режим разработки: смотрите код в логах Functions',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < _codeLength; index++) ...[
                      if (index > 0) const SizedBox(width: 8),
                      SizedBox(
                        width: 46,
                        height: 56,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1E28),
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _boxFill,
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
                              borderSide: const BorderSide(color: _primary, width: 1.5),
                            ),
                          ),
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _verifying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Verify',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: (_secondsLeft == 0 && !_resending) ? _resend : null,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _resending ? 'Sending…' : 'Resend Code',
                          style: TextStyle(
                            color: _secondsLeft == 0 ? _primary : _secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _timerLabel,
                        style: const TextStyle(
                          color: _secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
