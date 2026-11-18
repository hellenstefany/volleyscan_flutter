import 'package:flutter/material.dart';
import '../../../models/schedule_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Grupo de un día con columna izquierda de fecha y tarjetas de eventos (`.dia`).
class ScheduleDayGroup extends StatelessWidget {
  final String isoDate;
  final List<ScheduleEvent> events;
  final bool isToday;

  const ScheduleDayGroup({
    super.key,
    required this.isoDate,
    required this.events,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = events.isNotEmpty ? events.first.dateOnly : null;
    final dayNum = parsed != null ? '${parsed.day}' : isoDate.split('-').last;
    final weekday =
        parsed != null ? formatScheduleShortWeekday(parsed).toUpperCase() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                children: [
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: isToday ? DashColors.accent2 : DashColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    weekday,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      letterSpacing: 1.0,
                      color: DashColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: events
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ScheduleEventCard(event: e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleEventCard extends StatelessWidget {
  final ScheduleEvent event;

  const _ScheduleEventCard({required this.event});

  Color _accentForType(String tipo) {
    switch (tipo) {
      case 'partido':
        return DashColors.red;
      case 'evaluacion':
        return DashColors.amber;
      case 'reunion':
        return DashColors.greenTeal;
      case 'otro':
        return DashColors.coachPurple;
      case 'entrenamiento':
      default:
        return DashColors.blueLight;
    }
  }

  Color _attendanceColor(String? estado) {
    switch (estado) {
      case 'presente':
        return DashColors.greenTeal;
      case 'tarde':
        return DashColors.amber;
      case 'ausente':
        return DashColors.deltaDown;
      case 'justificado':
      default:
        return DashColors.accent2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cancelado = event.isCancelled;
    final accent = _accentForType(event.tipo);
    final asistenciaLabel = event.asistenciaLabel;

    return Opacity(
      opacity: cancelado ? 0.55 : 1.0,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: AppGradients.coachCardBg,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: DashColors.coachBorder),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _EventChip(
                            label: event.tipoLabel,
                            bg: DashColors.blueLight.withValues(alpha: 0.16),
                            fg: DashColors.accent2,
                          ),
                          if (cancelado)
                            _EventChip(
                              label: 'Cancelado',
                              bg: DashColors.deltaDown.withValues(alpha: 0.16),
                              fg: DashColors.deltaDown,
                            ),
                          if (event.isCompleted)
                            _EventChip(
                              label: 'Realizado',
                              bg: DashColors.greenTeal.withValues(alpha: 0.14),
                              fg: DashColors.greenTeal,
                            ),
                          if (event.equipo != null)
                            _EventChip(
                              label: event.equipo!.nombre,
                              bg: DashColors.muted.withValues(alpha: 0.14),
                              fg: DashColors.textSecondary,
                            ),
                          if (asistenciaLabel != null)
                            _EventChip(
                              label: asistenciaLabel,
                              bg: _attendanceColor(event.miAsistencia)
                                  .withValues(alpha: 0.16),
                              fg: _attendanceColor(event.miAsistencia),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.titulo,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: DashColors.text,
                          decoration:
                              cancelado ? TextDecoration.lineThrough : null,
                          decorationColor: DashColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${event.horaInicio} – ${event.horaFin}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DashColors.textSecondary,
                            ),
                          ),
                          if (event.ubicacion != null)
                            Text(
                              '· ${event.ubicacion}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: DashColors.muted,
                              ),
                            ),
                          if (event.entrenador.isNotEmpty)
                            Text(
                              '· ${event.entrenador}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: DashColors.muted,
                              ),
                            ),
                        ],
                      ),
                      if (event.notas != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: DashColors.muted.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(AppRadii.btn),
                          ),
                          child: Text(
                            event.notas!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              height: 1.4,
                              color: DashColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                      if (event.miObservacion != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: DashColors.purple.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadii.btn),
                            border: Border.all(
                              color: DashColors.purple.withValues(alpha: 0.30),
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
                                  letterSpacing: 1.0,
                                  color: DashColors.purple,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                event.miObservacion!,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  height: 1.4,
                                  color: DashColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _EventChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _EventChip({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
