import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

/// Tarjetas resumen (rendimiento, asistencia, activos, sesiones).
class EstadisticasMiniCards extends StatelessWidget {
  final double width;
  final int avgPerf;
  final int avgAtt;
  final int active;

  const EstadisticasMiniCards({
    super.key,
    required this.width,
    required this.avgPerf,
    required this.avgAtt,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final w = width;
    final cards = [
      (
        'Rendimiento promedio',
        '$avgPerf%',
        '+3.2%',
        true,
        EstadisticasTheme.accent,
      ),
      (
        'Asistencia promedio',
        '$avgAtt%',
        '-1.1%',
        false,
        EstadisticasTheme.accent2,
      ),
      (
        'Deportistas activos',
        '$active',
        '$active de 5',
        true,
        EstadisticasTheme.accent5,
      ),
      (
        'Sesiones registradas',
        '24',
        '+4 este mes',
        true,
        EstadisticasTheme.accent4,
      ),
    ];
    final cols = w >= 700 ? 4 : 2;
    const gap = 14.0;
    final itemW = (w - gap * (cols - 1)) / cols;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: cards.map((c) {
        final up = c.$4;
        return Container(
          width: itemW,
          padding: EdgeInsets.all(w < 900 ? 12 : 16),
          decoration: BoxDecoration(
            color: EstadisticasTheme.panel2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: EstadisticasTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.$1,
                style: const TextStyle(
                  fontSize: 11,
                  color: EstadisticasTheme.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.$2,
                style: TextStyle(
                  fontSize: w < 900 ? 24 : 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: c.$5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${up ? '▲' : '▼'} ${c.$3}',
                style: TextStyle(
                  fontSize: 11,
                  color: up
                      ? EstadisticasTheme.accent5
                      : EstadisticasTheme.accent3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
