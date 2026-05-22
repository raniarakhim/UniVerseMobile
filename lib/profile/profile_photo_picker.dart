import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:diplomka/core/services/profile_photo_service.dart';

/// Выбор фото профиля (как загрузка CV: галерея или проводник).
class ProfilePhotoPicker {
  ProfilePhotoPicker._();

  static final _imagePicker = ImagePicker();

  static Future<String?> pickAndSave(
    BuildContext context,
    String uid, {
    bool hasPhoto = false,
  }) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Choose from files'),
              onTap: () => Navigator.pop(ctx, 'files'),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !context.mounted) return null;

    if (choice == 'remove') {
      await ProfilePhotoService.instance.clear(uid);
      return null;
    }

    if (choice == 'gallery') {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return null;
      return ProfilePhotoService.instance.saveFromPath(uid, image.path);
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    return ProfilePhotoService.instance.saveFromPath(uid, path);
  }
}
