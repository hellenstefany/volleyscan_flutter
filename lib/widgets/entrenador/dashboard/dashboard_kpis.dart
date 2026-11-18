import 'package:flutter/material.dart';

import 'dashboard_kpi_card.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Cuadrícula de las 4 tarjetas KPI reales (`deportistas_activos`, `eventos_proximos.length`,
/// `equipos_activos` y `analisis_pendientes`).
class DashboardKpis extends StatelessWidget {
  final double width;
  final EntrenadorDashboardData? data;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const DashboardKpis({
    super.key,
    required this.width,
    required this.data,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final w = width;
    final cols = w < 760 ? 2 : 4;
    final gap = w < 760 ? 12.0 : 16.0;
    final itemW = ((w - gap * (cols - 1)) / cols).clamp(0.0, w).toDouble();
    final compactCards = w < 760;

    if (error != null && data == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DashboardTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DashboardTheme.red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: DashboardTheme.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error!,
                style: const TextStyle(
                  fontSize: 13,
                  color: DashboardTheme.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashboardTheme.blue,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (loading && data == null) {
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: List.generate(
          4,
          (_) => SizedBox(
            width: itemW,
            child: Container(
              height: compactCards ? 86 : 96,
              padding: EdgeInsets.all(compactCards ? 14 : 18),
              decoration: BoxDecoration(
                color: DashboardTheme.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DashboardTheme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: compactCards ? 38 : 44,
                    height: compactCards ? 38 : 44,
                    decoration: BoxDecoration(
                      color: DashboardTheme.bgCardHover,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10,
                          width: 90,
                          decoration: BoxDecoration(
                            color: DashboardTheme.bgCardHover,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 22,
                          width: 48,
                          decoration: BoxDecoration(
                            color: DashboardTheme.bgCardHover,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final kpis = [
      DashboardKpi(
        DashboardTheme.blue,
        '👥',
        'Deportistas Activos',
        data?.deportistasActivos ?? 0,
        '',
        sub: 'En tus equipos',
      ),
      DashboardKpi(
        DashboardTheme.teal,
        '📅',
        'Eventos (Próx. 7 días)',
        data?.eventosProximos.length ?? 0,
        '',
        sub: 'Sesiones programadas',
      ),
      DashboardKpi(
        DashboardTheme.green,
        '🏐',
        'Equipos Activos',
        data?.equiposActivos ?? 0,
        '',
        sub: 'Bajo tu dirección',
      ),
      DashboardKpi(
        DashboardTheme.gold,
        '📹',
        'Análisis Pendientes',
        data?.analisisPendientes ?? 0,
        '',
        sub: 'Por revisar en IA',
      ),
    ];

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
