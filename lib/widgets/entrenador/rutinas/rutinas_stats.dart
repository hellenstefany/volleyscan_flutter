import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_common_widgets.dart';

/// Tarjetas de estadísticas (total, completadas, hoy, deportistas activos).
class RutinasStats extends StatelessWidget {
  final double width;
  final List<RutinaEntrenador> visibles;
  final int deportistasCount;
  final String today;

  const RutinasStats({
    super.key,
    required this.width,
    required this.visibles,
    required this.deportistasCount,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final done = visibles.where((r) => r.completada).length;
    final pct = visibles.isEmpty ? 0 : (done / visibles.length * 100).round();
    final hoyCount = visibles.where((r) => r.fechaProgramada == today).length;
    final items = [
      ('Total rutinas', '${visibles.length}', 'asignadas', DashColors.coachPurple),
      ('Completadas', '$done', '$pct% del total', DashColors.greenTeal),
      ('Hoy programadas', '$hoyCount', 'sesiones', DashColors.cyan),
      (
        'Deportistas activos',
        '$deportistasCount',
        'vinculados contigo',
        DashColors.amber,
      ),
    ];
    const gap = 10.0;
    final cols = width >= 600 ? 4 : 2;
    final itemW = (width - gap * (cols - 1)) / cols;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final s in items)
          SizedBox(
            width: itemW,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: rtBox(DashColors.card, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DashColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$2,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: s.$4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.$3,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DashColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
