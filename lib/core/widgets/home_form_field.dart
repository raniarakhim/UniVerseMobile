import 'package:flutter/material.dart';
import 'package:diplomka/core/home_theme.dart';

class HomeFormField extends StatelessWidget {
  const HomeFormField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int maxLines;
  final bool readOnly;

  static const Color _labelColor = Color(0xFF0F0E2A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 20 / 16,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16, height: 20 / 16, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: HomeTheme.placeholder),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentSurface),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: HomeTheme.accentLight),
            ),
          ),
        ),
      ],
    );
  }
}
