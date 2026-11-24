import 'package:flutter/material.dart';
import '../../../theme/dash_colors.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

class MonthView extends StatelessWidget {
  final DateTime current;
  final List<CoachScheduleEvent> events;
  final ValueChanged<DateTime> onNew;
  final ValueChanged<CoachScheduleEvent> onEdit;

  const MonthView({
    super.key,
    required this.current,
    required this.events,
    required this.onNew,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final y = current.year, m = current.month;
    final first = DateTime(y, m, 1);
    final prevDays = first.weekday - 1;
    final today = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              for (final d in kDayNames)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: HC.t3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 0; row < 6; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: col < 6 ? 4 : 0),
                        child: _cell(
                          DateTime(y, m, 1 - prevDays + row * 7 + col),
                          m,
                          today,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(DateTime date, int month, DateTime today) {
    final isToday = sameDay(date, today);
    final other = date.month != month;
    final delDia = eventsForDay(events, date);
    final evs = delDia.take(3).toList();

    return Opacity(
      opacity: other ? 0.35 : 1,
      child: InkWell(
        onTap: () => onNew(date),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isToday ? HC.blue.withValues(alpha: 0.07) : HC.card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isToday ? HC.blue : HC.border),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isToday ? HC.blue2 : HC.t2,
                  ),
                ),
                for (final ev in evs)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Opacity(
                      opacity: ev.isCancelled ? 0.45 : 1.0,
                      child: GestureDetector(
                        onTap: () => onEdit(ev),
                        child: EvBox(
                          bg: evBg(ev.tipo),
                          border: evBorder(ev.tipo),
                          radius: 4,
                          width: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              '${ev.horaInicio} ${ev.titulo.length > 12 ? '${ev.titulo.substring(0, 12)}...' : ev.titulo}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: DashColors.textPrimary,
                                decoration: ev.isCancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (delDia.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '+${delDia.length - 3} más',
                      style: const TextStyle(fontSize: 10, color: HC.t2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
