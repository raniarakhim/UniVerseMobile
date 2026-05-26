import 'package:flutter/material.dart';

/// Кольцевой ползунок: обводка цвета трека + белый центр.
class DonutRangeSliderThumbShape extends RangeSliderThumbShape {
  const DonutRangeSliderThumbShape({
    this.outerRadius = 10,
    this.innerRadius = 5,
    required this.ringColor,
    this.centerColor = Colors.white,
  });

  final double outerRadius;
  final double innerRadius;
  final Color ringColor;
  final Color centerColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(outerRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, outerRadius, Paint()..color = ringColor);
    canvas.drawCircle(center, innerRadius, Paint()..color = centerColor);
  }
}
