import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Logo de la app (`assets/images/Logo.VS.jpg`) con fallback vectorial.
class AnalisisLogo extends StatelessWidget {
  final double size;
  final double radius;

  const AnalisisLogo({super.key, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: DashColors.teal.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'assets/images/Logo.VS.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            decoration: const BoxDecoration(gradient: AppGradients.aiAccent),
            child: Icon(
              Icons.sports_volleyball,
              color: DashColors.textPrimary,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
