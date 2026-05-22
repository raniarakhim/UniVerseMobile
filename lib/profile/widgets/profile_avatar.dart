import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    this.photoPath,
    this.size = 65,
    this.backgroundColor = HomeTheme.infoBox,
    this.initialsColor = Colors.white,
    this.initialsFontSize = 24,
    this.onTap,
    this.showEditBadge = false,
  });

  final String initials;
  final String? photoPath;
  final double size;
  final Color backgroundColor;
  final Color initialsColor;
  final double initialsFontSize;
  final VoidCallback? onTap;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        image: _imageDecoration(),
      ),
      alignment: Alignment.center,
      child: _imageDecoration() == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: initialsFontSize,
                fontWeight: FontWeight.w700,
                color: initialsColor,
              ),
            )
          : null,
    );

    if (showEditBadge) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: HomeTheme.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }

  DecorationImage? _imageDecoration() {
    if (photoPath == null || photoPath!.isEmpty) return null;
    if (kIsWeb) return null;
    if (!File(photoPath!).existsSync()) return null;
    return DecorationImage(
      image: FileImage(File(photoPath!)),
      fit: BoxFit.cover,
    );
  }
}
