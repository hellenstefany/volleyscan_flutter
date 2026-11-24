import 'package:flutter/material.dart';
import '../../../models/rutina_entrenador_data.dart';
import '../../../theme/dash_colors.dart';
import '../gestion/gestion_athlete.dart';
import 'rutinas_attention_card.dart';
import 'rutinas_catalog.dart';
import 'rutinas_header.dart';
import 'rutinas_list_section.dart';
import 'rutinas_presets_card.dart';
import 'rutinas_progress_card.dart';
import 'rutinas_stats.dart';
import 'rutinas_week_card.dart';

/// Cuerpo principal de `RutinasScreen` con diseño responsivo y pull-to-refresh.
class RutinasBody extends StatelessWidget {
  final double width;
  final String hoy;
  final List<EntrenadorDeportista> deportistas;
  final List<RutinaEntrenador> visibles;
  final List<RutinaEntrenador> filtered;
  final List<RutinaEntrenador> enSemana;
  final RutinaAtleta? atletaVisto;
  final String verAtleta;
  final String filter;
  final String emptyMsg;
  final String resumen;
  final Widget form;
  final Future<void> Function() onRefresh;
  final ValueChanged<RutinaPreset> onLoadPreset;
  final ValueChanged<String> onFilter;
  final ValueChanged<String> onVerAtleta;
  final ValueChanged<RutinaEntrenador> onEdit;
  final ValueChanged<RutinaEntrenador> onDelete;

  const RutinasBody({
    super.key,
    required this.width,
    required this.hoy,
    required this.deportistas,
    required this.visibles,
    required this.filtered,
    required this.enSemana,
    required this.atletaVisto,
    required this.verAtleta,
    required this.filter,
    required this.emptyMsg,
    required this.resumen,
    required this.form,
    required this.onRefresh,
    required this.onLoadPreset,
    required this.onFilter,
    required this.onVerAtleta,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = width >= 700;
    final right = Column(
      children: [
        RutinasPresetsCard(onLoad: onLoadPreset),
        const SizedBox(height: 12),
        RutinasProgressCard(enSemana: enSemana),
        const SizedBox(height: 12),
        RutinasAttentionCard(resumen: resumen),
      ],
    );

    return RefreshIndicator(
      color: DashColors.coachPurple,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RutinasHeader(),
            const SizedBox(height: 18),
            RutinasStats(
              width: width - 32,
              visibles: visibles,
              deportistasCount: deportistas.length,
              today: hoy,
            ),
            const SizedBox(height: 10),
            RutinasWeekCard(visibles: visibles, today: hoy),
            const SizedBox(height: 14),
            if (ancho)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: form),
                  const SizedBox(width: 14),
                  Expanded(child: right),
                ],
              )
            else ...[
              form,
              const SizedBox(height: 14),
              right,
            ],
            const SizedBox(height: 22),
            RutinasListDivider(
              label: atletaVisto != null
                  ? 'Rutinas de ${atletaVisto!.nombreCompleto}'
                  : 'Rutinas Asignadas',
            ),
            const SizedBox(height: 22),
            RutinasListHeader(
              count: filtered.length,
              filter: filter,
              verAtleta: verAtleta,
              deportistas: deportistas,
              atletaVisto: atletaVisto,
              onFilter: onFilter,
              onVerAtleta: onVerAtleta,
            ),
            const SizedBox(height: 16),
            RutinasGrid(
              width: width - 32,
              list: filtered,
              today: hoy,
              emptyMessage: emptyMsg,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
