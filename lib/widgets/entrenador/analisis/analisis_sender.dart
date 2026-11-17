import 'package:flutter/material.dart';

import 'analisis_theme.dart';

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
              color: AnalisisTheme.textSecondary,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AnalisisTheme.accent.withOpacity(0.13),
                    AnalisisTheme.blue.withOpacity(0.07),
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AnalisisTheme.accent.withOpacity(0.27),
                ),
              ),
              child: Text(
                'IA',
                style: AnalisisTheme.mono.copyWith(
                  fontSize: 9.6,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFFB9A4FF),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
