import 'package:flutter/material.dart';

import '../../../models/equipo.dart';
import '../../../models/my_matches_data.dart';
import '../../../theme/dash_colors.dart';

InputDecoration partidoInputDeco([String hint = '']) => InputDecoration(
      isDense: true,
      filled: true,
      fillColor: DashColors.bg,
      counterText: '',
      hintText: hint,
      hintStyle: const TextStyle(color: DashColors.text3, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DashColors.coachBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DashColors.blue),
      ),
    );

Widget partidoFieldLabel(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: DashColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );

class PartidoPlayerDraft {
  final int id;
  final String nombre, apellido;
  final String? fotoUrl;
  final int? numeroCamiseta;
  bool juega;
  final Map<String, int> stats;
  int? minutosJugados;
  final TextEditingController obsCtrl;

  PartidoPlayerDraft({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.numeroCamiseta,
    required this.juega,
    required this.stats,
    this.minutosJugados,
    String observacion = '',
  }) : obsCtrl = TextEditingController(text: observacion);

  factory PartidoPlayerDraft.fromTemplate({
    required int id,
    required String nombre,
    required String apellido,
    String? fotoUrl,
    int? numeroCamiseta,
    CoachMatchPlayerStat? prev,
  }) =>
      PartidoPlayerDraft(
        id: id,
        nombre: nombre,
        apellido: apellido,
        fotoUrl: fotoUrl,
        numeroCamiseta: numeroCamiseta,
        juega: prev != null,
        stats: {
          for (final c in kPartidoCamposStat)
            c.k: prev?.stats.statByKey(c.k) ?? 0,
        },
        minutosJugados: prev?.stats.minutosJugados,
        observacion: prev?.observacion ?? '',
      );

  Map<String, dynamic> toPayload() => <String, dynamic>{
        'deportistaId': id,
        for (final c in kPartidoCamposStat) c.k: stats[c.k] ?? 0,
        'minutosJugados': minutosJugados,
        'observacion':
            obsCtrl.text.trim().isEmpty ? null : obsCtrl.text.trim(),
      };

  String get nombreCompleto =>
      [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');
  String get iniciales => buildEquipoInitials(nombre, apellido);
  int get puntos =>
      (stats['ataquesExitosos'] ?? 0) +
      (stats['bloqueos'] ?? 0) +
      (stats['saquesExitosos'] ?? 0);
}

/// Campos principales del formulario de Partido (Equipo, Evento, Rival, Fecha, Sets, Lugar).
class PartidoFormTopFields extends StatelessWidget {
  final List<Equipo> equipos;
  final int equipoId;
  final int? horarioId;
  final List<DropdownMenuItem<int?>> evOpts;
  final TextEditingController rivalCtrl;
  final TextEditingController lugarCtrl;
  final String fecha;
  final int setsG, setsP;
  final bool editando, guardando;
  final ValueChanged<int> onEquipoChanged;
  final ValueChanged<int?> onEventoChanged;
  final VoidCallback onPickFecha;
  final ValueChanged<int> onSetsGChanged;
  final ValueChanged<int> onSetsPChanged;

  const PartidoFormTopFields({
    super.key,
    required this.equipos,
    required this.equipoId,
    required this.horarioId,
    required this.evOpts,
    required this.rivalCtrl,
    required this.lugarCtrl,
    required this.fecha,
    required this.setsG,
    required this.setsP,
    required this.editando,
    required this.guardando,
    required this.onEquipoChanged,
    required this.onEventoChanged,
    required this.onPickFecha,
    required this.onSetsGChanged,
    required this.onSetsPChanged,
  });

  Widget _setDrop(int value, ValueChanged<int> onChanged) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        dropdownColor: DashColors.cardDark,
        style: const TextStyle(
          color: DashColors.text1,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        decoration: partidoInputDeco(),
        items: [
          for (var i = 0; i <= 3; i++)
            DropdownMenuItem(value: i, child: Text('$i')),
        ],
        onChanged: guardando ? null : (v) => onChanged(v ?? value),
      );

  @override
  Widget build(BuildContext context) {
    final equipoDrop = partidoFieldLabel(
      'Equipo',
      DropdownButtonFormField<int>(
        initialValue: equipos.any((e) => e.id == equipoId) ? equipoId : null,
        isExpanded: true,
        dropdownColor: DashColors.cardDark,
        style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
        decoration: partidoInputDeco(),
        items: [
          for (final e in equipos)
            DropdownMenuItem(
              value: e.id,
              child: Text(e.nombre, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (editando || guardando)
            ? null
            : (v) {
                if (v != null && v != equipoId) onEquipoChanged(v);
              },
      ),
    );
    final eventoDrop = partidoFieldLabel(
      'Evento del Horario (opcional)',
      DropdownButtonFormField<int?>(
        initialValue: evOpts.any((o) => o.value == horarioId) ? horarioId : null,
        isExpanded: true,
        dropdownColor: DashColors.cardDark,
        style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
        decoration: partidoInputDeco(),
        items: evOpts,
        onChanged: guardando ? null : onEventoChanged,
      ),
    );
    final rivalField = partidoFieldLabel(
      'Rival',
      TextField(
        controller: rivalCtrl,
        maxLength: 150,
        enabled: !guardando,
        style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
        decoration: partidoInputDeco('Nombre del equipo rival'),
      ),
    );
    final fechaField = partidoFieldLabel(
      'Fecha',
      InkWell(
        onTap: guardando ? null : onPickFecha,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: DashColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashColors.coachBorder),
          ),
          child: Text(fecha, style: const TextStyle(color: DashColors.text1, fontSize: 13.5)),
        ),
      ),
    );
    final setsField = partidoFieldLabel(
      'Sets (nosotros – rival)',
      Row(
        children: [
          Expanded(child: _setDrop(setsG, onSetsGChanged)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('–', style: TextStyle(color: DashColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: _setDrop(setsP, onSetsPChanged)),
        ],
      ),
    );
    final lugarField = partidoFieldLabel(
      'Lugar',
      TextField(
        controller: lugarCtrl,
        maxLength: 150,
        enabled: !guardando,
        style: const TextStyle(color: DashColors.text1, fontSize: 13.5),
        decoration: partidoInputDeco('Cancha o coliseo'),
      ),
    );

    return LayoutBuilder(
      builder: (_, c) {
        final narrow = c.maxWidth < 560;
        return Column(
          children: [
            if (narrow) ...[
              equipoDrop,
              const SizedBox(height: 12),
              eventoDrop,
              const SizedBox(height: 12),
              rivalField,
              const SizedBox(height: 12),
              Row(children: [Expanded(child: fechaField), const SizedBox(width: 12), Expanded(child: setsField)]),
            ] else ...[
              Row(children: [Expanded(child: equipoDrop), const SizedBox(width: 12), Expanded(child: eventoDrop)]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 2, child: rivalField),
                  const SizedBox(width: 12),
                  Expanded(child: fechaField),
                  const SizedBox(width: 12),
                  Expanded(child: setsField),
                ],
              ),
            ],
            const SizedBox(height: 12),
            lugarField,
          ],
        );
      },
    );
  }
}
