import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';

class AnalisisSender extends StatelessWidget {
  final bool coach;

  const AnalisisSender({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            coach ? 'VolleyAI Coach' : 'Tú',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashColors.textSecondary,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DashColors.teal.withValues(alpha: 0.16),
                    DashColors.sky.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: DashColors.teal.withValues(alpha: 0.32),
                ),
              ),
              child: const Text(
                'IA',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9.6,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: DashColors.badgePrepText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
