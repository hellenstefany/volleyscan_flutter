import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

class EstadisticasCard extends StatelessWidget {
  final String title;
  final Widget child;
  const EstadisticasCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EstadisticasTheme.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              EstadisticasTheme.accent.withOpacity(0.04),
              EstadisticasTheme.panel2,
            ),
            EstadisticasTheme.panel2,
          ],
          stops: const [0, 0.6],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: EstadisticasTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
