import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:diplomka/core/models/picked_local_file.dart';
import 'package:diplomka/core/services/firebase_bootstrap.dart';

class StorageUploadException implements Exception {
  StorageUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Локальное «хранилище» файлов (без Firebase Storage) — только на этом устройстве.
class StorageUploadService {
  StorageUploadService._();
  static final StorageUploadService instance = StorageUploadService._();

  Future<void> _ensureAuth() async {
    if (!FirebaseBootstrap.isReady) {
      await FirebaseBootstrap.initialize();
    }
    if (FirebaseAuth.instance.currentUser == null) {
      throw StorageUploadException('Войдите в аккаунт для загрузки файлов');
    }
  }

  /// Сохраняет файл и возвращает **локальный путь** на диске.
  Future<String> uploadFile({
    required String storagePath,
    required PickedLocalFile file,
    required String contentType,
    int? maxBytes,
  }) async {
    await _ensureAuth();

    if (maxBytes != null && file.sizeBytes > maxBytes) {
      final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
      throw StorageUploadException('Файл слишком большой (макс. $mb MB)');
    }

    if (kIsWeb) {
      throw StorageUploadException(
        'Локальные файлы на web недоступны. Запустите приложение на Android или Windows.',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final safePath = storagePath.replaceAll('..', '').replaceAll('\\', '/');
    final dest = File('${dir.path}/universe_files/$safePath');
    await dest.parent.create(recursive: true);

    if (file.bytes != null) {
      await dest.writeAsBytes(file.bytes!);
    } else if (file.path.isNotEmpty) {
      final src = File(file.path);
      if (!await src.exists()) {
        throw StorageUploadException('Файл не найден на устройстве');
      }
      await src.copy(dest.path);
    } else {
      throw StorageUploadException('Не удалось прочитать файл');
    }

    return dest.path;
  }

  Future<void> deleteIfExists(String storagePath) async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safePath = storagePath.replaceAll('..', '').replaceAll('\\', '/');
      final file = File('${dir.path}/universe_files/$safePath');
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('[LocalStorage] delete failed: $e');
    }
  }
}
