import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta "Sugerencia IA".
class RutinasAiCard extends StatelessWidget {
  const RutinasAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RtC.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RtC.accent.withValues(alpha: 0.25)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RtCardTitle(icon: '🤖', title: 'Sugerencia IA'),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '🏐 '),
                TextSpan(
                  text: 'Juan García',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: RtC.text,
                  ),
                ),
                TextSpan(
                  text:
                      ' lleva 3 sesiones consecutivas de alta intensidad. Considera agregar recuperación activa mañana.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 13, color: RtC.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}
