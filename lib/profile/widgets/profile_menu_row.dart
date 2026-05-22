import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0),
              child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    _iconCircle(icon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 16, height: 20 / 16, color: Colors.black),
                      ),
                    ),
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: HomeTheme.accentSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: HomeTheme.profileTitle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Icon(Icons.chevron_right, size: 24, color: HomeTheme.accent),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 0.3, color: HomeTheme.placeholder.withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _iconCircle(IconData iconData) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: HomeTheme.surfaceBackground,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Icon(iconData, size: 24, color: HomeTheme.accent),
    );
  }
}
