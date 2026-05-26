import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:diplomka/core/models/app_user.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/core/services/session_service.dart';
import 'package:diplomka/core/services/user_profile_service.dart';
import 'package:diplomka/core/utils/phone_utils.dart';

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

/// Результат запроса сброса пароля (письмо на email Firebase).
class PasswordResetResult {
  const PasswordResetResult({
    required this.email,
    required this.viaPhoneLookup,
  });

  final String email;
  final bool viaPhoneLookup;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      await SessionService.instance.markLoggedIn();
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

  Future<SignUpResult> signInWithGoogle() async {
    await _ensureFirebase();

    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        // Web: Firebase popup (не требует clientId в index.html).
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException('Вход через Google отменён');
        }
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
        return _completeGoogleSignIn(
          userCredential,
          fallbackEmail: googleUser.email,
          fallbackName: googleUser.displayName,
        );
      }
      return _completeGoogleSignIn(userCredential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<SignUpResult> _completeGoogleSignIn(
    UserCredential userCredential, {
    String? fallbackEmail,
    String? fallbackName,
  }) async {
    final fbUser = userCredential.user!;
    final uid = fbUser.uid;
    final email = (fbUser.email ?? fallbackEmail ?? '').trim();
    final name = (fbUser.displayName ?? fallbackName ?? email.split('@').first).trim();

    if (email.isEmpty) {
      throw AuthException('Google не вернул email. Разрешите доступ к email в аккаунте Google.');
    }

    final doc = await _db.collection('users').doc(uid).get();
    String? firestoreWarning;
    final AppUser profile;

    if (doc.exists && doc.data() != null) {
      profile = AppUser.fromFirestore(uid, doc.data()!);
    } else {
      profile = AppUser(
        uid: uid,
        fullName: name.isNotEmpty ? name : 'User',
        email: email,
        phone: '',
        university: 'SKSU',
      );
      try {
        await _db.collection('users').doc(uid).set(profile.toFirestore(includeCreatedAt: true));
      } on FirebaseException catch (e) {
        debugPrint('[Auth] Google Firestore save failed: ${e.code}');
        firestoreWarning = _mapFirestoreError(e);
      }
      try {
        await fbUser.updateDisplayName(profile.fullName);
      } catch (_) {}
    }

    UserProfileService.instance.cacheUser(profile);
    await SessionService.instance.markLoggedIn();
    return SignUpResult(user: profile, firestoreWarning: firestoreWarning);
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
      await SessionService.instance.markLoggedIn();
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
    await SessionService.instance.clearSession();
  }

  Future<PasswordResetResult> sendPasswordReset(String emailOrPhone) async {
    await _ensureFirebase();
    final email = await _resolveEmailForPasswordReset(emailOrPhone);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return PasswordResetResult(
        email: email,
        viaPhoneLookup: !emailOrPhone.trim().contains('@'),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<String> _resolveEmailForPasswordReset(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw AuthException('Введите email или номер телефона');
    }
    if (trimmed.contains('@')) {
      if (!trimmed.contains('.') || trimmed.length < 5) {
        throw AuthException('Введите корректный email');
      }
      return trimmed.toLowerCase();
    }

    final normalized = normalizePhone(trimmed);
    if (normalized.length < 10) {
      throw AuthException('Введите корректный номер телефона');
    }

    final email = await _findEmailByPhone(normalized);
    if (email == null || email.isEmpty) {
      throw AuthException(
        'Аккаунт с этим номером не найден. Укажите email, указанный при регистрации.',
      );
    }
    return email.toLowerCase();
  }

  Future<String?> _findEmailByPhone(String normalized) async {
    var snap = await _db
        .collection('users')
        .where('phoneNormalized', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return snap.docs.first.data()['email'] as String?;
    }

    snap = await _db.collection('users').limit(200).get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final phone = data['phone'] as String? ?? '';
      if (normalizePhone(phone) == normalized) {
        return data['email'] as String?;
      }
    }
    return null;
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _ensureFirebase();
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw AuthException('Войдите в аккаунт');
    }
    if (newPassword.length < 6) {
      throw AuthException('Новый пароль должен быть не короче 6 символов');
    }
    if (currentPassword == newPassword) {
      throw AuthException('Новый пароль должен отличаться от текущего');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e));
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
    await SessionService.instance.clearSession();
  }

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
        return 'В Firebase включите провайдер входа: Authentication → Sign-in method (Email/Password или Google)';
      case 'account-exists-with-different-credential':
        return 'Этот email уже зарегистрирован другим способом. Войдите через email/пароль.';
      case 'popup-closed-by-user':
        return 'Вход через Google отменён';
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
