import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальное фото профиля (галерея / файлы), привязано к uid пользователя.
class ProfilePhotoService extends ChangeNotifier {
  ProfilePhotoService._();

  static final ProfilePhotoService instance = ProfilePhotoService._();

  String? _cachedUid;
  String? _cachedPath;

  String _prefsKey(String uid) => 'profile_photo_path_$uid';

  Future<String?> pathForUser(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    if (_cachedUid == uid && _cachedPath != null) {
      if (kIsWeb || File(_cachedPath!).existsSync()) return _cachedPath;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey(uid));
    if (stored == null || stored.isEmpty) return null;
    if (!kIsWeb && !File(stored).existsSync()) {
      await prefs.remove(_prefsKey(uid));
      return null;
    }

    _cachedUid = uid;
    _cachedPath = stored;
    return stored;
  }

  Future<String?> saveFromPath(String uid, String sourcePath) async {
    if (kIsWeb) return null;

    final source = File(sourcePath);
    if (!await source.exists()) return null;

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${dir.path}/profile_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final dest = File('${photosDir.path}/$uid.jpg');
    await source.copy(dest.path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey(uid), dest.path);

    _cachedUid = uid;
    _cachedPath = dest.path;
    notifyListeners();
    return dest.path;
  }

  Future<void> clear(String uid) async {
    if (!kIsWeb) {
      final path = await pathForUser(uid);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey(uid));
    if (_cachedUid == uid) {
      _cachedUid = null;
      _cachedPath = null;
    }
    notifyListeners();
  }
}
