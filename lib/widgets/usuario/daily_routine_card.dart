import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta "Rutina del día": replica `.card1.card--routine` de `Dashboard.css`.
/// Si [hasRoutine] es `false`, muestra `"No tienes rutina asignada para hoy."`
/// y el botón `"Explorar rutinas"`.
class DailyRoutineCard extends StatelessWidget {
  const DailyRoutineCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    this.hasRoutine = true,
    this.onViewRoutine,
  });

  final String title;
  final int completed;
  final int total;
  final bool hasRoutine;
  final VoidCallback? onViewRoutine;

  @override
  Widget build(BuildContext context) {
    final visibleDots = total.clamp(0, 5);

    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: DashColors.border)),
            ),
            child: const Text(
              'Rutina del día',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DashColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (!hasRoutine) ...[
            Text(
              'No tienes rutina asignada para hoy.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                height: 1.4,
                color: DashColors.textSecondary,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: onViewRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashColors.blueLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Explorar rutinas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$completed/$total ejercicios',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                height: 1.25,
                color: DashColors.textSecondary,
              ),
            ),
            if (visibleDots > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < visibleDots; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(child: _ExerciseDot(done: i < completed)),
                  ],
                ],
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: onViewRoutine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashColors.blueLight,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ver rutina',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseDot extends StatelessWidget {
  const _ExerciseDot({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DashColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashColors.border),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? DashColors.green : Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}
