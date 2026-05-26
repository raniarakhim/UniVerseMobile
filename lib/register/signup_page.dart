import 'package:flutter/material.dart';
import 'package:diplomka/register/create_password_page.dart';
import 'package:diplomka/register/login_page.dart';
import 'package:diplomka/register/register_back_button.dart';
import 'package:diplomka/register/register_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _goToCreatePassword() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePasswordPage(
          fullName: name,
          email: email,
          phone: phone,
        ),
      ),
    );
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
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RegisterBackButton(),
                const SizedBox(height: RegisterLayout.spacingAfterBack),
                
                // Illustration
                Image.asset(
                  'assets/Register/Signup/Group 19.png',
                  width: double.infinity,
                  height: RegisterTheme.illustrationHeight,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                
                // Title
                const Text('Sign Up', style: RegisterTheme.h2),
                const SizedBox(height: 32),

                // Full Name field
                const Text('Full Name', style: RegisterTheme.fieldLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  style: RegisterTheme.fieldLabel.copyWith(fontSize: 14),
                  decoration: RegisterTheme.fieldDecoration('Enter your full name'),
                ),
                const SizedBox(height: 20),
                
                // Email field
                const Text('Email Address', style: RegisterTheme.fieldLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: RegisterTheme.fieldLabel.copyWith(fontSize: 14),
                  decoration: RegisterTheme.fieldDecoration('Enter your email'),
                ),
                const SizedBox(height: 20),
                
                // Phone field
                const Text('Phone Number', style: RegisterTheme.fieldLabel),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: RegisterTheme.fieldLabel.copyWith(fontSize: 14),
                  decoration: RegisterTheme.fieldDecoration('Enter your phone number'),
                ),
                const SizedBox(height: 24),
                
                // Terms and conditions
                RichText(
                  text: TextSpan(
                    style: RegisterTheme.captionMuted.copyWith(fontSize: 16, height: 1.25),
                    children: const [
                      TextSpan(text: 'By signing up, you\'ve agree to our '),
                      TextSpan(
                        text: 'terms and conditions',
                        style: TextStyle(
                          fontFamily: RegisterTheme.fontFamily,
                          color: RegisterTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy.',
                        style: TextStyle(
                          fontFamily: RegisterTheme.fontFamily,
                          color: RegisterTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Create Password button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToCreatePassword,
                    style: RegisterTheme.primaryButtonStyle,
                    child: const Text('Create Password'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Login link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'Joined us before? ', style: RegisterTheme.footerMuted),
                          TextSpan(text: 'Login', style: RegisterTheme.footerAction),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
