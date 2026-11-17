import 'package:flutter/material.dart';

import 'analisis_logo.dart';
import 'analisis_theme.dart';

class AnalisisAvatar extends StatelessWidget {
  final bool coach;
  const AnalisisAvatar({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    if (coach)
      return const AnalisisLogo(size: 40, radius: 10); // logo del coach
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF151824),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AnalisisTheme.lineStrong),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 20,
        color: AnalisisTheme.textSecondary,
      ),
    );
  }
}
