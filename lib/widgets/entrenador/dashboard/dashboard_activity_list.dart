import 'package:flutter/material.dart';

import 'dashboard_activity_row.dart';
import 'dashboard_models.dart';
import 'dashboard_theme.dart';

/// Lista de "Próximos eventos (7 días)" con estados de carga, error y vacío.
class DashboardActivityList extends StatelessWidget {
  final List<EntrenadorEventoProximo> eventos;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const DashboardActivityList({
    super.key,
    required this.eventos,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null && eventos.isEmpty) {
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

    if (loading && eventos.isEmpty) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: DashboardTheme.bgCardHover,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    }

    if (eventos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No tienes sesiones programadas para los próximos 7 días.',
          style: TextStyle(
            fontSize: 14,
            color: DashboardTheme.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: eventos.map((e) => DashboardActivityRow(evento: e)).toList(),
    );
  }
}
