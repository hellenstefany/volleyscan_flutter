import 'package:flutter/material.dart';

import 'analisis_composer.dart';
import 'analisis_models.dart';
import 'analisis_suggestion_chip.dart';
import 'analisis_theme.dart';

/// Pie de la vista de chat (`.ai-footer` en `Analisis.css`): `.ai-composer` + `.ai-suggestions`.
class AnalisisInputFooter extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final bool escribiendo;
  final bool narrow;
  final double bottomSafePadding;
  final void Function(String texto) onSend;

  const AnalisisInputFooter({
    super.key,
    required this.controller,
    required this.focus,
    required this.escribiendo,
    required this.narrow,
    required this.onSend,
    this.bottomSafePadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = narrow ? 16.0 : 32.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        hPad,
        12,
        hPad,
        20 + bottomSafePadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35],
          colors: [
            AnalisisTheme.bg.withValues(alpha: 0.0),
            AnalisisTheme.bg.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnalisisComposer(
                controller: controller,
                focus: focus,
                escribiendo: escribiendo,
                maxWidth: 880,
                onSend: onSend,
              ),
              const SizedBox(height: 12),
              narrow
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final s in AnalisisConfig.sugerencias)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AnalisisSuggestionChip(
                                glifo: s.$1,
                                texto: s.$2,
                                onTap:
                                    escribiendo ? null : () => onSend(s.$2),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in AnalisisConfig.sugerencias)
                          AnalisisSuggestionChip(
                            glifo: s.$1,
                            texto: s.$2,
                            onTap: escribiendo ? null : () => onSend(s.$2),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
