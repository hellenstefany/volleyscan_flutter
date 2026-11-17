import 'package:flutter/material.dart';

import 'analisis_action_btn.dart';
import 'analisis_avatar.dart';
import 'analisis_markdown_text.dart';
import 'analisis_models.dart';
import 'analisis_sender.dart';
import 'analisis_theme.dart';

class AnalisisMessageBubble extends StatelessWidget {
  final ChatMsg mensaje;
  final double bubbleMax;

  /// true si es el último mensaje del coach (muestra "Regenerar").
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

    final bubble = coach
        ? Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            decoration: BoxDecoration(
              gradient: AnalisisTheme.surfaceGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AnalisisTheme.line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 15, 20, 15),
                  child: AnalisisMarkdownText(m.texto),
                ),
                Positioned(
                  left: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: AnalisisTheme.aiGradient,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AnalisisTheme.accent.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            constraints: BoxConstraints(maxWidth: bubbleMax),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              gradient: AnalisisTheme.aiGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: AnalisisTheme.accent.withOpacity(0.25),
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
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            m.hora,
            style: AnalisisTheme.mono.copyWith(
              fontSize: 10.5,
              letterSpacing: 0.3,
              color: AnalisisTheme.textMuted,
            ),
          ),
          if (coach) ...[
            const SizedBox(width: 10),
            AnalisisActionBtn(
              icon: copiado ? Icons.check : Icons.copy_rounded,
              confirmed: copiado,
              tooltip: 'Copiar',
              onTap: onCopy,
            ),
            if (esUltimoCoach && !escribiendo) ...[
              const SizedBox(width: 4),
              AnalisisActionBtn(
                icon: Icons.refresh_rounded,
                tooltip: 'Regenerar',
                onTap: onRegenerate,
              ),
            ],
          ],
        ],
      ),
    );

    final column = Flexible(
      child: Column(
        crossAxisAlignment: coach
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          AnalisisSender(coach: coach),
          bubble,
          footer,
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: coach
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: coach
          ? [
              const AnalisisAvatar(coach: true),
              const SizedBox(width: 14),
              column,
            ]
          : [
              column,
              const SizedBox(width: 14),
              const AnalisisAvatar(coach: false),
            ],
    );
  }
}
