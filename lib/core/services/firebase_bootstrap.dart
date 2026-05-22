import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:diplomka/firebase/firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;
  static String? lastError;

  static bool get isReady => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    lastError = null;
    if (!DefaultFirebaseOptions.isConfigured) {
      lastError = 'Конфиг Firebase не заполнен';
      debugPrint('[Firebase] $lastError');
      return;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('[Firebase] Initialized: ${DefaultFirebaseOptions.android.projectId}');
    } catch (e, st) {
      lastError = e.toString();
      debugPrint('[Firebase] Init failed: $e\n$st');
    }
  }
}
