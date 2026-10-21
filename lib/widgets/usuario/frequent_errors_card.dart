import 'package:flutter/material.dart';
import '../../models/progress_data.dart';
import '../../theme/routine_colors.dart';

class FrequentErrorsCard extends StatelessWidget {
  final List<FrequentError> errors;
  const FrequentErrorsCard({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ERRORES MÁS FRECUENTES',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < errors.length; i++)
            _ErrorRow(index: i + 1, error: errors[i]),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final int index;
  final FrequentError error;
  const _ErrorRow({required this.index, required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RoutineColors.trackGrey,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: RoutineColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: error.percent / 100,
                    minHeight: 5,
                    backgroundColor: RoutineColors.trackGrey,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFF87171)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${error.percent}%',
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
