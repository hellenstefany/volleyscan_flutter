import 'package:flutter/material.dart';

import 'estadisticas_donut_painter.dart';
import 'estadisticas_theme.dart';

/// Dona de asistencia promedio.
class EstadisticasDonut extends StatelessWidget {
  final int avgAtt;
  const EstadisticasDonut({super.key, required this.avgAtt});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(160, 160),
                painter: EstadisticasDonutPainter(avgAtt / 100),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$avgAtt%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: EstadisticasTheme.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Promedio',
                    style: TextStyle(
                      fontSize: 11,
                      color: EstadisticasTheme.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
