import 'package:flutter/material.dart';

import '../../../models/my_matches_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';

/// Bloque de 4 tarjetas KPI del récord de partidos (`resumen` en `GET /api/ia/partidos`).
class PartidosRecordSection extends StatelessWidget {
  final CoachMatchesSummary resumen;
  final bool narrow;

  const PartidosRecordSection({
    super.key,
    required this.resumen,
    required this.narrow,
  });

  @override
  Widget build(BuildContext context) {
    final pct = resumen.porcentajeVictorias ?? 0;
    final items = <Widget>[
      _RecordCard(value: '${resumen.jugados}', label: 'Partidos', color: DashColors.text1),
      _RecordCard(value: '${resumen.ganados}', label: 'Victorias', color: DashColors.badgeRecepcionText),
      _RecordCard(value: '${resumen.perdidos}', label: 'Derrotas', color: DashColors.warningText),
      _RecordCard(
        value: '$pct%',
        label: 'Sets ${resumen.setsGanados}–${resumen.setsPerdidos}',
        color: DashColors.text1,
      ),
    ];

    if (narrow) {
      return Column(
        children: [
          Row(children: [Expanded(child: items[0]), const SizedBox(width: 12), Expanded(child: items[1])]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: items[2]), const SizedBox(width: 12), Expanded(child: items[3])]),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: items[0]),
        const SizedBox(width: 12),
        Expanded(child: items[1]),
        const SizedBox(width: 12),
        Expanded(child: items[2]),
        const SizedBox(width: 12),
        Expanded(child: items[3]),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String value, label;
  final Color color;

  const _RecordCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1.1, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.2, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: DashColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un partido en la lista principal (`partidos` en `GET /api/ia/partidos`).
class PartidoListCard extends StatelessWidget {
  final CoachMatchListItem partido;
  final bool narrow;
  final VoidCallback onTap;

  const PartidoListCard({
    super.key,
    required this.partido,
    required this.narrow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final vic = partido.esVictoria;
    final accent = vic ? DashColors.green : DashColors.orange;
    final scoreColor = vic ? DashColors.badgeRecepcionText : DashColors.warningText;
    final scoreSub = vic ? DashColors.successBadgeText : DashColors.warningText;
    final jugTxt = '${partido.jugadores} jugador${partido.jugadores == 1 ? '' : 'es'}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.coachCardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: DashColors.coachBorder),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: accent),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(minWidth: 78),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accent.withValues(alpha: 0.30)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${partido.setsGanados}–${partido.setsPerdidos}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: scoreColor, height: 1.0),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  vic ? 'VICTORIA' : 'DERROTA',
                                  style: TextStyle(fontSize: 10.2, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: scoreSub),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'vs ${partido.rival}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: DashColors.text1),
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(formatPartidoFecha(partido.fecha), style: const TextStyle(fontSize: 13.2, color: DashColors.textMuted)),
                                    if (partido.ubicacion != null && partido.ubicacion!.isNotEmpty)
                                      Text(partido.ubicacion!, style: const TextStyle(fontSize: 13.2, color: DashColors.textMuted)),
                                    EquipoChip(text: partido.equipo, tone: EquipoChipTone.azul),
                                    EquipoChip(text: jugTxt, tone: EquipoChipTone.gris),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!narrow) ...[
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${partido.puntosEquipo}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: DashColors.text1, height: 1.1),
                                ),
                                const Text(
                                  'PUNTOS',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.9, color: DashColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío cuando no hay partidos registrados (o para el equipo filtrado).
class PartidosEmptyState extends StatelessWidget {
  final bool hasTeams;
  final bool isFiltered;
  final VoidCallback onRegister;

  const PartidosEmptyState({
    super.key,
    required this.hasTeams,
    this.isFiltered = false,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final sub = !hasTeams
        ? 'Primero crea un equipo y añade deportistas.'
        : (isFiltered
            ? 'Este equipo aún no tiene partidos registrados. Registra el primero para ver su récord y estadísticas.'
            : 'Registra el primero para empezar a ver el récord del equipo y el rendimiento de cada jugador.');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 52),
      decoration: BoxDecoration(
        color: DashColors.coachCard2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, size: 32, color: DashColors.accent2),
          const SizedBox(height: 10),
          const Text(
            'Aún no hay partidos registrados',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w700, color: DashColors.text1),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.8, color: DashColors.textMuted, height: 1.45),
            ),
          ),
          if (hasTeams) ...[
            const SizedBox(height: 16),
            EquipoPrimButton(label: 'Registrar partido', onTap: onRegister),
          ],
        ],
      ),
    );
  }
}
