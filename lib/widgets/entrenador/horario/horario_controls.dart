import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

/// Barra superior del calendario: ‹ › Hoy · Mes Año · Semana/Mes.
class CalendarControls extends StatelessWidget {
  final bool narrow;
  final DateTime current;
  final String view;
  final VoidCallback onPrev, onNext, onToday, onPickMonth;
  final ValueChanged<String> onView;

  const CalendarControls({
    super.key,
    required this.narrow,
    required this.current,
    required this.view,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onPickMonth,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CtrlBtn(icon: Icons.chevron_left, onTap: onPrev),
        const SizedBox(width: 6),
        CtrlBtn(icon: Icons.chevron_right, onTap: onNext),
        const SizedBox(width: 6),
        InkWell(
          onTap: onToday,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: HC.card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: HC.border2),
            ),
            child: const Text(
              'Hoy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: HC.t1,
              ),
            ),
          ),
        ),
      ],
    );

    final center = InkWell(
      onTap: onPickMonth,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${kMonthNames[current.month - 1]} ${current.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: HC.t1,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: HC.t1),
          ],
        ),
      ),
    );

    final right = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ViewBtn(
          label: 'Semana',
          active: view == 'semana',
          onTap: () => onView('semana'),
        ),
        const SizedBox(width: 6),
        ViewBtn(
          label: 'Mes',
          active: view == 'mes',
          onTap: () => onView('mes'),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HC.border)),
      ),
      child: narrow
          ? Column(
              children: [
                Row(children: [left, const Spacer(), right]),
                const SizedBox(height: 6),
                center,
              ],
            )
          : Row(
              children: [
                left,
                Expanded(child: Center(child: center)),
                right,
              ],
            ),
    );
  }
}
