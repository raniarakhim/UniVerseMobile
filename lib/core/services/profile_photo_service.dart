import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diplomka/core/models/picked_local_file.dart';
import 'package:diplomka/core/services/storage_upload_service.dart';

/// Фото профиля: локальные файлы + метаданные в Firestore (без Firebase Storage).
class ProfilePhotoService extends ChangeNotifier {
  ProfilePhotoService._();

  static final ProfilePhotoService instance = ProfilePhotoService._();

  String? _cachedUid;
  String? _cachedPath;

  String _pathKey(String uid) => 'profile_photo_path_$uid';

  Future<String?> pathForUser(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    if (_cachedUid == uid && _cachedPath != null) {
      if (kIsWeb || File(_cachedPath!).existsSync()) return _cachedPath;
    }

    final prefs = await SharedPreferences.getInstance();
    var stored = prefs.getString(_pathKey(uid));
    if (stored == null || stored.isEmpty) {
      stored = await _pathFromFirestore(uid);
      if (stored != null) {
        await prefs.setString(_pathKey(uid), stored);
      }
    }

    if (stored == null || stored.isEmpty) return null;
    if (!kIsWeb && !File(stored).existsSync()) {
      await prefs.remove(_pathKey(uid));
      return null;
    }

    _cachedUid = uid;
    _cachedPath = stored;
    return stored;
  }

  Future<String?> urlForUser(String? uid) async {
    final path = await pathForUser(uid);
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : null;
  }

  Future<String?> _pathFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['photoLocalPath'] as String?;
    } catch (e) {
      debugPrint('[ProfilePhoto] firestore read failed: $e');
      return null;
    }
  }

  Future<String?> uploadFromPicked(String uid, PickedLocalFile picked) async {
    if (kIsWeb) return null;
    if (picked.path.isEmpty && picked.bytes == null) return null;

    final localPath = await StorageUploadService.instance.uploadFile(
      storagePath: 'users/$uid/profile.jpg',
      file: picked,
      contentType: 'image/jpeg',
      maxBytes: 5 * 1024 * 1024,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey(uid), localPath);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'photoLocalPath': localPath},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[ProfilePhoto] firestore save failed: $e');
    }

    _cachedUid = uid;
    _cachedPath = localPath;
    notifyListeners();
    return localPath;
  }

  Future<void> clear(String uid) async {
    await StorageUploadService.instance.deleteIfExists('users/$uid/profile.jpg');

    if (!kIsWeb) {
      final path = await pathForUser(uid);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pathKey(uid));

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'photoLocalPath': FieldValue.delete()},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[ProfilePhoto] firestore clear failed: $e');
    }

    if (_cachedUid == uid) {
      _cachedUid = null;
      _cachedPath = null;
    }
    notifyListeners();
  }

  Future<String?> saveFromPath(String uid, String sourcePath) async {
    if (kIsWeb) return null;
    final file = File(sourcePath);
    if (!await file.exists()) return null;
    final size = await file.length();
    return uploadFromPicked(
      uid,
      PickedLocalFile(
        name: 'profile.jpg',
        path: sourcePath,
        sizeBytes: size,
        extension: 'jpg',
      ),
    );
  }
}
