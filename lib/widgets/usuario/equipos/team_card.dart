import 'package:flutter/material.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../entrenador/coach_status_widgets.dart';
import '../shared/dash_card.dart';

/// Tarjeta de un equipo del deportista (`.tarjeta` en `equipos.module.css`).
class TeamCard extends StatelessWidget {
  final MyTeam team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: EdgeInsets.zero,
      backgroundColor: DashColors.cardDark,
      borderRadius: 22,
      borderColor: DashColors.coachBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: AppGradients.coachPrimaryBtn,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.nombre,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: DashColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (team.categoria != null)
                      _TeamChip(label: team.categoria!, isBlue: true),
                    if (team.temporada != null)
                      _TeamChip(label: team.temporada!),
                    _TeamChip(label: '${team.integrantes} integrantes'),
                  ],
                ),
                const SizedBox(height: 16),
                _PlayerRoleBox(team: team),
                if (team.entrenadores.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    team.entrenadores.length > 1
                        ? 'ENTRENADORES'
                        : 'ENTRENADOR',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: DashColors.text3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...team.entrenadores.map(
                    (coach) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TeamCoachRow(teamCoach: coach),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  final String label;
  final bool isBlue;

  const _TeamChip({required this.label, this.isBlue = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isBlue
            ? DashColors.blueLight.withValues(alpha: 0.16)
            : DashColors.muted.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isBlue ? DashColors.accent2 : DashColors.textSecondary,
        ),
      ),
    );
  }
}

class _PlayerRoleBox extends StatelessWidget {
  final MyTeam team;

  const _PlayerRoleBox({required this.team});

  @override
  Widget build(BuildContext context) {
    final hasNumber = team.numeroCamiseta != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DashColors.muted.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadii.panel),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.panel),
              color: hasNumber ? null : DashColors.card,
              gradient: hasNumber ? AppGradients.coachPrimaryBtn : null,
            ),
            child: Text(
              hasNumber ? '${team.numeroCamiseta}' : '—',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: hasNumber ? DashColors.textPrimary : DashColors.text3,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.posicion ?? 'Sin posición asignada',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: DashColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Desde ${formatTeamShortDate(team.desde)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCoachRow extends StatelessWidget {
  final TeamCoach teamCoach;

  const _TeamCoachRow({required this.teamCoach});

  @override
  Widget build(BuildContext context) {
    final person = teamCoach.coach;
    return Row(
      children: [
        CoachSquareAvatar(person: person, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            person.fullName.isNotEmpty ? person.fullName : 'Entrenador',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: DashColors.textSecondary,
            ),
          ),
        ),
        if (teamCoach.esPropietario) ...[
          const SizedBox(width: 8),
          const _TeamChip(label: 'Principal', isBlue: true),
        ],
      ],
    );
  }
}
