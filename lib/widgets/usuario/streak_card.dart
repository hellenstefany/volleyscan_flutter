import 'package:flutter/material.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

/// Tarjeta "Racha actual".
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DashCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF3A2315),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DashColors.orange.withOpacity(0.4)),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 24,
                color: DashColors.orange,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RACHA ACTUAL',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: DashColors.muted,
                  ),
                ),
                Text(
                  '$days ${days == 1 ? 'día' : 'días'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '¡Sigue así!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
