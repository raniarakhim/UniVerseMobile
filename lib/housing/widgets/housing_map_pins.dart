import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

/// Зелёная метка «сохранено» (Figma).
class HousingBookmarkMapPin extends StatelessWidget {
  const HousingBookmarkMapPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.45),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Icon(Icons.bookmark, size: 16, color: Color(0xFF0F172A)),
    );
  }
}

/// Основная метка с лучом направления и буквой (Figma).
class HousingPrimaryMapPin extends StatelessWidget {
  const HousingPrimaryMapPin({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 72,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(36, 44),
              painter: _MapBeamPainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFF3B82F6), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                label.length > 2 ? label.substring(0, 2) : label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF60A5FA).withValues(alpha: 0.55),
          const Color(0xFF3B82F6).withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Обычная метка объявления на карте.
class HousingListingMapPin extends StatelessWidget {
  const HousingListingMapPin({super.key, this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: selected ? 20 : 14,
      height: selected ? 20 : 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : HomeTheme.accentLight,
        border: Border.all(
          color: selected ? HomeTheme.accent : Colors.white,
          width: selected ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: HomeTheme.accent.withValues(alpha: 0.35),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}
