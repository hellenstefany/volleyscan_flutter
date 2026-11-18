import 'package:flutter/material.dart';
import '../../../models/schedule_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Barra superior con botón del menú lateral y título "Horario".
class ScheduleTopBar extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const ScheduleTopBar({super.key, required this.onOpenDrawer});

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
              'Horario',
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

/// Cabecera de contenido (`.head` en `horario.module.css`).
class SchedulePageHeader extends StatelessWidget {
  const SchedulePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MI AGENDA',
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
            'Horario',
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
            'Entrenamientos, competencias y reuniones de tus equipos y de tu entrenador.',
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

/// Tarjeta destacada "Tu próximo evento" (`.proximo` en `horario.module.css`).
class NextEventBanner extends StatelessWidget {
  final ScheduleEvent event;

  const NextEventBanner({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startDateTime;
    final countdown = start != null ? formatCountdown(start) : null;
    final dayLabel = start != null ? formatScheduleLongDay(start) : event.fecha;
    final whenText =
        '$dayLabel · ${event.horaInicio} – ${event.horaFin}${event.ubicacion != null ? ' · ${event.ubicacion}' : ''}';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashColors.coachPurple.withValues(alpha: 0.22),
            DashColors.cardDark,
          ],
          stops: const [0.0, 0.72],
        ),
        border: Border.all(
          color: DashColors.coachPurple.withValues(alpha: 0.50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TU PRÓXIMO EVENTO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: DashColors.accent2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            event.titulo,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: DashColors.text,
            ),
          ),
          if (countdown != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
              decoration: BoxDecoration(
                color: DashColors.blueLight.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                countdown,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DashColors.accent2,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            whenText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _NextChip(label: event.tipoLabel, isBlue: true),
              if (event.equipo != null) _NextChip(label: event.equipo!.nombre),
              if (event.entrenador.isNotEmpty)
                Text(
                  event.entrenador,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: DashColors.muted,
                  ),
                ),
            ],
          ),
          if (event.notas != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: DashColors.bg.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(AppRadii.panel),
                border: Border.all(color: DashColors.coachBorder),
              ),
              child: Text(
                event.notas!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  height: 1.45,
                  color: DashColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextChip extends StatelessWidget {
  final String label;
  final bool isBlue;

  const _NextChip({required this.label, this.isBlue = false});

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

/// Estado vacío cuando no hay eventos en el mes seleccionado (`.vacio`).
class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(
        color: DashColors.coachBorder,
        radius: 22,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: const Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 38,
              color: DashColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Sin eventos este mes',
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
              'Cuando tu entrenador programe algo, lo verás aquí y te llegará un aviso.',
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

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
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

/// Botón "Reintentar" cuando falla la carga de la agenda.
class ScheduleErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const ScheduleErrorRetry({super.key, required this.onRetry});

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
