import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Barra superior con botón del menú lateral y título de "Mis equipos".
class TeamsTopBar extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const TeamsTopBar({super.key, required this.onOpenDrawer});

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
              'Mis equipos',
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

/// Cabecera de contenido (`.head` en `equipos.module.css`).
class TeamsPageHeader extends StatelessWidget {
  const TeamsPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MI CLUB',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: DashColors.accent2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mis equipos',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: DashColors.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Los equipos a los que te invitaron tus entrenadores. Puedes estar en varios a la vez.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.45,
              color: DashColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner verde de confirmación (`.alerta.alertaBien` en `equipos.module.css`).
class TeamsSuccessBanner extends StatelessWidget {
  final String message;

  const TeamsSuccessBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DashColors.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(
          color: DashColors.green.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          height: 1.45,
          color: DashColors.successBadgeText,
        ),
      ),
    );
  }
}

/// Estado vacío cuando el atleta aún no pertenece a ningún equipo (`.vacio`).
class TeamsEmptyState extends StatelessWidget {
  const TeamsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: DashColors.coachBorder,
        radius: 22,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
        child: const Column(
          children: [
            Icon(
              Icons.groups_outlined,
              size: 40,
              color: DashColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Aún no estás en ningún equipo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DashColors.text,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Cuando un entrenador te invite por correo, la invitación aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                height: 1.45,
                color: DashColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 5.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Botón "Reintentar" para el estado de error.
class TeamsErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const TeamsErrorRetry({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text(
        'Reintentar',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: DashColors.cardDark,
        foregroundColor: DashColors.textSecondary,
        side: const BorderSide(color: DashColors.coachBorder),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.btn),
        ),
      ),
    );
  }
}
