import 'package:flutter/material.dart';

import '../../../models/my_matches_data.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';

enum PartidoDetailOutcome { edit, deleted }

/// Modal de detalle de un partido con tabla de estadísticas por jugador,
/// notas privadas del entrenador y observaciones visibles para cada jugador.
class PartidoDetailDialog extends StatefulWidget {
  final CoachMatchDetail partido;
  const PartidoDetailDialog({super.key, required this.partido});

  @override
  State<PartidoDetailDialog> createState() => _PartidoDetailDialogState();
}

class _PartidoDetailDialogState extends State<PartidoDetailDialog> {
  bool _borrando = false;

  Future<void> _borrar() async {
    if (_borrando) return;
    final p = widget.partido;
    final ok = await showEquipoConfirmDialog(
      context,
      title: 'Eliminar partido',
      message: '¿Eliminar el partido contra ${p.rival}? Se borran también las estadísticas de los jugadores.',
      confirmLabel: 'Eliminar',
    );
    if (!ok || !mounted) return;
    setState(() => _borrando = true);
    try {
      await ApiService().borrarPartidoEntrenador(p.id);
      if (!mounted) return;
      showAppToast(context, 'Partido eliminado.');
      Navigator.pop(context, PartidoDetailOutcome.deleted);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _borrando = false);
      showAppToast(context, e.message, type: 'error');
    } catch (_) {
      if (!mounted) return;
      setState(() => _borrando = false);
      showAppToast(context, 'No se pudo eliminar el partido.', type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partido;
    final t = p.totales;
    final conObs = p.jugadores.where((j) => j.observacion != null && j.observacion!.isNotEmpty).toList();
    final sub = '${p.equipo} · ${formatPartidoFecha(p.fecha)}'
        '${p.ubicacion != null && p.ubicacion!.isNotEmpty ? ' · ${p.ubicacion}' : ''}';

    return Dialog(
      backgroundColor: DashColors.cardDark,
      insetPadding: const EdgeInsets.all(14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: DashColors.coachBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 740),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DashColors.coachBorder))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub, style: const TextStyle(fontSize: 13, color: DashColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          '${p.esVictoria ? 'Victoria' : 'Derrota'} ${p.setsGanados}–${p.setsPerdidos} vs ${p.rival}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: DashColors.text1),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _borrando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18, color: DashColors.textMuted),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: DashColors.coachBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (p.notas != null && p.notas!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.blue.withValues(alpha: 0.28)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NOTAS DEL ENTRENADOR · PRIVADAS',
                              style: TextStyle(fontSize: 11.2, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: AppColors.indigoSoft),
                            ),
                            const SizedBox(height: 4),
                            Text(p.notas!, style: const TextStyle(fontSize: 13.5, color: DashColors.textSecondary, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (p.jugadores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Este partido se registró solo con el resultado, sin estadísticas por jugador.',
                          style: TextStyle(fontSize: 13.5, color: DashColors.textMuted),
                        ),
                      )
                    else
                      _buildStatsTable(p, t),
                    if (conObs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: DashColors.green.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: DashColors.green.withValues(alpha: 0.30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OBSERVACIONES PARA LOS JUGADORES · ELLOS LAS VEN',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: DashColors.successBadgeText),
                            ),
                            const SizedBox(height: 8),
                            for (var i = 0; i < conObs.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              Text(conObs[i].nombreCompleto, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                              const SizedBox(height: 2),
                              Text(conObs[i].observacion!, style: const TextStyle(fontSize: 13.2, color: DashColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: DashColors.coachBorder))),
              child: Row(
                children: [
                  EquipoDangerButton(
                    label: _borrando ? 'Eliminando…' : 'Eliminar',
                    enabled: !_borrando,
                    onTap: _borrar,
                  ),
                  const Spacer(),
                  EquipoSecButton(label: 'Cerrar', enabled: !_borrando, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  EquipoPrimButton(
                    label: 'Editar',
                    enabled: !_borrando,
                    onTap: () => Navigator.pop(context, PartidoDetailOutcome.edit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTable(CoachMatchDetail p, MatchStats t) {
    const cols = ['JUGADOR', 'PTS', 'ATAQUE +/−', '% ATAQUE', 'BLOQ.', 'ACES', 'SAQUE ✗', 'RECEP. +/−', '% RECEP.', 'ERRORES'];
    return Container(
      decoration: BoxDecoration(
        color: DashColors.coachCard2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tableRow(
                isHeader: true,
                first: const Text('JUGADOR', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: DashColors.textMuted)),
                cells: [
                  for (var i = 1; i < cols.length; i++)
                    Text(cols[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: DashColors.textMuted)),
                ],
              ),
              for (final j in p.jugadores)
                _tableRow(
                  first: Row(
                    children: [
                      EquipoAvatar(fotoUrl: j.fotoUrl, iniciales: j.iniciales, size: 30),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          '${j.nombreCompleto}${j.numeroCamiseta != null ? ' #${j.numeroCamiseta}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DashColors.text1),
                        ),
                      ),
                    ],
                  ),
                  cells: _statCells(j.stats),
                ),
              _tableRow(
                isTotal: true,
                first: const Text('Equipo', style: TextStyle(fontSize: 13.2, fontWeight: FontWeight.w700, color: DashColors.text1)),
                cells: _statCells(t, isTotal: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _statCells(MatchStats s, {bool isTotal = false}) {
    final baseStyle = TextStyle(fontSize: 13, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500, color: isTotal ? DashColors.text1 : DashColors.textSecondary);
    final pctStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isTotal ? DashColors.text1 : DashColors.accent2);
    final ptStyle = TextStyle(fontSize: 13.2, fontWeight: FontWeight.w800, color: isTotal ? DashColors.text1 : DashColors.badgeRecepcionText);
    return [
      Text('${s.puntosTotales}', textAlign: TextAlign.center, style: ptStyle),
      Text('${s.ataquesExitosos}/${s.ataquesFallidos}', textAlign: TextAlign.center, style: baseStyle),
      Text(formatPercentOrDash(s.efectividadAtaque), textAlign: TextAlign.center, style: pctStyle),
      Text('${s.bloqueos}', textAlign: TextAlign.center, style: baseStyle),
      Text('${s.saquesExitosos}', textAlign: TextAlign.center, style: baseStyle),
      Text('${s.saquesFallidos}', textAlign: TextAlign.center, style: baseStyle),
      Text('${s.recepcionesExitosas}/${s.recepcionesFalladas}', textAlign: TextAlign.center, style: baseStyle),
      Text(formatPercentOrDash(s.efectividadRecepcion), textAlign: TextAlign.center, style: pctStyle),
      Text('${s.erroresNoForzados}', textAlign: TextAlign.center, style: baseStyle),
    ];
  }

  Widget _tableRow({required Widget first, required List<Widget> cells, bool isHeader = false, bool isTotal = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isHeader ? 10 : 8),
      decoration: BoxDecoration(
        color: isTotal ? DashColors.blue.withValues(alpha: 0.08) : null,
        border: Border(
          top: isTotal ? const BorderSide(color: DashColors.coachBorder) : BorderSide.none,
          bottom: isTotal ? BorderSide.none : BorderSide(color: DashColors.coachBorder.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 190, child: first),
          for (final c in cells) SizedBox(width: 72, child: Center(child: c)),
        ],
      ),
    );
  }
}
