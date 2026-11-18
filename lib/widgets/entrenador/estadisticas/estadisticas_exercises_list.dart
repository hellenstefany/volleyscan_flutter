import 'package:flutter/material.dart';

import 'estadisticas_models.dart';
import 'estadisticas_no_data.dart';
import 'estadisticas_theme.dart';

/// Lista de tipos de ejercicio con su porcentaje.
class EstadisticasExercisesList extends StatelessWidget {
  final List<EstadisticasItem> exercises;
  const EstadisticasExercisesList({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const EstadisticasNoData(icon: '🏐');

    return Column(
      children: exercises
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: e.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: EstadisticasTheme.text,
                      ),
                    ),
                  ),
                  Text(
                    '${e.pct}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: EstadisticasTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
