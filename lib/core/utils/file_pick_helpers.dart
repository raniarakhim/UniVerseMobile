import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diplomka/core/models/picked_local_file.dart';

/// Общие диалоги выбора файлов (фото, PDF).
class FilePickHelpers {
  FilePickHelpers._();

  static final _imagePicker = ImagePicker();

  static Future<String?> _showSourceSheet(
    BuildContext context, {
    required bool allowGallery,
    required bool allowFiles,
    String galleryLabel = 'Choose from gallery',
    String filesLabel = 'Choose file',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allowGallery)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(galleryLabel),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
            if (allowFiles)
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text(filesLabel),
                onTap: () => Navigator.pop(ctx, 'files'),
              ),
          ],
        ),
      ),
    );
  }

  static Future<PickedLocalFile?> pickImage(BuildContext context) async {
    final choice = await _showSourceSheet(
      context,
      allowGallery: true,
      allowFiles: true,
      galleryLabel: 'Choose from gallery',
      filesLabel: 'Choose image file',
    );
    if (choice == null || !context.mounted) return null;

    if (choice == 'gallery') {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return null;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return PickedLocalFile(
          name: image.name,
          path: '',
          sizeBytes: bytes.length,
          extension: _ext(image.name),
          bytes: bytes,
        );
      }
      final file = File(image.path);
      final size = await file.length();
      return PickedLocalFile(
        name: image.name,
        path: image.path,
        sizeBytes: size,
        extension: _ext(image.name),
      );
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    return _fromPlatformResult(result);
  }

  static Future<PickedLocalFile?> pickPdf(
    BuildContext context, {
    int maxBytes = 2 * 1024 * 1024,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    final picked = _fromPlatformResult(result);
    if (picked == null) return null;
    if (!picked.name.toLowerCase().endsWith('.pdf')) {
      return null;
    }
    if (picked.sizeBytes > maxBytes) {
      throw FilePickSizeException(maxBytes);
    }
    return picked;
  }

  static PickedLocalFile? _fromPlatformResult(FilePickerResult? result) {
    if (result == null || result.files.isEmpty) return null;
    final f = result.files.single;
    final path = f.path ?? '';
    final bytes = f.bytes;
    final size = bytes != null ? bytes.length : f.size;
    if (path.isEmpty && bytes == null) return null;
    return PickedLocalFile(
      name: f.name,
      path: path,
      sizeBytes: size,
      extension: _ext(f.name),
      bytes: bytes,
    );
  }

  static String? _ext(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0) return null;
    return name.substring(i + 1).toLowerCase();
  }
}

class FilePickSizeException implements Exception {
  FilePickSizeException(this.maxBytes);
  final int maxBytes;

  String get message {
    final mb = (maxBytes / (1024 * 1024)).toStringAsFixed(1);
    return 'Файл слишком большой (макс. $mb MB)';
  }
}
