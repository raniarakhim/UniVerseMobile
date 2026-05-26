import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';
import 'package:diplomka/housing/models/housing_photos.dart';

/// Loads remote or asset images with per-item fallback (not the current screen item).
class NetworkCoverImage extends StatelessWidget {
  const NetworkCoverImage({
    super.key,
    required this.url,
    this.fallbackPath,
    this.fit = BoxFit.cover,
  });

  final String url;
  final String? fallbackPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: fit,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) {
          if (fallbackPath != null &&
              fallbackPath!.isNotEmpty &&
              fallbackPath != url &&
              fallbackPath!.startsWith('http')) {
            return Image.network(
              fallbackPath!,
              fit: fit,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => _placeholder(),
            );
          }
          return _placeholder();
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: HomeTheme.accentSurface,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallbackNetwork(url),
      );
    }
    return _fallbackNetwork(url);
  }

  Widget _fallbackNetwork(String failedUrl) {
    final fallback = HousingPhotos.defaultCover;
    if (failedUrl != fallback) {
      return Image.network(
        fallback,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: HomeTheme.accentSurface,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 36, color: HomeTheme.placeholder),
    );
  }
}
