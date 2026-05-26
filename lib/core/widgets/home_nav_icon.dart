import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:diplomka/core/home_theme.dart';

/// Иконки нижней навигации Home (SVG из Figma).
class HomeNavIcon extends StatelessWidget {
  const HomeNavIcon({
    super.key,
    required this.index,
    this.size = 25,
  });

  final int index;
  final double size;

  static const _assetPaths = [
    'assets/Home/nav/Home.svg',
    'assets/Home/nav/Jobs.svg',
    'assets/Home/nav/Housing.svg',
    'assets/Home/nav/Events.svg',
    'assets/Home/nav/Profile.svg',
  ];

  static const _fallbackIcons = [
    Icons.home_outlined,
    Icons.work_outline,
    Icons.apartment_outlined,
    Icons.calendar_month_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    assert(index >= 0 && index < _assetPaths.length);
    return SvgPicture.asset(
      _assetPaths[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => Icon(
        _fallbackIcons[index],
        size: size,
        color: HomeTheme.accent,
      ),
    );
  }
}
