import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Actividad por semana" (`Semanas` en `MiProgreso.jsx`).
class ActividadSemanalCard extends StatelessWidget {
  final List<ProgresoSemanaItem> semanas;

  const ActividadSemanalCard({super.key, required this.semanas});

  @override
  Widget build(BuildContext context) {
    var total = 0;
    var maxVal = 1;
    for (final w in semanas) {
      final sum = w.sesiones + w.ejercicios;
      total += sum;
      if (sum > maxVal) maxVal = sum;
    }

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actividad por semana',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text1,
                ),
              ),
              const Row(
                children: [
                  _LegendDot(color: DashColors.blueLight, text: 'Ejercicios'),
                  SizedBox(width: 10),
                  _LegendDot(color: DashColors.teal, text: 'Análisis'),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.dashGap),
          if (total == 0)
            const ProgresoEmptyBox(
              title: 'Sin actividad en las últimas 8 semanas',
              subtitle:
                  'Cada ejercicio que marques y cada análisis suma aquí.',
            )
          else
            SizedBox(
              height: 145,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < semanas.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _SemanaBarColumn(
                        item: semanas[i],
                        maxVal: maxVal,
                        isCurrent: i == semanas.length - 1,
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: DashColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SemanaBarColumn extends StatelessWidget {
  final ProgresoSemanaItem item;
  final int maxVal;
  final bool isCurrent;

  const _SemanaBarColumn({
    required this.item,
    required this.maxVal,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final ses = item.sesiones;
    final ej = item.ejercicios;
    final n = ses + ej;
    const barMaxH = 95.0;
    final totalH = n == 0 ? 4.0 : ((n / maxVal) * barMaxH).clamp(8.0, barMaxH);
    final ejH = n == 0 ? 0.0 : totalH * (ej / n);
    final sesH = n == 0 ? 0.0 : totalH * (ses / n);
    final label = isCurrent ? 'Esta' : formatFechaNumerica(item.semana);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          n > 0 ? '$n' : '',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            color: DashColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: totalH,
            color: Colors.white.withValues(alpha: 0.05),
            child: n == 0
                ? null
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (sesH > 0)
                        Container(
                          height: sesH,
                          width: double.infinity,
                          color: DashColors.teal,
                        ),
                      if (ejH > 0)
                        Container(
                          height: ejH,
                          width: double.infinity,
                          color: DashColors.blueLight,
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            color: isCurrent ? Colors.white : DashColors.textMuted,
          ),
        ),
      ],
    );
  }
}
