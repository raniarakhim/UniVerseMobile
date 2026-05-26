import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diplomka/core/models/picked_local_file.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';
import 'package:diplomka/core/services/storage_upload_service.dart';

/// Резюме (CV) — локальный файл на устройстве.
class UserResumeService extends ChangeNotifier {
  UserResumeService._();
  static final UserResumeService instance = UserResumeService._();

  static const maxBytes = 2 * 1024 * 1024;

  String _nameKey(String uid) => 'resume_file_name_$uid';
  String _pathKey(String uid) => 'resume_local_path_$uid';

  Future<({String? fileName, String? localPath})> infoForUser(String? uid) async {
    if (uid == null || uid.isEmpty) return (fileName: null, localPath: null);

    final prefs = await SharedPreferences.getInstance();
    var name = prefs.getString(_nameKey(uid));
    var path = prefs.getString(_pathKey(uid));

    if (FirebaseBootstrap.isReady && (name == null || path == null)) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final data = doc.data();
        name ??= data?['resumeFileName'] as String?;
        path ??= data?['resumeLocalPath'] as String?;
        if (name != null) await prefs.setString(_nameKey(uid), name);
        if (path != null) await prefs.setString(_pathKey(uid), path);
      } catch (e) {
        debugPrint('[Resume] load failed: $e');
      }
    }
    return (fileName: name, localPath: path);
  }

  Future<void> uploadResume(String uid, PickedLocalFile file) async {
    final localPath = await StorageUploadService.instance.uploadFile(
      storagePath: 'users/$uid/resume.pdf',
      file: file,
      contentType: 'application/pdf',
      maxBytes: maxBytes,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pathKey(uid), localPath);
    await prefs.setString(_nameKey(uid), file.name);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'resumeLocalPath': localPath,
          'resumeFileName': file.name,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[Resume] firestore save failed: $e');
    }
    notifyListeners();
  }

  Future<void> clearResume(String uid) async {
    await StorageUploadService.instance.deleteIfExists('users/$uid/resume.pdf');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pathKey(uid));
    await prefs.remove(_nameKey(uid));
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'resumeLocalPath': FieldValue.delete(),
          'resumeFileName': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('[Resume] firestore clear failed: $e');
    }
    notifyListeners();
  }
}
