import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta "Atención" con resumen real de rutinas vencidas o completadas.
class RutinasAttentionCard extends StatelessWidget {
  final String resumen;

  const RutinasAttentionCard({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DashColors.coachPurple.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '🔔', title: 'Atención'),
          Text(
            resumen,
            style: const TextStyle(
              fontSize: 13,
              color: DashColors.textMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
