import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_player_row.dart';
import 'dashboard_theme.dart';

/// Lista de "Últimos partidos" con estados de carga, error y vacío.
class DashboardPlayersList extends StatelessWidget {
  final List<EntrenadorUltimoPartido> partidos;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final void Function(EntrenadorUltimoPartido partido) onPartidoTap;

  const DashboardPlayersList({
    super.key,
    required this.partidos,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onPartidoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null && partidos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error!,
              style: const TextStyle(
                fontSize: 13,
                color: DashboardTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
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

    if (loading && partidos.isEmpty) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: DashboardTheme.bgCardHover,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }

    if (partidos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Aún no has registrado partidos con tus equipos.',
          style: TextStyle(
            fontSize: 14,
            color: DashboardTheme.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < partidos.length; i++)
          DashboardPlayerRow(
            rank: i + 1,
            partido: partidos[i],
            color: dashboardRowPalette[i % dashboardRowPalette.length].$1,
            bg: dashboardRowPalette[i % dashboardRowPalette.length].$2,
            onTap: () => onPartidoTap(partidos[i]),
          ),
      ],
    );
  }
}
