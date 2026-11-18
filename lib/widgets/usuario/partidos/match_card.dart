import 'package:flutter/material.dart';
import '../../../models/my_matches_data.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta de un partido jugado con marcador, cifras personales y observación (`.partido`).
class MatchCard extends StatelessWidget {
  final AthleteMatch match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final victoria = match.isVictory;
    final barColor = victoria ? DashColors.green : DashColors.orange;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: barColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MatchHeaderRow(match: match),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: DashColors.coachBorder),
                    const SizedBox(height: 14),
                    _MatchStatsGrid(stats: match.misCifras),
                    if (match.miObservacion != null) ...[
                      const SizedBox(height: 14),
                      _CoachObservationBox(text: match.miObservacion!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchHeaderRow extends StatelessWidget {
  final AthleteMatch match;

  const _MatchHeaderRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final victoria = match.isVictory;
    final boxTint = victoria
        ? DashColors.green.withValues(alpha: 0.12)
        : DashColors.orange.withValues(alpha: 0.12);
    final boxBorder = victoria
        ? DashColors.green.withValues(alpha: 0.30)
        : DashColors.orange.withValues(alpha: 0.30);
    final scoreColor =
        victoria ? DashColors.badgeRecepcionText : DashColors.warningText;
    final labelColor =
        victoria ? DashColors.successBadgeText : DashColors.warningText;

    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 74),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: boxTint,
            borderRadius: BorderRadius.circular(AppRadii.panel),
            border: Border.all(color: boxBorder),
          ),
          child: Column(
            children: [
              Text(
                '${match.setsGanados}–${match.setsPerdidos}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                victoria ? 'VICTORIA' : 'DERROTA',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'vs ${match.rival}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    formatTeamShortDate(match.fecha),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
                      color: DashColors.muted,
                    ),
                  ),
                  if (match.ubicacion != null)
                    Text(
                      match.ubicacion!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: DashColors.muted,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DashColors.blueLight.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      match.equipo,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: DashColors.accent2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchStatsGrid extends StatelessWidget {
  final MatchStats stats;

  const _MatchStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = <_StatCell>[
      _StatCell(
        value: '${stats.puntosTotales}',
        label: 'PUNTOS',
        color: DashColors.badgeRecepcionText,
      ),
      _StatCell(
        value: '${stats.ataquesExitosos}/${stats.ataquesFallidos}',
        label: 'ATAQUE +/−',
      ),
      _StatCell(
        value: formatPercentOrDash(stats.efectividadAtaque),
        label: '% ATAQUE',
        color: DashColors.accent2,
      ),
      _StatCell(value: '${stats.bloqueos}', label: 'BLOQUEOS'),
      _StatCell(value: '${stats.saquesExitosos}', label: 'ACES'),
      _StatCell(
        value: '${stats.recepcionesExitosas}/${stats.recepcionesFalladas}',
        label: 'RECEP. +/−',
      ),
      _StatCell(
        value: formatPercentOrDash(stats.efectividadRecepcion),
        label: '% RECEP.',
        color: DashColors.accent2,
      ),
      _StatCell(value: '${stats.erroresNoForzados}', label: 'ERRORES'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 640 ? 4 : 2;
        const spacing = 12.0;
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.value,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          color: item.color ?? DashColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: DashColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCell {
  final String value;
  final String label;
  final Color? color;

  const _StatCell({required this.value, required this.label, this.color});
}

class _CoachObservationBox extends StatelessWidget {
  final String text;

  const _CoachObservationBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DashColors.blueLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(
          color: DashColors.blueLight.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OBSERVACIÓN DE TU ENTRENADOR',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: DashColors.infoBadgeText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.45,
              color: DashColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
