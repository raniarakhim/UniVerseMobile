import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/core/models/picked_local_file.dart';

/// Зона загрузки файла (CV, документы).
class AppFileUploadArea extends StatelessWidget {
  const AppFileUploadArea({
    super.key,
    required this.file,
    required this.onTap,
    this.uploading = false,
    this.height = 102,
    this.emptyLabel = 'Upload',
  });

  final PickedLocalFile? file;
  final VoidCallback? onTap;
  final bool uploading;
  final double height;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: uploading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(
              color: hasFile || uploading ? HomeTheme.accentLight : HomeTheme.accentSurface,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (uploading)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  hasFile ? Icons.check_circle_outline : Icons.upload_file,
                  size: 30,
                  color: hasFile ? HomeTheme.accentLight : HomeTheme.primary,
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  uploading
                      ? 'Uploading…'
                      : hasFile
                          ? '${file!.name}\n${file!.sizeLabel}'
                          : emptyLabel,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: hasFile ? 14 : 16,
                    height: 1.25,
                    color: hasFile ? HomeTheme.accentLight : HomeTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
