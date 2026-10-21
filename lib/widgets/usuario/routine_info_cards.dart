import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

class _InfoCardShell extends StatelessWidget {
  final Widget child;
  const _InfoCardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: child,
    );
  }
}

const _labelStyle = TextStyle(
  color: RoutineColors.textMuted,
  fontSize: 11,
  fontWeight: FontWeight.w600,
  letterSpacing: 1.4,
);

/// Tarjeta "OBJETIVO DE LA SEMANA".
class WeeklyGoalCard extends StatelessWidget {
  final String goal;
  const WeeklyGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RoutineColors.teal.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.track_changes,
              color: RoutineColors.teal,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OBJETIVO DE LA SEMANA', style: _labelStyle),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta "NIVEL DE DIFICULTAD" con barra de 3 segmentos.
class DifficultyCard extends StatelessWidget {
  final String label; // Intermedio
  final int level; // 1..3

  const DifficultyCard({super.key, required this.label, required this.level});

  static const _segmentColors = [
    RoutineColors.blue,
    RoutineColors.teal,
    RoutineColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return _InfoCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.add_circle, color: RoutineColors.blue, size: 16),
              SizedBox(width: 8),
              Text('NIVEL DE DIFICULTAD', style: _labelStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final active = i < level;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: active ? _segmentColors[i] : RoutineColors.trackGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
