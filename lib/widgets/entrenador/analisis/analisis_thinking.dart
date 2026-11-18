import 'package:flutter/material.dart';

import 'analisis_theme.dart';
import 'analisis_thinking_bar.dart';

/// Burbuja "ANALIZANDO" (`.ai-thinking` en `page.jsx` / `Analisis.css`).
class AnalisisThinking extends StatelessWidget {
  const AnalisisThinking({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AnalisisTheme.surface,
            border: Border.all(color: AnalisisTheme.line),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(AnalisisTheme.radiusBubble),
              bottomLeft: Radius.circular(AnalisisTheme.radiusBubble),
              bottomRight: Radius.circular(AnalisisTheme.radiusBubble),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ANALIZANDO',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  letterSpacing: 0.6,
                  color: AnalisisTheme.text2,
                ),
              ),
              SizedBox(width: 12),
              AnalisisThinkingBar(),
            ],
          ),
        ),
      ],
    );
  }
}
