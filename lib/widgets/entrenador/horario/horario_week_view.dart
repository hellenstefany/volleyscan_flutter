import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

class WeekView extends StatelessWidget {
  final bool narrow;
  final DateTime current;
  final List<Ev> events;
  final void Function(DateTime day, int hour) onNewAt;
  final ValueChanged<Ev> onEdit;

  const WeekView({
    super.key,
    required this.narrow,
    required this.current,
    required this.events,
    required this.onNewAt,
    required this.onEdit,
  });

  List<DateTime> _weekDays() {
    final d = DateTime(current.year, current.month, current.day);
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekDays();
    final today = DateTime.now();
    final timeW = narrow ? 44.0 : 52.0;
    final minW = timeW + 588;

    return LayoutBuilder(
      builder: (context, c) {
        final scrolls = c.maxWidth < minW;
        final width = scrolls ? minW : c.maxWidth;

        final header = Container(
          decoration: const BoxDecoration(
            color: HC.card,
            border: Border(bottom: BorderSide(color: HC.border2)),
          ),
          child: Row(
            children: [
              SizedBox(width: timeW),
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      border: i < 6
                          ? const Border(right: BorderSide(color: HC.border))
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          kDayNames[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: sameDay(days[i], today) ? HC.blue2 : HC.t3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${days[i].day} ${kMonthShort[days[i].month - 1]}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: sameDay(days[i], today)
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: sameDay(days[i], today) ? HC.blue2 : HC.t2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );

        final timeCol = Container(
          width: timeW,
          decoration: const BoxDecoration(
            color: HC.card,
            border: Border(right: BorderSide(color: HC.border)),
          ),
          child: Column(
            children: [
              for (final h in kHours)
                Container(
                  height: kSlotH,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: HC.border)),
                  ),
                  child: Text(
                    '${pad2(h)}:00',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                      color: HC.t3,
                    ),
                  ),
                ),
            ],
          ),
        );

        final content = SizedBox(
          width: width,
          child: Column(
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      timeCol,
                      for (var i = 0; i < 7; i++)
                        Expanded(child: _dayColumn(days[i], last: i == 6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return scrolls
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              )
            : content;
      },
    );
  }

  Widget _dayColumn(DateTime day, {required bool last}) {
    final evs = events.where((e) => sameDay(e.start, day) && e.start.hour >= 6);

    return Container(
      height: kHours.length * kSlotH,
      decoration: BoxDecoration(
        border: last ? null : const Border(right: BorderSide(color: HC.border)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final h = (d.localPosition.dy ~/ kSlotH).clamp(0, 17) + 6;
                onNewAt(day, h);
              },
              child: Column(
                children: [
                  for (final _ in kHours)
                    Container(
                      height: kSlotH,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: HC.border)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final ev in evs)
            Positioned(
              left: 3,
              right: 3,
              top:
                  (ev.start.hour - 6) * kSlotH +
                  (ev.start.minute / 60) * kSlotH,
              height: ((ev.end.difference(ev.start).inMinutes / 60) * kSlotH)
                  .clamp(42.0, double.infinity),
              child: GestureDetector(
                onTap: () => onEdit(ev),
                child: EvBox(
                  bg: evBg(ev.type),
                  border: evBorder(ev.type),
                  radius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxHeight: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ev.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${fmtTime(ev.start)} - ${fmtTime(ev.end)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          if (ev.place.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              ev.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
