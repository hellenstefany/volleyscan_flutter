import 'package:flutter/material.dart';

import 'dashboard_kpi_card.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Cuadrícula de tarjetas KPI. [width] es el ancho disponible del contenido.
class DashboardKpis extends StatelessWidget {
  final double width;
  final int sessionCount;

  const DashboardKpis({
    super.key,
    required this.width,
    required this.sessionCount,
  });

  @override
  Widget build(BuildContext context) {
    final w = width;

    final kpis = [
      const DashboardKpi(
        Color(0xFF4F6EF7),
        '👥',
        'Total Deportistas',
        24,
        '',
        sub: 'Activos',
      ),
      DashboardKpi(
        DashboardTheme.teal,
        '✅',
        'Sesiones esta semana',
        sessionCount,
        '',
        sub: 'Completadas',
      ),
      const DashboardKpi(
        DashboardTheme.green,
        '⏱',
        'Asistencia promedio',
        87,
        '%',
        delta: '▲ +5% vs semana pasada',
      ),
      const DashboardKpi(
        DashboardTheme.gold,
        '📈',
        'Rendimiento promedio',
        78,
        '%',
        delta: '▲ +8% vs semana pasada',
      ),
    ];

    // Se decide la cuadrícula por el ancho disponible, no el de todo el dispositivo.
    final cols = w < 600 ? 2 : (w < 1000 ? 3 : 4);
    final gap = w < 600 ? 12.0 : 16.0;
    final itemW = ((w - gap * (cols - 1)) / cols).clamp(0.0, w).toDouble();
    final compactCards = itemW < 220;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: kpis
          .map(
            (k) => SizedBox(
              width: itemW,
              child: DashboardKpiCard(kpi: k, narrow: compactCards),
            ),
          )
          .toList(),
    );
  }
}
