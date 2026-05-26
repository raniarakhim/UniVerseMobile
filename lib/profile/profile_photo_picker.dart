import 'package:flutter/material.dart';
import 'package:diplomka/core/utils/file_pick_helpers.dart';
import 'package:diplomka/core/services/profile_photo_service.dart';

/// Выбор и загрузка фото профиля в Firebase Storage.
class ProfilePhotoPicker {
  ProfilePhotoPicker._();

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
              onTap: () => Navigator.pop(ctx, 'pick'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_outlined),
              title: const Text('Choose from files'),
              onTap: () => Navigator.pop(ctx, 'pick'),
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

    if (!context.mounted || choice == null) return null;

    if (choice == 'remove') {
      await ProfilePhotoService.instance.clear(uid);
      return null;
    }

    final picked = await FilePickHelpers.pickImage(context);
    if (picked == null || !context.mounted) return null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading photo…'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      return await ProfilePhotoService.instance.uploadFromPicked(uid, picked);
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
