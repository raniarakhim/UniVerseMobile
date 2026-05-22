import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

class RegisterStepper extends StatelessWidget {
  const RegisterStepper({super.key, required this.currentStep});

  final int currentStep;

  static const _labels = ['Info', 'Preferences', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 44,
            right: 44,
            top: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep > 0
                        ? HomeTheme.primary
                        : HomeTheme.accentSurface,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: currentStep > 1
                        ? const Color(0xFF4C1D95)
                        : HomeTheme.accentSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) => _step(i)),
          ),
        ],
      ),
    );
  }

  Widget _step(int index) {
    final done = index < currentStep;
    final active = index == currentStep;
    final circleColor = done || active
        ? (active ? const Color(0xFF4C1D95) : HomeTheme.primary)
        : HomeTheme.accentSurface;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : HomeTheme.tagMuted,
                  ),
                ),
        ),
        const SizedBox(height: 5),
        Text(
          _labels[index],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active
                ? const Color(0xFF4C1D95)
                : (done ? HomeTheme.primary : HomeTheme.tagMuted),
          ),
        ),
      ],
    );
  }
}