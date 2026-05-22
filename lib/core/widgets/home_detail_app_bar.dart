import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

class HomeDetailAppBar extends StatelessWidget {
  const HomeDetailAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HomeTheme.horizontalPadding),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            _BackButton(
              onPressed: onBack ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 26 / 20,
                  color: HomeTheme.primary,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: trailing ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HomeTheme.surfaceBackground,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_back_ios_new, size: 20, color: HomeTheme.primary),
        ),
      ),
    );
  }
}
