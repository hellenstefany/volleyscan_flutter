import 'package:flutter/material.dart';
import '../../models/routine_data.dart';
import '../../theme/routine_colors.dart';

class RoutineExerciseTile extends StatelessWidget {
  final int number;
  final RoutineExercise exercise;
  final VoidCallback onStart;

  const RoutineExerciseTile({
    super.key,
    required this.number,
    required this.exercise,
    required this.onStart,
  });

  static const _accents = [
    RoutineColors.blue,
    RoutineColors.teal,
    RoutineColors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[(number - 1) % _accents.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: exercise.completed
                ? Icon(Icons.check, color: accent, size: 20)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.description,
                  style: const TextStyle(
                    color: RoutineColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: OutlinedButton(
              onPressed: exercise.completed ? null : onStart,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF60A5FA),
                backgroundColor: RoutineColors.blue.withOpacity(0.15),
                side: BorderSide(color: RoutineColors.blue.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(
                exercise.completed ? 'Listo' : 'Comenzar',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
