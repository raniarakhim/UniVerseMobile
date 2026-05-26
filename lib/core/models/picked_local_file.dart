/// Локально выбранный файл перед загрузкой в Storage.
class PickedLocalFile {
  const PickedLocalFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    this.extension,
    this.bytes,
  });

  final String name;
  final String path;
  final int sizeBytes;
  final String? extension;

  /// Для web, когда [path] недоступен.
  final List<int>? bytes;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
