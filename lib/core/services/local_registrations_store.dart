import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное сохранение регистраций на события, если Firestore недоступен.
class LocalRegistrationsStore {
  LocalRegistrationsStore._();
  static final LocalRegistrationsStore instance = LocalRegistrationsStore._();

  String _key(String uid) => 'event_registrations_local_$uid';

  Future<String> save(String uid, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key(uid)) ?? <String>[];
    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final entry = <String, dynamic>{
      ...data,
      'id': id,
      'userId': uid,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    list.add(jsonEncode(entry));
    await prefs.setStringList(_key(uid), list);
    debugPrint('[LocalRegistrations] saved $id');
    return id;
  }
}
