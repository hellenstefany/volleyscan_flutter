import 'package:flutter/material.dart';

import 'analisis_theme.dart';

/// Logo de la app (assets/images/Logo.VS.jpg).
/// Si la imagen no se encuentra, muestra el icono de antes.
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
            color: AnalisisTheme.accent.withOpacity(0.35),
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
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(gradient: AnalisisTheme.aiGradient),
            child: Icon(
              Icons.sports_volleyball,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
