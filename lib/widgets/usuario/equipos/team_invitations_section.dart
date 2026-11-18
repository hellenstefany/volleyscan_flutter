import 'package:flutter/material.dart';
import '../../../models/my_teams_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Sección "Invitaciones pendientes" (`.bloque` + `.recibidas` en `equipos.module.css`).
class TeamInvitationsSection extends StatelessWidget {
  final List<TeamInvitation> invitations;
  final bool busy;
  final void Function(TeamInvitation invitation, String action) onRespond;

  const TeamInvitationsSection({
    super.key,
    required this.invitations,
    required this.busy,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invitaciones pendientes',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ...invitations.map(
            (inv) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TeamInvitationCard(
                invitation: inv,
                busy: busy,
                onAccept: () => onRespond(inv, 'aceptar'),
                onReject: () => onRespond(inv, 'rechazar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamInvitationCard extends StatelessWidget {
  final TeamInvitation invitation;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _TeamInvitationCard({
    required this.invitation,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final extraParts = [
      if (invitation.equipo.categoria != null) invitation.equipo.categoria!,
      if (invitation.equipo.temporada != null) invitation.equipo.temporada!,
    ];
    final extraText = extraParts.isNotEmpty ? ' · ${extraParts.join(' · ')}' : '';
    final subtitle =
        'Te invita ${invitation.invitadoPor}$extraText · vence ${formatTeamShortDate(invitation.venceEn)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.authCard),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashColors.coachPurple.withValues(alpha: 0.16),
            DashColors.cardDark,
          ],
        ),
        border: Border.all(
          color: DashColors.coachPurple.withValues(alpha: 0.50),
        ),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.equipo.nombre,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: DashColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    height: 1.4,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrimaryAcceptButton(
                busy: busy,
                onPressed: onAccept,
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: busy ? null : onReject,
                style: OutlinedButton.styleFrom(
                  backgroundColor: DashColors.cardDark,
                  foregroundColor: DashColors.textSecondary,
                  disabledForegroundColor:
                      DashColors.textSecondary.withValues(alpha: 0.50),
                  side: const BorderSide(color: DashColors.coachBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.btn),
                  ),
                ),
                child: const Text(
                  'Rechazar',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryAcceptButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onPressed;

  const _PrimaryAcceptButton({
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: busy ? 0.55 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.coachPrimaryBtn,
          borderRadius: BorderRadius.circular(AppRadii.btn),
        ),
        child: ElevatedButton(
          onPressed: busy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: DashColors.textPrimary,
            disabledForegroundColor: DashColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.btn),
            ),
          ),
          child: const Text(
            'Aceptar',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
