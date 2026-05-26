import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/core/services/local_registrations_store.dart';

class ApplicationException implements Exception {
  ApplicationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Сохранение заявок на события и вакансии в Firestore.
class ApplicationsService {
  ApplicationsService._();
  static final ApplicationsService instance = ApplicationsService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _ensureReady() async {
    if (!FirebaseBootstrap.isReady) {
      await FirebaseBootstrap.initialize();
    }
    if (!FirebaseBootstrap.isReady) {
      throw ApplicationException('Firebase недоступен. Проверьте подключение.');
    }
    if (_uid == null) {
      throw ApplicationException('Войдите в аккаунт, чтобы отправить заявку');
    }
  }

  Future<String> submitEventRegistration({
    required String eventId,
    required String eventTitle,
    required Map<String, dynamic> formData,
  }) async {
    await _ensureReady();
    final uid = _uid!;
    final payload = <String, dynamic>{
      'userId': uid,
      'eventId': eventId,
      'eventTitle': eventTitle,
      ...formData,
    };

    if (FirebaseBootstrap.isReady) {
      try {
        final ref = await _db.collection('event_registrations').add({
          ...payload,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return ref.id;
      } catch (e, stack) {
        debugPrint('[Applications] event registration firestore failed: $e\n$stack');
      }
    }

    try {
      return await LocalRegistrationsStore.instance.save(uid, payload);
    } catch (e, stack) {
      debugPrint('[Applications] event registration local failed: $e\n$stack');
      throw ApplicationException('Не удалось сохранить регистрацию. Проверьте подключение.');
    }
  }

  Future<String> submitJobApplication({
    required String jobId,
    required String jobTitle,
    required String company,
    required Map<String, dynamic> formData,
  }) async {
    await _ensureReady();
    try {
      final ref = await _db.collection('job_applications').add({
        'userId': _uid,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'company': company,
        ...formData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e, stack) {
      debugPrint('[Applications] job application failed: $e\n$stack');
      throw ApplicationException('Не удалось отправить заявку: $e');
    }
  }
}
