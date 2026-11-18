import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_model.dart';

/// Panel lateral "Próximos eventos".
class EventsPanel extends StatelessWidget {
  final bool narrow;
  final double calH;
  final List<Ev> events;
  final ValueChanged<Ev> onEdit;
  final VoidCallback onNew;

  const EventsPanel({
    super.key,
    required this.narrow,
    required this.calH,
    required this.events,
    required this.onEdit,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final future = events.where((e) => e.end.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final list = future.take(10).toList();

    final items = list.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No hay eventos próximos',
                style: TextStyle(fontSize: 12, color: HC.t3),
              ),
            ),
          )
        : Column(children: [for (final ev in list) _item(ev)]);

    final boton = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onNew,
        borderRadius: BorderRadius.circular(9),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HC.purpleG1, HC.purpleG2],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: HC.purple.withValues(alpha: 0.35),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 14, color: Colors.white),
              SizedBox(width: 7),
              Text(
                'Nuevo evento',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      height: narrow ? null : calH,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: hBox(HC.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Próximos eventos',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: HC.t1,
            ),
          ),
          const SizedBox(height: 12),
          if (narrow)
            items
          else
            Expanded(child: SingleChildScrollView(child: items)),
          const SizedBox(height: 12),
          boton,
        ],
      ),
    );
  }

  Widget _item(Ev ev) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => onEdit(ev),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotFg(ev.type).withValues(alpha: 0.15),
              ),
              child: Icon(tipoIcon(ev.type), size: 13, color: dotFg(ev.type)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: HC.t1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ev.start.day} ${kMonthShort[ev.start.month - 1]} • ${fmtTime(ev.start)}',
                    style: const TextStyle(fontSize: 10.5, color: HC.t2),
                  ),
                  if (ev.place.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        ev.place,
                        style: const TextStyle(fontSize: 10, color: HC.t3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
