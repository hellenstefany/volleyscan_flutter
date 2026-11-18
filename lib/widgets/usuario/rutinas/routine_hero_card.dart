import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/routine_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Portada de la rutina seleccionada con badges, objetivo y anillo de progreso (`.hero`).
class RoutineHeroCard extends StatelessWidget {
  final RoutineDetail routine;

  const RoutineHeroCard({super.key, required this.routine});

  Color _levelColor(int idx) {
    switch (idx) {
      case 0:
        return DashColors.sky;
      case 1:
        return DashColors.teal;
      case 2:
        return DashColors.green;
      case 3:
      default:
        return DashColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idxNivel = routineLevelIndex(routine.nivel);
    final lvlColor = _levelColor(idxNivel);
    final completa = routine.progreso.isComplete;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completa
              ? [
                  DashColors.green.withValues(alpha: 0.16),
                  DashColors.coachCard2,
                ]
              : [
                  DashColors.card,
                  DashColors.coachCard2,
                ],
        ),
        border: Border.all(
          color: completa
              ? DashColors.green.withValues(alpha: 0.40)
              : DashColors.border2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 600;
          final mainContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _LevelBadge(
                    label: formatRoutineLevelLabel(routine.nivel),
                    color: lvlColor,
                  ),
                  if (!routine.activa)
                    const _LevelBadge(
                      label: 'Inactiva',
                      color: DashColors.muted,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                routine.nombre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: DashColors.textPrimary,
                ),
              ),
              if (routine.descripcion.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  routine.descripcion,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    height: 1.5,
                    color: DashColors.muted,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _GoalBox(objetivo: routine.objetivo),
            ],
          );

          final ring = _ProgressRing(
            percent: routine.progreso.porcentaje,
            complete: completa,
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: ring),
                const SizedBox(height: 18),
                mainContent,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: mainContent),
              const SizedBox(width: 24),
              ring,
            ],
          );
        },
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LevelBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: color,
        ),
      ),
    );
  }
}

class _GoalBox extends StatelessWidget {
  final String objetivo;

  const _GoalBox({required this.objetivo});

  @override
  Widget build(BuildContext context) {
    final hasGoal = objetivo.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DashColors.textPrimary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: DashColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: DashColors.green.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: DashColors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OBJETIVO',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: DashColors.text3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasGoal
                      ? objetivo
                      : 'Tu entrenador no definió un objetivo.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    height: 1.4,
                    color: hasGoal ? DashColors.text : DashColors.text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;
  final bool complete;

  const _ProgressRing({required this.percent, required this.complete});

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100);
    return SizedBox(
      width: 136,
      height: 136,
      child: CustomPaint(
        painter: _RingPainter(
          fraction: clamped / 100.0,
          complete: complete,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$clamped%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  color: DashColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                complete ? 'COMPLETADA' : 'PROGRESO',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  letterSpacing: 0.8,
                  color: DashColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final bool complete;

  const _RingPainter({required this.fraction, required this.complete});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 12) / 2;

    final bgPaint = Paint()
      ..color = DashColors.border
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    if (fraction <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final fgPaint = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (complete) {
      fgPaint.color = DashColors.green;
    } else {
      fgPaint.shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
        colors: [DashColors.blueLight, DashColors.cyan],
      ).createShader(rect);
    }

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.complete != complete;
}

/// Banner verde de celebración cuando todos los ejercicios están completados (`.win`).
class RoutineCompletedBanner extends StatelessWidget {
  final int total;

  const RoutineCompletedBanner({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DashColors.green.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: DashColors.green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: DashColors.yellow,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Rutina completada!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: DashColors.textPrimary,
                  ),
                ),
                Text(
                  'Terminaste los $total ejercicios. Tu entrenador ya puede ver tu avance.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: DashColors.successBadgeText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
