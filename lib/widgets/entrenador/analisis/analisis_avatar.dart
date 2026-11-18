import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import 'analisis_logo.dart';

class AnalisisAvatar extends StatelessWidget {
  final bool coach;

  const AnalisisAvatar({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    if (coach) return const AnalisisLogo(size: 40, radius: 10);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.border2),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 20,
        color: DashColors.textSecondary,
      ),
    );
  }
}
