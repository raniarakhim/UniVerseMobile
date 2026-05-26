import 'package:flutter/material.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/session_service.dart';
import 'package:diplomka/home/home_page.dart';
import 'package:diplomka/register/forget_password_page.dart';
import 'package:diplomka/register/register_back_button.dart';
import 'package:diplomka/register/register_error_formatter.dart';
import 'package:diplomka/register/register_helpers.dart';
import 'package:diplomka/register/register_theme.dart';
import 'package:diplomka/register/signup_page.dart';
import 'package:diplomka/register/google_auth_flow.dart';
import 'package:diplomka/register/widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _passwordNotEmpty = false;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(_onPasswordChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryRestoreSession());
  }

  Future<void> _tryRestoreSession() async {
    final restored = await SessionService.instance.tryRestoreSession();
    if (!mounted || !restored) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
      (_) => false,
    );
  }

  void _onPasswordChanged() {
    final notEmpty = _passwordCtrl.text.isNotEmpty;
    if (notEmpty != _passwordNotEmpty) {
      setState(() => _passwordNotEmpty = notEmpty);
    }
  }

  @override
  void dispose() {
    _passwordCtrl.removeListener(_onPasswordChanged);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      await runGoogleSignIn(context);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (mounted) showRegisterError(context, e.message);
    } catch (e, stack) {
      debugPrint('Login error: $e\n$stack');
      if (mounted) showRegisterError(context, RegisterErrorFormatter.format(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegisterTheme.pageBackground,
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
                  'assets/Register/Login/Group 19.png',
                  width: double.infinity,
                  height: RegisterTheme.illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                const Text('Login', style: RegisterTheme.h2),
                const SizedBox(height: 32),
                const Text('Email Address', style: RegisterTheme.fieldLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: RegisterTheme.fieldLabel.copyWith(fontSize: 14),
                  decoration: RegisterTheme.fieldDecoration('Enter your email'),
                ),
                const SizedBox(height: 20),
                const Text('Password', style: RegisterTheme.fieldLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: RegisterTheme.fieldLabel.copyWith(fontSize: 14),
                  decoration: RegisterTheme.fieldDecoration('Enter your password').copyWith(
                    suffixIcon: RegisterTheme.passwordVisibilitySuffix(
                      show: _passwordNotEmpty,
                      obscured: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Forgot Password?', style: RegisterTheme.captionLink),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: RegisterTheme.primaryButtonStyle,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 16),
                RegisterTheme.orDivider(),
                const SizedBox(height: 16),
                GoogleSignInButton(
                  onPressed: _loginWithGoogle,
                  loading: _googleLoading,
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: "Don't have an account? ", style: RegisterTheme.footerMuted),
                          TextSpan(text: 'Sign Up', style: RegisterTheme.footerAction),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
