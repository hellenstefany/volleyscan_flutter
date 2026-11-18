import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_model.dart';
import 'rutinas_routine_card.dart';

/// Separador "RUTINAS REGISTRADAS".
class RutinasListDivider extends StatelessWidget {
  const RutinasListDivider({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: RtC.border, height: 1)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text(
          'RUTINAS REGISTRADAS',
          style: TextStyle(fontSize: 11, letterSpacing: 2, color: RtC.muted),
        ),
      ),
      Expanded(child: Divider(color: RtC.border, height: 1)),
    ],
  );
}

/// "Total: N rutinas" + filtros por tipo.
class RutinasListHeader extends StatelessWidget {
  final int count;
  final String filter;
  final ValueChanged<String> onFilter;
  const RutinasListHeader({
    super.key,
    required this.count,
    required this.filter,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    runSpacing: 10,
    spacing: 12,
    children: [
      Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Total: '),
            TextSpan(
              text: '$count',
              style: const TextStyle(color: RtC.accent),
            ),
            const TextSpan(text: ' rutinas'),
          ],
        ),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: RtC.text,
        ),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final t in ['Todas', ...kTypeColors.keys])
            RtPill(text: t, selected: filter == t, onTap: () => onFilter(t)),
        ],
      ),
    ],
  );
}

/// Cuadrícula responsiva de rutinas (o estado vacío).
class RutinasGrid extends StatelessWidget {
  final double width;
  final List<Routine> list;
  final ValueChanged<Routine> onToggleDone, onEdit, onDelete;
  const RutinasGrid({
    super.key,
    required this.width,
    required this.list,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Opacity(
                opacity: 0.3,
                child: Text('📋', style: TextStyle(fontSize: 48)),
              ),
              SizedBox(height: 10),
              Opacity(
                opacity: 0.5,
                child: Text(
                  'Sin rutinas registradas',
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                    color: RtC.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    const gap = 16.0;
    final cols = math.max(1, ((width + gap) / (300 + gap)).floor());
    final itemW = (width - gap * (cols - 1)) / cols;

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final r in list)
          SizedBox(
            width: itemW,
            child: RoutineCard(
              r: r,
              onToggleDone: () => onToggleDone(r),
              onEdit: () => onEdit(r),
              onDelete: () => onDelete(r),
            ),
          ),
      ],
    );
  }
}
