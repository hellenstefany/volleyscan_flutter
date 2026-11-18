import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_model.dart';

/// Tarjeta "Semana actual": un punto por día con rutinas.
class RutinasWeekCard extends StatelessWidget {
  final List<Routine> routines;
  final String today;
  const RutinasWeekCard({
    super.key,
    required this.routines,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: rtBox(RtC.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '📅', title: 'Semana actual'),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final d = monday.add(Duration(days: i));
                      final iso = isoDate(d);
                      final has = routines.any((r) => r.date == iso);
                      final isToday = iso == today;
                      return Column(
                        children: [
                          Text(
                            names[i],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: RtC.muted,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: has ? RtC.accent : RtC.border,
                              boxShadow: has
                                  ? [
                                      BoxShadow(
                                        color: RtC.accent.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                              border: isToday
                                  ? Border.all(color: RtC.accent4, width: 2)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${d.day}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: RtC.muted,
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
