import 'package:flutter/material.dart';

import 'analisis_message_bubble.dart';
import 'analisis_models.dart';
import 'analisis_thinking.dart';

class AnalisisMessageList extends StatelessWidget {
  final List<ChatMsg> mensajes;
  final bool escribiendo;
  final bool narrow;
  final ScrollController controller;
  final int? copiadoIndex;
  final void Function(String texto, int index) onCopy;
  final VoidCallback onRegenerate;

  const AnalisisMessageList({
    super.key,
    required this.mensajes,
    required this.escribiendo,
    required this.narrow,
    required this.controller,
    required this.copiadoIndex,
    required this.onCopy,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final total = mensajes.length + (escribiendo ? 1 : 0);

    return LayoutBuilder(
      builder: (context, c) {
        final bubbleMax =
            (narrow ? 0.9 : 0.74) *
            (c.maxWidth - (narrow ? 32 : 64) - 54).clamp(0, 880);

        return ListView.builder(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            narrow ? 16 : 32,
            28,
            narrow ? 16 : 32,
            20,
          ),
          itemCount: total,
          itemBuilder: (_, i) {
            Widget child;
            if (i >= mensajes.length) {
              child = const AnalisisThinking();
            } else {
              final m = mensajes[i];
              final esUltimoCoach =
                  m.coach && i == mensajes.length - 1 && mensajes.length > 1;
              child = AnalisisMessageBubble(
                mensaje: m,
                bubbleMax: bubbleMax.toDouble().clamp(200, 640),
                esUltimoCoach: esUltimoCoach,
                escribiendo: escribiendo,
                copiado: copiadoIndex == i,
                onCopy: () => onCopy(m.texto, i),
                onRegenerate: onRegenerate,
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: child,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
