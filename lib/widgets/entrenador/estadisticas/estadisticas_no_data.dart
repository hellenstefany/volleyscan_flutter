import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

class EstadisticasNoData extends StatelessWidget {
  final String icon;
  const EstadisticasNoData({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            const Text(
              'Sin datos',
              style: TextStyle(fontSize: 13, color: EstadisticasTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
