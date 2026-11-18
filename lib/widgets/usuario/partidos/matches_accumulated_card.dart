import 'package:flutter/material.dart';
import '../../../models/my_matches_data.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta "Mi acumulado" (`.acum` en `partidos.module.css`).
class MatchesAccumulatedCard extends StatelessWidget {
  final MatchAccumulated accumulated;

  const MatchesAccumulatedCard({super.key, required this.accumulated});

  @override
  Widget build(BuildContext context) {
    final s = accumulated.stats;
    final count = accumulated.partidos;
    final countLabel = '$count partido${count == 1 ? '' : 's'}';

    final items = <_AccumStatItem>[
      _AccumStatItem(
        value: '${s.puntosTotales}',
        label: 'PUNTOS',
        color: DashColors.badgeRecepcionText,
      ),
      _AccumStatItem(
        value: formatPercentOrDash(s.efectividadAtaque),
        label: '% ATAQUE',
        color: DashColors.accent2,
      ),
      _AccumStatItem(value: '${s.bloqueos}', label: 'BLOQUEOS'),
      _AccumStatItem(value: '${s.saquesExitosos}', label: 'ACES'),
      _AccumStatItem(
        value: formatPercentOrDash(s.efectividadRecepcion),
        label: '% RECEPCIÓN',
        color: DashColors.accent2,
      ),
      _AccumStatItem(value: '${s.erroresNoForzados}', label: 'ERRORES'),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashColors.surface,
            DashColors.coachCard2,
          ],
        ),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Mi acumulado',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                countLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: DashColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 640 ? 6 : 3;
              const spacing = 12.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: 14,
                children: items
                    .map(
                      (item) => SizedBox(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.value,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: item.color ?? DashColors.text,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: DashColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AccumStatItem {
  final String value;
  final String label;
  final Color? color;

  const _AccumStatItem({
    required this.value,
    required this.label,
    this.color,
  });
}
