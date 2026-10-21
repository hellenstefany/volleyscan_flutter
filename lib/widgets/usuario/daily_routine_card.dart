import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta "Rutina del día" con el avance de ejercicios y botón "Ver rutina".
class DailyRoutineCard extends StatelessWidget {
  const DailyRoutineCard({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    this.onViewRoutine,
  });

  final String title;
  final int completed;
  final int total;
  final VoidCallback? onViewRoutine;

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rutina del día',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              height: 1.3,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            '$completed/$total ejercicios',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              height: 1.3,
              color: DashColors.muted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _ExerciseDot(done: i < completed)),
              ],
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton(
              onPressed: onViewRoutine,
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blue,
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
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? DashColors.green : Colors.white.withOpacity(0.15),
        ),
      ),
    );
  }
}
