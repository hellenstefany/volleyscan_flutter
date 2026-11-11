import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Actividad reciente" (`Reciente` en `MiProgreso.jsx`).
class ActividadRecienteCard extends StatelessWidget {
  final List<ProgresoEventoReciente> eventos;

  const ActividadRecienteCard({super.key, required this.eventos});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProgresoCardHeader(title: 'Actividad reciente'),
          const SizedBox(height: AppSpacing.dashGap),
          if (eventos.isEmpty)
            const ProgresoEmptyBox(
              title: 'Todavía no hay actividad',
              subtitle:
                  'Tus análisis y ejercicios completados aparecerán aquí.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < eventos.length; i++) ...[
                  if (i > 0) Divider(height: 18, color: DashColors.border),
                  _EventoRow(evento: eventos[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _EventoRow extends StatelessWidget {
  final ProgresoEventoReciente evento;

  const _EventoRow({required this.evento});

  @override
  Widget build(BuildContext context) {
    final isAnalisis = evento.tipo == 'analisis';

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isAnalisis
                ? DashColors.blueLight.withValues(alpha: 0.16)
                : DashColors.green.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(
            isAnalisis ? Icons.gps_fixed_rounded : Icons.fitness_center_rounded,
            size: 16,
            color: isAnalisis
                ? DashColors.infoBadgeText
                : DashColors.successBadgeText,
          ),
        ),
        const SizedBox(width: AppSpacing.dashCardGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashColors.text1,
                ),
              ),
              if (evento.detalle != null && evento.detalle!.trim().isNotEmpty)
                Text(
                  evento.detalle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: DashColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatHaceCuanto(evento.creadoEn),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: DashColors.textMuted,
          ),
        ),
      ],
    );
  }
}
