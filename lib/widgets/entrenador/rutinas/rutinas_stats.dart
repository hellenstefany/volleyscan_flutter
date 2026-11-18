import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_model.dart';

/// Tarjetas de estadísticas (total, completadas, hoy, deportistas).
class RutinasStats extends StatelessWidget {
  final double width;
  final List<Routine> routines;
  final String today;
  const RutinasStats({
    super.key,
    required this.width,
    required this.routines,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final done = routines.where((r) => r.done).length;
    final pct = routines.isEmpty ? 0 : (done / routines.length * 100).round();
    final items = [
      ('Total rutinas', '${routines.length}', 'registradas', RtC.accent),
      ('Completadas', '$done', '$pct% del total', RtC.accent5),
      (
        'Hoy programadas',
        '${routines.where((r) => r.date == today).length}',
        'sesiones',
        RtC.accent2,
      ),
      ('Deportistas activos', '5', 'en el sistema', RtC.accent4),
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
              decoration: rtBox(RtC.card, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.$1,
                    style: const TextStyle(fontSize: 11, color: RtC.muted),
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
                    style: const TextStyle(fontSize: 11, color: RtC.muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
