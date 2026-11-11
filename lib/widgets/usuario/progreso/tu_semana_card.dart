import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Tu semana" (`Semana` en `MiProgreso.jsx`).
class TuSemanaCard extends StatelessWidget {
  final ProgresoRacha racha;
  final List<ProgresoDiaSemana> semana;

  const TuSemanaCard({
    super.key,
    required this.racha,
    required this.semana,
  });

  @override
  Widget build(BuildContext context) {
    final actual = racha.actual;
    final mejor = racha.mejor;
    final activoHoy = racha.activoHoy;

    final mensaje = activoHoy
        ? '¡Hoy ya cuenta! Vuelve mañana para seguir sumando.'
        : (actual > 0
              ? 'Entrena hoy para no perder tu racha.'
              : 'Haz un análisis o un ejercicio hoy y empieza tu racha.');

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProgresoCardHeader(title: 'Tu semana', tag: 'Lunes a domingo'),
          const SizedBox(height: AppSpacing.dashGap),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: actual == 0
                      ? Colors.white.withValues(alpha: 0.06)
                      : DashColors.orange.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.panel),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 24,
                  color: actual == 0 ? DashColors.textMuted : DashColors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.dashGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Poppins'),
                        children: [
                          TextSpan(
                            text: '$actual',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${actual == 1 ? 'día seguido' : 'días seguidos'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DashColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$mensaje Mejor racha: $mejor ${mejor == 1 ? 'día' : 'días'}.',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.4,
                        color: DashColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (semana.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.dashGap),
            Row(
              children: [
                for (var i = 0; i < semana.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(child: _DayCell(day: semana[i])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final ProgresoDiaSemana day;

  const _DayCell({required this.day});

  @override
  Widget build(BuildContext context) {
    final dayNum = extractDayOfMonth(day.fecha);
    Color bgColor = DashColors.surface;
    Color borderColor = DashColors.border;

    if (day.activo) {
      bgColor = DashColors.green.withValues(alpha: 0.08);
      borderColor = DashColors.green.withValues(alpha: 0.4);
    }
    if (day.hoy) {
      borderColor = DashColors.blueLight;
    }

    return Opacity(
      opacity: day.futuro ? 0.45 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadii.btn),
          border: Border.all(color: borderColor, width: day.hoy ? 1.5 : 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day.dia,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: DashColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: (day.activo || day.hoy)
                    ? Colors.white
                    : DashColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: day.activo
                    ? DashColors.green
                    : Colors.white.withValues(alpha: 0.06),
              ),
              alignment: Alignment.center,
              child: day.activo
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: DashColors.checkIconDark,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
