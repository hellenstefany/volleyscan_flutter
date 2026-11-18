import 'package:flutter/material.dart';
import '../../../models/routine_data.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta lateral/inferior "Resumen" con métricas, barras de dificultad y CTA.
class RoutineSummaryCard extends StatelessWidget {
  final RoutineDetail routine;
  final bool hasNext;
  final VoidCallback onJumpToNext;

  const RoutineSummaryCard({
    super.key,
    required this.routine,
    required this.hasNext,
    required this.onJumpToNext,
  });

  static const _barColors = <Color>[
    DashColors.blueLight,
    DashColors.teal,
    DashColors.green,
    DashColors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final total = routine.progreso.total;
    final completados = routine.progreso.completados;
    final pendientes = (total - completados).clamp(0, total);
    final seriesTotal =
        routine.ejercicios.fold<int>(0, (sum, e) => sum + e.series);
    final seriesHechas = routine.ejercicios
        .where((e) => e.completado)
        .fold<int>(0, (sum, e) => sum + e.series);

    final idxNivel = routineLevelIndex(routine.nivel);
    final diffLabel = routine.nivel == 'todos'
        ? 'para todos los niveles'
        : formatRoutineLevelLabel(routine.nivel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESUMEN',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: DashColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '$completados',
                  label: 'Hechos',
                  valueColor: DashColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(value: '$pendientes', label: 'Pendientes'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '$seriesHechas/$seriesTotal',
                  label: 'Series',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${routine.ejercicios.length}',
                  label: 'Ejercicios',
                  icon: Icons.fitness_center_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dificultad',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: DashColors.muted,
                ),
              ),
              Text(
                diffLabel,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(routineLevelOrder.length, (i) {
              final active = i <= idxNivel;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: i < routineLevelOrder.length - 1 ? 6 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? _barColors[i]
                        : DashColors.textPrimary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
          if (hasNext) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onJumpToNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashColors.blueLight,
                  foregroundColor: DashColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Ir al siguiente ejercicio',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final IconData? icon;

  const _StatTile({
    required this.value,
    required this.label,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashColors.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: DashColors.textPrimary),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: valueColor ?? DashColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: DashColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
