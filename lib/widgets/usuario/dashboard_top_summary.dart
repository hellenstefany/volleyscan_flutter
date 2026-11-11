import 'package:flutter/material.dart';
import '../../models/dashboard_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'daily_routine_card.dart';
import 'last_analysis_card.dart';
import 'progreso/progreso_shared.dart';
import 'sparkline.dart';
import 'stat_card.dart';
import 'streak_card.dart';

/// Bloque superior del Dashboard (`/api/usuario/dashboard/`):
/// - Estadísticas principales (`Progreso general` con `Sparkline`, `Sesiones completadas`)
/// - `StreakCard` (`Racha actual`)
/// - Fila con `LastAnalysisCard` y `DailyRoutineCard`
/// Incluye sus estados de carga, error con "Reintentar" y vacío sin inventar datos.
class DashboardTopSummary extends StatelessWidget {
  final bool loading;
  final String? error;
  final DashboardResponse? data;
  final int? progresoRachaActual;
  final VoidCallback onRetry;
  final VoidCallback onOpenAnalysis;
  final VoidCallback onOpenAiHistory;
  final VoidCallback onOpenRoutines;

  const DashboardTopSummary({
    super.key,
    required this.loading,
    required this.error,
    required this.data,
    required this.progresoRachaActual,
    required this.onRetry,
    required this.onOpenAnalysis,
    required this.onOpenAiHistory,
    required this.onOpenRoutines,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Column(
        children: [
          SizedBox(
            height: 156,
            child: Row(
              children: [
                Expanded(child: DashboardSkeletonCard(height: 156)),
                SizedBox(width: AppSpacing.dashCardGap),
                Expanded(child: DashboardSkeletonCard(height: 156)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.dashCardGap),
          DashboardSkeletonCard(height: 82),
          SizedBox(height: AppSpacing.dashGap),
          SizedBox(
            height: 168,
            child: Row(
              children: [
                Expanded(child: DashboardSkeletonCard(height: 168)),
                SizedBox(width: AppSpacing.dashCardGap),
                Expanded(child: DashboardSkeletonCard(height: 168)),
              ],
            ),
          ),
        ],
      );
    }

    if (error != null || data == null) {
      return DashboardErrorBanner(
        message: 'No se pudo cargar el dashboard.',
        detail: error,
        onRetry: onRetry,
      );
    }

    final d = data!;
    final prog = d.progreso;
    final ses = d.sesiones;

    // Progreso general: valor y variación reales (sin inventar si vienen null)
    final progValorStr = prog.valor != null ? '${prog.valor}%' : '—%';
    final progVar = prog.variacion;
    final String? progDeltaStr = (progVar != null && progVar != 0)
        ? '${progVar.abs()}%'
        : null;
    final bool progDeltaPos = (progVar ?? 0) > 0;

    // Sesiones completadas esta semana
    final sesSemana = ses.semana ?? 0;
    final sesVar = ses.variacion;
    final String? sesDeltaStr = (sesVar != null && sesVar != 0)
        ? '${sesVar.abs()}'
        : null;
    final bool sesDeltaPos = (sesVar ?? 0) > 0;

    // Racha actual: igual que en Next (`progresoReal.datos?.racha?.actual ?? racha_dias ?? 0`)
    final rachaDias = progresoRachaActual ?? d.rachaDias ?? 0;

    final ultimo = d.ultimoAnalisis;
    final rutina = d.rutinaDelDia;

    return Column(
      children: [
        SizedBox(
          height: 156,
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: DashColors.blueLight,
                  iconBg: DashColors.blueGlow,
                  label: 'Progreso general',
                  value: progValorStr,
                  delta: progDeltaStr,
                  deltaPositive: progDeltaPos,
                  caption: 'vs. semana pasada',
                  chart: prog.tendencia.length >= 2
                      ? Sparkline(values: prog.tendencia)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.dashCardGap),
              Expanded(
                child: StatCard(
                  icon: Icons.gps_fixed_rounded,
                  iconColor: DashColors.green,
                  iconBg: DashColors.greenGlow,
                  label: 'Sesiones completadas',
                  value: '$sesSemana',
                  delta: sesDeltaStr,
                  deltaPositive: sesDeltaPos,
                  caption: 'esta semana',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.dashCardGap),
        StreakCard(days: rachaDias),
        const SizedBox(height: AppSpacing.dashGap),
        SizedBox(
          height: 174,
          child: Row(
            children: [
              Expanded(
                child: ultimo != null
                    ? LastAnalysisCard(
                        hasData: true,
                        technique: ultimo.tecnica.isNotEmpty
                            ? ultimo.tecnica
                            : 'Análisis',
                        timeAgo: formatHaceCuanto(ultimo.creadoEn),
                        score: ultimo.puntuacion ?? 0,
                        imageUrl: ApiService.resolveMediaUrl(
                          ultimo.miniaturaUrl,
                        ),
                        onTap: onOpenAiHistory,
                      )
                    : LastAnalysisCard(
                        hasData: false,
                        technique: '',
                        timeAgo: '',
                        score: 0,
                        onTap: onOpenAnalysis,
                      ),
              ),
              const SizedBox(width: AppSpacing.dashCardGap),
              Expanded(
                child: rutina != null
                    ? DailyRoutineCard(
                        hasRoutine: true,
                        title: rutina.nombre.isNotEmpty
                            ? rutina.nombre
                            : 'Rutina',
                        completed: rutina.completados ?? 0,
                        total: rutina.totalEjercicios ?? 0,
                        onViewRoutine: onOpenRoutines,
                      )
                    : DailyRoutineCard(
                        hasRoutine: false,
                        title: '',
                        completed: 0,
                        total: 0,
                        onViewRoutine: onOpenRoutines,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
