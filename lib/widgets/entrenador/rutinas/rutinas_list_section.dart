import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import '../gestion/gestion_athlete.dart';
import 'rutinas_catalog.dart';
import 'rutinas_common_widgets.dart';
import 'rutinas_routine_card.dart';

/// Separador con título dinámico de la sección de rutinas.
class RutinasListDivider extends StatelessWidget {
  final String label;
  const RutinasListDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Expanded(child: Divider(color: DashColors.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                color: DashColors.textMuted,
              ),
            ),
          ),
          const Expanded(child: Divider(color: DashColors.border, height: 1)),
        ],
      );
}

/// "Total: N rutinas" + selector "Ver rutinas de" + filtros por tipo.
class RutinasListHeader extends StatelessWidget {
  final int count;
  final String filter;
  final String verAtleta;
  final List<EntrenadorDeportista> deportistas;
  final RutinaAtleta? atletaVisto;
  final ValueChanged<String> onFilter;
  final ValueChanged<String> onVerAtleta;

  const RutinasListHeader({
    super.key,
    required this.count,
    required this.filter,
    required this.verAtleta,
    required this.deportistas,
    this.atletaVisto,
    required this.onFilter,
    required this.onVerAtleta,
  });

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('', 'Todos mis deportistas'),
      for (final d in deportistas) ('${d.id}', d.nombreCompleto),
      if (atletaVisto != null &&
          !deportistas.any((d) => d.id == atletaVisto!.id))
        ('${atletaVisto!.id}', atletaVisto!.nombreCompleto),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Total: '),
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(color: DashColors.coachPurple),
                  ),
                  const TextSpan(text: ' rutinas'),
                ],
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'VER RUTINAS DE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: DashColors.textMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  constraints: const BoxConstraints(minWidth: 190, maxWidth: 240),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: rtBox(DashColors.card2, 9),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: items.any((i) => i.$1 == verAtleta)
                          ? verAtleta
                          : '',
                      isExpanded: true,
                      dropdownColor: DashColors.card,
                      style: const TextStyle(
                        color: DashColors.text,
                        fontSize: 13,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: DashColors.textMuted,
                      ),
                      items: [
                        for (final i in items)
                          DropdownMenuItem(
                            value: i.$1,
                            child: Text(i.$2, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) onVerAtleta(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in ['Todas', ...kRutinaTypeColors.keys])
              RtPill(text: t, selected: filter == t, onTap: () => onFilter(t)),
          ],
        ),
      ],
    );
  }
}

/// Cuadrícula responsiva de rutinas (o estado vacío contextual).
class RutinasGrid extends StatelessWidget {
  final double width;
  final List<RutinaEntrenador> list;
  final String today;
  final String emptyMessage;
  final ValueChanged<RutinaEntrenador> onEdit;
  final ValueChanged<RutinaEntrenador> onDelete;

  const RutinasGrid({
    super.key,
    required this.width,
    required this.list,
    required this.today,
    required this.emptyMessage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              const Opacity(
                opacity: 0.3,
                child: Text('📋', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: 0.55,
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 1,
                    color: DashColors.textMuted,
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
              today: today,
              onEdit: () => onEdit(r),
              onDelete: () => onDelete(r),
            ),
          ),
      ],
    );
  }
}
