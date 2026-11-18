import 'package:flutter/material.dart';

import 'analisis_action_btn.dart';
import 'analisis_markdown_text.dart';
import 'analisis_models.dart';
import 'analisis_theme.dart';

class AnalisisMessageBubble extends StatelessWidget {
  final ChatMsg mensaje;
  final double bubbleMax;
  final bool esUltimoCoach;
  final bool escribiendo;
  final bool copiado;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;

  const AnalisisMessageBubble({
    super.key,
    required this.mensaje,
    required this.bubbleMax,
    required this.esUltimoCoach,
    required this.escribiendo,
    required this.copiado,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final m = mensaje;
    final coach = m.coach;

    // En `Analisis.css`:
    // `.ai-message--coach .ai-bubble-column { max-width: 100%; }`
    // `.ai-message-- coach .ai-bubble { padding: 6px 8px; color: var(--ai-text); }`
    // `.ai-message--user .ai-bubble { background: var(--ai-gradient); color: #ffffff; border-radius: 16px 4px 16px 16px; ... }`
    final bubble = coach
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: AnalisisMarkdownText(m.texto),
            ),
          )
        : Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: AnalisisTheme.aiGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AnalisisTheme.radiusBubble),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(AnalisisTheme.radiusBubble),
                bottomRight: Radius.circular(AnalisisTheme.radiusBubble),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              m.texto,
              style: const TextStyle(
                fontSize: 14.9,
                height: 1.65,
                color: Colors.white,
              ),
            ),
          );

    final footer = Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            m.hora,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.6,
              letterSpacing: 0.3,
              color: AnalisisTheme.text3,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AnalisisTheme.bg.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AnalisisTheme.lineStrong),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnalisisActionBtn(
                    icon: copiado ? Icons.check_rounded : Icons.copy_rounded,
                    confirmed: copiado,
                    tooltip: 'Copiar',
                    onTap: onCopy,
                  ),
                  if (esUltimoCoach && !escribiendo) ...[
                    const SizedBox(width: 2),
                    AnalisisActionBtn(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Regenerar',
                      onTap: onRegenerate,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          coach ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment:
                coach ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              bubble,
              footer,
            ],
          ),
        ),
      ],
    );
  }
}
