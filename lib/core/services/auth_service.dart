import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/core/services/user_profile_service.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SignUpResult {
  const SignUpResult({
    required this.user,
    this.firestoreWarning,
  });

  final AppUser user;
  final String? firestoreWarning;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _ensureFirebase() async {
    if (!FirebaseBootstrap.isReady) {
      await FirebaseBootstrap.initialize();
    }
    if (!FirebaseBootstrap.isReady) {
      final detail = FirebaseBootstrap.lastError;
      throw AuthException(
        detail != null
            ? 'Firebase не запустился: $detail'
            : 'Firebase не настроен. Выполните flutterfire configure для diplomkauniverse.',
      );
    }
  }

  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _ensureFirebase();

    final trimmedEmail = email.trim();
    if (fullName.trim().isEmpty) {
      throw AuthException('Введите полное имя');
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw AuthException('Введите корректный email');
    }
    if (password.length < 6) {
      throw AuthException('Пароль должен быть не короче 6 символов');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );

      final uid = credential.user!.uid;
      final profile = AppUser(
        uid: uid,
        fullName: fullName.trim(),
        email: trimmedEmail,
        phone: phone.trim(),
        university: 'SKSU',
      );

      String? firestoreWarning;
      try {
        await _db.collection('users').doc(uid).set(profile.toFirestore(includeCreatedAt: true));
      } on FirebaseException catch (e) {
        debugPrint('[Auth] Firestore save failed: ${e.code} ${e.message}');
        firestoreWarning = _mapFirestoreError(e);
      }

      try {
        await credential.user!.updateDisplayName(fullName.trim());
      } catch (_) {}

      UserProfileService.instance.cacheUser(profile);
      return SignUpResult(user: profile, firestoreWarning: firestoreWarning);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    } on FirebaseException catch (e) {
      throw AuthException(_mapFirestoreError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Не удалось создать аккаунт: $e');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _ensureFirebase();

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw AuthException('Введите корректный email');
    }
    if (password.isEmpty) {
      throw AuthException('Введите пароль');
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      await UserProfileService.instance.load();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> deleteAccount() async {
    await _ensureFirebase();
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('Пользователь не авторизован');
    }
    final uid = user.uid;
    try {
      await _db.collection('users').doc(uid).delete();
    } on FirebaseException catch (e) {
      debugPrint('[Auth] Firestore delete failed: ${e.code}');
    }
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    await _ensureFirebase();
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw AuthException('Введите корректный email');
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'configuration-not-found':
        return 'Включите Email/Password: Firebase Console → diplomkauniverse → Authentication → Sign-in method → Email/Password → Enable → Save';
      case 'operation-not-allowed':
        return 'В Firebase включите вход по Email/Password: Authentication → Sign-in method';
      case 'network-request-failed':
        return 'Нет сети. Проверьте интернет и повторите';
      case 'requires-recent-login':
        return 'Войдите снова и повторите удаление аккаунта';
      default:
        final msg = e.message?.trim() ?? '';
        if (msg.isNotEmpty && msg != 'Error') return msg;
        return 'Ошибка авторизации (${e.code})';
    }
  }

  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Нет доступа к Firestore. Создайте базу данных и опубликуйте Rules (см. firestore.rules)';
      case 'unavailable':
        return 'Firestore не создан. Firebase Console → Firestore → Create database';
      case 'not-found':
        return 'База Firestore не найдена. Создайте её в Firebase Console';
      default:
        return 'Ошибка базы данных (${e.code}): ${e.message ?? ''}';
    }
  }
}
