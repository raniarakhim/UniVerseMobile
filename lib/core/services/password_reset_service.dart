import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:diplomka/core/services/auth_service.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';

class EmailOtpRequestResult {
  const EmailOtpRequestResult({
    required this.sessionId,
    required this.maskedDestination,
    this.devMode = false,
  });

  final String sessionId;
  final String maskedDestination;
  final bool devMode;
}

class PasswordResetService {
  PasswordResetService._();
  static final PasswordResetService instance = PasswordResetService._();

  String? _verificationId;
  int? _resendToken;
  ConfirmationResult? _webConfirmation;

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<void> _ensureFirebase() async {
    if (!FirebaseBootstrap.isReady) {
      await FirebaseBootstrap.initialize();
    }
    if (!FirebaseBootstrap.isReady) {
      throw AuthException('Firebase не настроен');
    }
  }

  bool isEmailInput(String input) => input.trim().contains('@');

  Future<EmailOtpRequestResult> requestEmailOtp(String email) async {
    await _ensureFirebase();
    try {
      final result = await _functions.httpsCallable('requestPasswordResetOtp').call({
        'email': email.trim().toLowerCase(),
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return EmailOtpRequestResult(
        sessionId: data['sessionId'] as String,
        maskedDestination: data['maskedDestination'] as String,
        devMode: data['devMode'] == true,
      );
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_mapFunctionsError(e));
    }
  }

  Future<String> verifyEmailOtp({
    required String sessionId,
    required String code,
  }) async {
    await _ensureFirebase();
    try {
      final result = await _functions.httpsCallable('verifyPasswordResetOtp').call({
        'sessionId': sessionId,
        'code': code,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return data['resetToken'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_mapFunctionsError(e));
    }
  }

  Future<void> completeEmailPasswordReset({
    required String sessionId,
    required String resetToken,
    required String newPassword,
  }) async {
    await _ensureFirebase();
    try {
      await _functions.httpsCallable('completePasswordReset').call({
        'sessionId': sessionId,
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_mapFunctionsError(e));
    }
  }

  Future<void> ensurePhoneRegistered(String normalizedPhone) async {
    await _ensureFirebase();
    try {
      await _functions.httpsCallable('checkPhoneForPasswordReset').call({
        'phone': normalizedPhone,
      });
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_mapFunctionsError(e));
    }
  }

  Future<void> sendPhoneSmsCode(String e164) async {
    await _ensureFirebase();
    _verificationId = null;
    _resendToken = null;
    _webConfirmation = null;

    if (kIsWeb) {
      _webConfirmation = await FirebaseAuth.instance.signInWithPhoneNumber(e164);
      return;
    }

    final completer = Completer<void>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: const Duration(seconds: 120),
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        _verificationId = null;
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(_mapPhoneError(e)));
        }
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        _verificationId = verificationId;
        _resendToken = forceResendingToken;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
    return completer.future;
  }

  Future<void> verifyPhoneSmsAndSignIn({
    required String smsCode,
    required String e164,
  }) async {
    await _ensureFirebase();
    final code = smsCode.trim();
    if (code.length < 6) {
      throw AuthException('Введите 6-значный код из SMS');
    }

    if (kIsWeb) {
      final confirmation = _webConfirmation;
      if (confirmation == null) {
        throw AuthException('Сначала запросите SMS-код');
      }
      await confirmation.confirm(code);
      return;
    }

    final verificationId = _verificationId;
    if (verificationId == null) {
      throw AuthException('Сначала запросите SMS-код');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> completePhonePasswordReset({
    required String normalizedPhone,
    required String newPassword,
  }) async {
    await _ensureFirebase();
    try {
      await _functions.httpsCallable('completePhonePasswordReset').call({
        'normalizedPhone': normalizedPhone,
        'newPassword': newPassword,
      });
    } on FirebaseFunctionsException catch (e) {
      throw AuthException(_mapFunctionsError(e));
    } finally {
      await FirebaseAuth.instance.signOut();
    }
  }

  String _mapFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return e.message ?? 'Пользователь не найден';
      case 'invalid-argument':
        return e.message ?? 'Неверные данные';
      case 'deadline-exceeded':
        return e.message ?? 'Код истёк';
      case 'resource-exhausted':
        return e.message ?? 'Слишком много попыток';
      case 'unavailable':
        return 'Сервер недоступен. Разверните Cloud Functions (см. PASSWORD_RESET_SETUP.md)';
      default:
        return e.message ?? 'Ошибка: ${e.code}';
    }
  }

  String _mapPhoneError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Некорректный номер телефона';
      case 'too-many-requests':
        return 'Слишком много SMS. Попробуйте позже';
      case 'quota-exceeded':
        return 'Лимит SMS исчерпан. Включите Blaze или подождите';
      case 'operation-not-allowed':
        return 'В Firebase включите Phone: Authentication → Sign-in method';
      default:
        return e.message ?? 'Ошибка SMS (${e.code})';
    }
  }
}
