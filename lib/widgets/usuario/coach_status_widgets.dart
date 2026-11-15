import 'package:flutter/material.dart';
import '../../models/coach_link_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Cabecera superior y título de la pantalla "Mi entrenador".
class CoachScreenHeader extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const CoachScreenHeader({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onOpenDrawer,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DashColors.card,
                borderRadius: BorderRadius.circular(AppRadii.panel),
                border: Border.all(color: DashColors.border),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 22,
                color: DashColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Mi entrenador',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar cuadrado redondeado (`border-radius: 20px`) de `MiEntrenadorPage` (`Avatar` en `page.jsx`).
class CoachSquareAvatar extends StatefulWidget {
  final CoachPerson person;
  final double size;

  const CoachSquareAvatar({
    super.key,
    required this.person,
    this.size = 56,
  });

  @override
  State<CoachSquareAvatar> createState() => _CoachSquareAvatarState();
}

class _CoachSquareAvatarState extends State<CoachSquareAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant CoachSquareAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.person.fotoUrl != widget.person.fotoUrl) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiService.resolveMediaUrl(widget.person.fotoUrl);
    final radius = BorderRadius.circular(20);

    if (resolvedUrl != null && resolvedUrl.isNotEmpty && !_imageFailed) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          width: widget.size,
          height: widget.size,
          color: DashColors.card,
          child: Image.network(
            resolvedUrl,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_imageFailed) {
                  setState(() => _imageFailed = true);
                }
              });
              return _buildInitials();
            },
          ),
        ),
      );
    }

    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppGradients.coachPrimaryBtn,
      ),
      child: Text(
        widget.person.initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: widget.size * 0.36,
          fontWeight: FontWeight.w800,
          color: DashColors.textPrimary,
        ),
      ),
    );
  }
}

/// Banner de alerta naranja (`.alerta` en `entrenador.module.css`).
class CoachAlertBanner extends StatelessWidget {
  final String message;

  const CoachAlertBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DashColors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(
          color: DashColors.orange.withValues(alpha: 0.40),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          height: 1.45,
          color: DashColors.warningText,
        ),
      ),
    );
  }
}

/// Tarjeta de vínculo activo o solicitud pendiente (`.estadoCard.ok` / `.estadoCard.espera`).
class CoachBondStatusCard extends StatelessWidget {
  final CoachBond vinculo;
  final bool busy;
  final VoidCallback onActionPressed;

  const CoachBondStatusCard({
    super.key,
    required this.vinculo,
    required this.busy,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final v = vinculo;
    final accepted = v.isAccepted;
    final accent = accepted ? DashColors.green : DashColors.orange;
    final bgTint = accepted
        ? DashColors.green.withValues(alpha: 0.12)
        : DashColors.orange.withValues(alpha: 0.10);

    final subtitle = accepted
        ? 'Entrenan juntos desde el ${formatCoachLongDate(v.respondidoEn)}.'
        : 'La enviaste el ${formatCoachLongDate(v.solicitadoEn)}. Esperando que ${v.entrenador.nombre} la acepte.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgTint, DashColors.cardDark],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CoachSquareAvatar(person: v.entrenador, size: 72),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accepted ? 'TU ENTRENADOR' : 'SOLICITUD ENVIADA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  v.entrenador.fullName.isNotEmpty
                      ? v.entrenador.fullName
                      : 'Entrenador',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DashColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    height: 1.45,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: busy ? null : onActionPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: DashColors.cardDark,
              foregroundColor: DashColors.textSecondary,
              disabledForegroundColor:
                  DashColors.textSecondary.withValues(alpha: 0.5),
              side: const BorderSide(color: DashColors.coachBorder),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.btn),
              ),
            ),
            child: Text(
              busy
                  ? 'Procesando…'
                  : (accepted ? 'Cambiar de entrenador' : 'Cancelar solicitud'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
