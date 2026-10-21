import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

class RoutineProgressCard extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int completed;
  final int total;
  final VoidCallback onViewFull;

  const RoutineProgressCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
    required this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'PROGRESO DE LA\nRUTINA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 9,
                    backgroundColor: RoutineColors.trackGrey,
                    valueColor: const AlwaysStoppedAnimation(
                      RoutineColors.blue,
                    ),
                  ),
                ),
                Text(
                  '$percent %',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$completed de $total ejercicios completados',
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onViewFull,
              icon: const Icon(Icons.checklist, size: 20),
              label: const Text(
                'Ver rutina completa',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
