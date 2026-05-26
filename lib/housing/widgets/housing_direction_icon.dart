import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diplomka/core/home_theme.dart';

/// Иконка направления на карте Housing (Figma).
class HousingDirectionIcon extends StatelessWidget {
  const HousingDirectionIcon({super.key, this.size = 26});

  final double size;

  static const _assetPath = 'assets/Housing/direction_icon.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => Icon(Icons.near_me, size: size, color: HomeTheme.accent),
      errorBuilder: (_, __, ___) => Icon(Icons.near_me, size: size, color: HomeTheme.accent),
    );
  }
}
