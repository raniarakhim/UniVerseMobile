import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/core/services/user_profile_service.dart';

/// Сохранённый вход: Firebase Auth (локально) + флаг в SharedPreferences.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  static const _prefsLoggedInKey = 'session_is_logged_in';

  Future<void> configureAuthPersistence() async {
    if (!FirebaseBootstrap.isReady) return;
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  }

  Future<bool> tryRestoreSession() async {
    await FirebaseBootstrap.initialize();
    await configureAuthPersistence();

    if (!FirebaseBootstrap.isReady) {
      return _readLoggedInFlag();
    }

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      await _setLoggedInFlag(false);
      return false;
    }

    await UserProfileService.instance.load();
    await _setLoggedInFlag(true);
    return true;
  }

  Future<void> markLoggedIn() async {
    await _setLoggedInFlag(true);
  }

  Future<void> clearSession() async {
    await _setLoggedInFlag(false);
    UserProfileService.instance.clear();
  }

  Future<void> _setLoggedInFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsLoggedInKey, value);
  }

  Future<bool> _readLoggedInFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsLoggedInKey) ?? false;
  }
}
