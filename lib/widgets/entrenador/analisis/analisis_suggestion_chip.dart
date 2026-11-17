import 'package:flutter/material.dart';

import 'analisis_theme.dart';

class AnalisisSuggestionChip extends StatelessWidget {
  final String glifo;
  final String texto;
  final VoidCallback onTap;
  const AnalisisSuggestionChip({
    super.key,
    required this.glifo,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      hoverColor: AnalisisTheme.accent.withOpacity(0.1),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AnalisisTheme.lineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              glifo,
              style: AnalisisTheme.mono.copyWith(
                fontSize: 11.2,
                fontWeight: FontWeight.w700,
                color: AnalisisTheme.accent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 12.8,
                color: AnalisisTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
