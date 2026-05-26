import 'package:flutter/material.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/password_reset_service.dart';
import 'package:diplomka/core/utils/phone_utils.dart';
import 'package:diplomka/register/models/password_reset_flow.dart';
import 'package:diplomka/register/register_back_button.dart';
import 'package:diplomka/register/register_helpers.dart';
import 'package:diplomka/register/register_theme.dart';
import 'package:diplomka/register/verification_code_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  static const Color _primary = Color(0xFF1C1C44);
  static const Color _background = Color(0xFFF8F8FB);
  static const Color _hint = Color(0xFFA09DC5);
  static const Color _body = Color(0xFF666666);

  final _inputCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _inputCtrl.text.trim();
    if (raw.isEmpty) {
      showRegisterError(context, 'Введите email или номер телефона');
      return;
    }

    setState(() => _loading = true);
    try {
      final reset = PasswordResetService.instance;
      if (reset.isEmailInput(raw)) {
        await _startEmailFlow(raw);
      } else {
        await _startPhoneFlow(raw);
      }
    } on AuthException catch (e) {
      if (mounted) showRegisterError(context, e.message);
    } catch (e) {
      if (mounted) showRegisterError(context, '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startEmailFlow(String email) async {
    final result = await PasswordResetService.instance.requestEmailOtp(email);
    if (!mounted) return;

    if (result.devMode) {
      showRegisterWarning(
        context,
        'Письмо не настроено на сервере. Код в логах Firebase Functions (см. PASSWORD_RESET_SETUP.md).',
      );
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodePage(
          flow: PasswordResetFlowArgs(
            channel: PasswordResetChannel.email,
            target: email.trim().toLowerCase(),
            maskedDestination: result.maskedDestination,
            sessionId: result.sessionId,
            devMode: result.devMode,
          ),
        ),
      ),
    );
  }

  Future<void> _startPhoneFlow(String phone) async {
    final normalized = normalizePhone(phone);
    final e164 = formatPhoneE164(phone);
    if (e164.isEmpty || normalized.length < 10) {
      throw AuthException('Введите корректный номер телефона');
    }

    await PasswordResetService.instance.ensurePhoneRegistered(normalized);
    await PasswordResetService.instance.sendPhoneSmsCode(e164);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationCodePage(
          flow: PasswordResetFlowArgs(
            channel: PasswordResetChannel.phone,
            target: e164,
            maskedDestination: maskPhone(e164),
            normalizedPhone: normalized,
            e164: e164,
          ),
        ),
      ),
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RegisterBackButton(),
                const SizedBox(height: RegisterLayout.spacingAfterBack),
                Image.asset(
                  'assets/Register/ForgetPassword/Group 19.png',
                  width: double.infinity,
                  height: RegisterTheme.illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text('Forget Password?', style: RegisterTheme.h2),
                const SizedBox(height: 12),
                const Text(
                  'Введите email — придёт 6-значный код на почту. '
                  'Введите телефон — придёт SMS-код (нужен Phone в Firebase).',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: _body,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Email или номер телефона',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _inputCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _loading ? null : _submit(),
                  decoration: InputDecoration(
                    hintText: 'email@example.com или +7 701 123 4567',
                    hintStyle: const TextStyle(color: _hint, fontSize: 15),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Отправить код',
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
