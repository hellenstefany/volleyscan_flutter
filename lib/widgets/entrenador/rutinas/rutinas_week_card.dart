import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta "Semana actual": un punto por día con rutinas.
class RutinasWeekCard extends StatelessWidget {
  final List<RutinaEntrenador> visibles;
  final String today;

  const RutinasWeekCard({
    super.key,
    required this.visibles,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: rtBox(DashColors.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '', title: 'Semana actual'),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final d = monday.add(Duration(days: i));
                      final iso = rtIsoDate(d);
                      final has = visibles.any((r) => r.fechaProgramada == iso);
                      final isToday = iso == today;
                      return Column(
                        children: [
                          Text(
                            names[i],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: DashColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: has
                                  ? DashColors.coachPurple
                                  : DashColors.border,
                              boxShadow: has
                                  ? [
                                      BoxShadow(
                                        color: DashColors.coachPurple
                                            .withValues(alpha: 0.25),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                              border: isToday
                                  ? Border.all(
                                      color: DashColors.amber,
                                      width: 2,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${d.day}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: DashColors.textMuted,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
