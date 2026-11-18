import 'package:flutter/material.dart';
import '../../../models/routine_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Panel de ejercicios con botones "Marcar hecho" / "Deshacer" (`.panel` + `.list`).
class RoutineExercisesPanel extends StatelessWidget {
  final List<RoutineExerciseItem> exercises;
  final RoutineProgress progress;
  final int? savingExerciseId;
  final int? nextExerciseId;
  final GlobalKey? nextExerciseKey;
  final void Function(RoutineExerciseItem exercise, bool completado) onToggle;

  const RoutineExercisesPanel({
    super.key,
    required this.exercises,
    required this.progress,
    required this.savingExerciseId,
    required this.nextExerciseId,
    this.nextExerciseKey,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EJERCICIOS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: DashColors.muted,
                ),
              ),
              Text(
                '${progress.completados} de ${progress.total} completados',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: DashColors.text3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (exercises.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: DashColors.border2),
              ),
              child: const Text(
                'Esta rutina todavía no tiene ejercicios.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  color: DashColors.muted,
                ),
              ),
            )
          else
            ...exercises.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isNext = !item.completado && item.id == nextExerciseId;
              return _ExerciseRowCard(
                key: isNext ? nextExerciseKey : ValueKey(item.id),
                index: idx + 1,
                exercise: item,
                isNext: isNext,
                isBusyAny: savingExerciseId != null,
                isSavingThis: savingExerciseId == item.id,
                onToggle: (completado) => onToggle(item, completado),
              );
            }),
        ],
      ),
    );
  }
}

class _ExerciseRowCard extends StatelessWidget {
  final int index;
  final RoutineExerciseItem exercise;
  final bool isNext;
  final bool isBusyAny;
  final bool isSavingThis;
  final ValueChanged<bool> onToggle;

  const _ExerciseRowCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.isNext,
    required this.isBusyAny,
    required this.isSavingThis,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final done = exercise.completado;

    Color borderColor = DashColors.border;
    Color bgColor = DashColors.card2;
    if (done) {
      borderColor = DashColors.green.withValues(alpha: 0.28);
      bgColor = DashColors.green.withValues(alpha: 0.05);
    } else if (isNext) {
      borderColor = DashColors.blueLight.withValues(alpha: 0.60);
      bgColor = DashColors.blueLight.withValues(alpha: 0.12);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? DashColors.green
                      : DashColors.blueLight.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: DashColors.checkIconDark,
                      )
                    : Text(
                        '$index',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: DashColors.infoBadgeText,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nombre,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: done ? DashColors.muted : DashColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DoseChip(
                          bold: '${exercise.series}',
                          rest: ' series',
                        ),
                        _DoseChip(
                          bold: '${exercise.repeticiones}',
                          rest: ' repeticiones',
                        ),
                        if (isNext)
                          const Text(
                            'SIGUIENTE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: DashColors.infoBadgeText,
                            ),
                          ),
                        if (done)
                          const Text(
                            '✔ Hecho',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: DashColors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: done
                ? OutlinedButton.icon(
                    onPressed: isBusyAny ? null : () => onToggle(false),
                    icon: const Icon(Icons.undo_rounded, size: 16),
                    label: Text(
                      isSavingThis ? 'Guardando…' : 'Deshacer',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DashColors.muted,
                      side: const BorderSide(color: DashColors.border2),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: isBusyAny ? null : () => onToggle(true),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: Text(
                      isSavingThis ? 'Guardando…' : 'Marcar hecho',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DashColors.blueLight,
                      disabledBackgroundColor:
                          DashColors.blueLight.withValues(alpha: 0.55),
                      foregroundColor: DashColors.textPrimary,
                      disabledForegroundColor: DashColors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoseChip extends StatelessWidget {
  final String bold;
  final String rest;

  const _DoseChip({required this.bold, required this.rest});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DashColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: DashColors.muted,
          ),
          children: [
            TextSpan(
              text: bold,
              style: const TextStyle(color: DashColors.text),
            ),
            TextSpan(text: rest),
          ],
        ),
      ),
    );
  }
}
