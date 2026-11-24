import 'package:flutter/material.dart';

import '../../../models/my_matches_data.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';
import 'partido_form_fields.dart';

export 'partido_form_fields.dart';

List<PartidoPlayerDraft> buildPartidoRoster(
  CoachMatchTemplate tpl,
  CoachMatchDetail? inicial,
) {
  final iniMap = <int, CoachMatchPlayerStat>{
    for (final j in inicial?.jugadores ?? const <CoachMatchPlayerStat>[])
      j.deportistaId: j,
  };
  return <PartidoPlayerDraft>[
    for (final j in tpl.jugadores)
      PartidoPlayerDraft.fromTemplate(
        id: j.id,
        nombre: j.nombre,
        apellido: j.apellido,
        fotoUrl: j.fotoUrl,
        numeroCamiseta: j.numeroCamiseta,
        prev: iniMap.remove(j.id),
      ),
    for (final x in iniMap.values)
      PartidoPlayerDraft.fromTemplate(
        id: x.deportistaId,
        nombre: x.nombre,
        apellido: x.apellido,
        fotoUrl: x.fotoUrl,
        numeroCamiseta: x.numeroCamiseta,
        prev: x,
      ),
  ];
}

/// Tabla interactiva de estadísticas por jugador en el formulario de Partido.
class PartidoEditableStatsTable extends StatelessWidget {
  final List<PartidoPlayerDraft> roster;
  final bool guardando;
  final VoidCallback onChanged;

  const PartidoEditableStatsTable({
    super.key,
    required this.roster,
    required this.guardando,
    required this.onChanged,
  });

  static const _hdrStyle = TextStyle(
    fontSize: 10.2,
    fontWeight: FontWeight.w700,
    color: DashColors.textMuted,
  );
  static const _totStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: DashColors.text1,
  );

  Widget _col(double w, Widget child, {bool center = true}) =>
      SizedBox(width: w, child: center ? Center(child: child) : child);

  @override
  Widget build(BuildContext context) {
    final jugando = roster.where((r) => r.juega).toList();
    int sumOf(String k) => jugando.fold(0, (a, b) => a + (b.stats[k] ?? 0));
    final totalPts = jugando.fold(0, (a, b) => a + b.puntos);

    return Container(
      decoration: BoxDecoration(
        color: DashColors.coachCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 830),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: DashColors.coachBorder)),
                ),
                child: Row(
                  children: [
                    _col(175, const Text('JUGADOR', style: _hdrStyle), center: false),
                    _col(48, const Text('JUGÓ', style: _hdrStyle)),
                    for (final c in kPartidoCamposStat)
                      _col(
                        62,
                        Tooltip(
                          message: c.ayuda,
                          child: Text(c.t.toUpperCase(), style: _hdrStyle),
                        ),
                      ),
                    _col(48, const Text('PTS', style: _hdrStyle)),
                    _col(58, const Text('MIN', style: _hdrStyle)),
                  ],
                ),
              ),
              for (final r in roster) ...[
                _buildPlayerRow(r),
                if (r.juega) _buildObsRow(r),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: DashColors.blue.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    _col(175, Text('Equipo (${jugando.length})', style: _totStyle), center: false),
                    const SizedBox(width: 48),
                    for (final c in kPartidoCamposStat)
                      _col(62, Text('${sumOf(c.k)}', style: _totStyle)),
                    _col(48, Text('$totalPts', style: _totStyle)),
                    const SizedBox(width: 58),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerRow(PartidoPlayerDraft r) {
    final tag = r.numeroCamiseta != null ? ' #${r.numeroCamiseta}' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DashColors.coachBorder.withValues(alpha: r.juega ? 0.25 : 0.7),
          ),
        ),
      ),
      child: Row(
        children: [
          _col(
            175,
            Row(
              children: [
                EquipoAvatar(fotoUrl: r.fotoUrl, iniciales: r.iniciales, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${r.nombreCompleto}$tag',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      color: DashColors.text1,
                    ),
                  ),
                ),
              ],
            ),
            center: false,
          ),
          _col(
            48,
            Checkbox(
              value: r.juega,
              onChanged: guardando
                  ? null
                  : (v) {
                      r.juega = v == true;
                      onChanged();
                    },
            ),
          ),
          for (final c in kPartidoCamposStat)
            _col(
              62,
              _numBox(
                enabled: r.juega && !guardando,
                initial: '${r.stats[c.k] ?? 0}',
                maxVal: 999,
                onChanged: (val) {
                  r.stats[c.k] = val ?? 0;
                  onChanged();
                },
              ),
            ),
          _col(
            48,
            Text(
              r.juega ? '${r.puntos}' : '—',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: r.juega
                    ? DashColors.badgeRecepcionText
                    : DashColors.textMuted,
              ),
            ),
          ),
          _col(
            58,
            _numBox(
              enabled: r.juega && !guardando,
              initial: r.minutosJugados?.toString() ?? '',
              maxVal: 300,
              allowEmpty: true,
              onChanged: (val) {
                r.minutosJugados = val;
                onChanged();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObsRow(PartidoPlayerDraft r) {
    return Container(
      width: 815,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DashColors.coachBorder.withValues(alpha: 0.7)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('OBSERVACIÓN PARA ${r.nombre.toUpperCase()} ', style: _hdrStyle),
              Text(
                '· la verá ${r.nombre}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DashColors.successBadgeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: r.obsCtrl,
            maxLength: 600,
            enabled: !guardando,
            style: const TextStyle(fontSize: 12.8, color: DashColors.text1),
            decoration: partidoInputDeco(
              'Qué mejorar. Ej: baja el contacto en la recepción y no cruces el pie al sacar.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _numBox({
    required bool enabled,
    required String initial,
    required int maxVal,
    bool allowEmpty = false,
    required ValueChanged<int?> onChanged,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: SizedBox(
        width: 52,
        child: TextFormField(
          key: ValueKey('$enabled-$initial'),
          initialValue: initial,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.5, color: DashColors.text1),
          decoration: partidoInputDeco(),
          onChanged: (txt) {
            final t = txt.trim();
            if (t.isEmpty) return onChanged(allowEmpty ? null : 0);
            onChanged((int.tryParse(t) ?? 0).clamp(0, maxVal));
          },
        ),
      ),
    );
  }
}
