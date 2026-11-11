import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'actividad_reciente_card.dart';
import 'actividad_semanal_card.dart';
import 'evolucion_tecnica_card.dart';
import 'logros_card.dart';
import 'por_tecnica_card.dart';
import 'progreso_shared.dart';
import 'tu_entrenador_card.dart';
import 'tu_semana_card.dart';
import 'tus_rutinas_card.dart';

/// Sección completa "Tu progreso" (`MiProgreso.jsx` + `mi-progreso.module.css`).
/// Compone las 8 tarjetas a partir de `ProgresoAtletaResponse` e incluye
/// sus propios estados de carga y error con "Reintentar".
class MiProgresoSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final ProgresoAtletaResponse? datos;
  final VoidCallback onRetry;
  final VoidCallback onOpenRoutines;
  final VoidCallback onStartAnalysis;

  const MiProgresoSection({
    super.key,
    required this.loading,
    required this.error,
    required this.datos,
    required this.onRetry,
    required this.onOpenRoutines,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final generadoEn = datos?.generadoEn;
    final stamp = (!loading && error == null && generadoEn != null)
        ? 'Actualizado ${formatHaceCuanto(generadoEn)}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'TU PROGRESO',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: DashColors.textSecondary,
              ),
            ),
            if (stamp != null && stamp.trim().isNotEmpty)
              Text(
                stamp,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: DashColors.textMuted,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.dashGap),
        if (loading) ...[
          const DashboardSkeletonCard(height: 185),
          const SizedBox(height: AppSpacing.dashGap),
          const DashboardSkeletonCard(height: 165),
          const SizedBox(height: AppSpacing.dashGap),
          const DashboardSkeletonCard(height: 195),
        ] else if (error != null || datos == null) ...[
          DashboardErrorBanner(
            message: 'No se pudo cargar tu progreso.',
            detail: error,
            onRetry: onRetry,
          ),
        ] else ...[
          TuSemanaCard(racha: datos!.racha, semana: datos!.semana),
          const SizedBox(height: AppSpacing.dashGap),
          TusRutinasCard(
            rutinas: datos!.rutinas,
            onOpenRoutines: onOpenRoutines,
          ),
          const SizedBox(height: AppSpacing.dashGap),
          EvolucionTecnicaCard(
            analisis: datos!.analisis,
            onStartAnalysis: onStartAnalysis,
          ),
          const SizedBox(height: AppSpacing.dashGap),
          PorTecnicaCard(porTecnica: datos!.analisis.porTecnica),
          const SizedBox(height: AppSpacing.dashGap),
          ActividadSemanalCard(semanas: datos!.semanas),
          const SizedBox(height: AppSpacing.dashGap),
          TuEntrenadorCard(entrenador: datos!.entrenador),
          const SizedBox(height: AppSpacing.dashGap),
          LogrosCard(logros: datos!.logros),
          const SizedBox(height: AppSpacing.dashGap),
          ActividadRecienteCard(eventos: datos!.reciente),
        ],
      ],
    );
  }
}
