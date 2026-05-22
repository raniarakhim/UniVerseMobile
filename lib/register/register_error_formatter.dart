import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:diplomka/core/services/auth_service.dart';

class RegisterErrorFormatter {
  static String format(Object error) {
    if (error is AuthException) return error.message;
    if (error is FirebaseAuthException) return _auth(error);
    if (error is FirebaseException) return _firestore(error);

    final text = error.toString().trim();
    if (text.isEmpty || text == 'Error' || text == 'Exception') {
      return 'Ошибка Firebase. Включите Email/Password в Authentication и создайте Firestore (diplomkauniverse).';
    }
    return text;
  }

  static String _auth(FirebaseAuthException e) {
    final msg = e.message?.trim() ?? '';
    if (msg.isNotEmpty && msg != 'Error') return msg;

    switch (e.code) {
      case 'configuration-not-found':
        return 'Включите Email/Password: Console → diplomkauniverse → Authentication → Sign-in method → Enable';
      case 'operation-not-allowed':
        return 'Включите Email/Password: Firebase → Authentication → Sign-in method';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'Неверный API key. Перезапустите flutterfire configure для diplomkauniverse';
      case 'network-request-failed':
        return 'Нет сети или заблокирован Firebase. Проверьте интернет';
      default:
        return 'Ошибка входа (${e.code})';
    }
  }

  static String _firestore(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore: нет доступа. Опубликуйте Rules из firestore.rules';
      case 'unavailable':
        return 'Создайте Firestore Database в Firebase Console';
      default:
        return 'Firestore (${e.code}): ${e.message ?? ''}';
    }
  }
}
