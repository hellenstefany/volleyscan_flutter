import 'package:flutter/material.dart';

import 'analisis_avatar.dart';
import 'analisis_sender.dart';
import 'analisis_theme.dart';
import 'analisis_thinking_bar.dart';

/// Burbuja "ANALIZANDO" que se muestra mientras la IA responde.
class AnalisisThinking extends StatelessWidget {
  const AnalisisThinking({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnalisisAvatar(coach: true),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnalisisSender(coach: true),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: AnalisisTheme.surfaceGradient,
                border: Border.all(color: AnalisisTheme.line),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ANALIZANDO',
                    style: AnalisisTheme.mono.copyWith(
                      fontSize: 11.5,
                      letterSpacing: 0.6,
                      color: AnalisisTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const AnalisisThinkingBar(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
