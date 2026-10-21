import 'package:flutter/material.dart';
import '../../models/progress_data.dart';
import '../../theme/routine_colors.dart';

const _green = Color(0xFF22C55E);

class ProgressStatCards extends StatelessWidget {
  final ProgressData data;
  const ProgressStatCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          label: 'PUNTUACIÓN PROMEDIO',
          value: '${data.averageScore}/100',
          icon: Icons.track_changes,
          iconColor: _green,
        ),
        _StatCard(
          label: 'MEJORA TOTAL',
          value: '+${data.totalImprovement}%',
          icon: Icons.trending_up,
          iconColor: _green,
          valueColor: _green,
        ),
        _StatCard(label: 'ANÁLISIS REALIZADO', value: '${data.analysesCount}'),
        _StatCard(label: 'TIEMPO ENTRENANDO', value: data.trainingTime),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              color: RoutineColors.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (iconColor ?? _green).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
