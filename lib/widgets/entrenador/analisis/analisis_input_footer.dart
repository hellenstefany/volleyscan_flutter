import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analisis_suggestion_chip.dart';
import 'analisis_theme.dart';

/// Pie: consola de entrada + contador + sugerencias.
///
/// Lee `controller.text` y `focus.hasFocus`, así que el padre debe
/// reconstruirse cuando cambien (la pantalla ya escucha ambos).
class AnalisisInputFooter extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final bool escribiendo;
  final bool narrow;
  final void Function(String texto) onSend;

  const AnalisisInputFooter({
    super.key,
    required this.controller,
    required this.focus,
    required this.escribiendo,
    required this.narrow,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final len = controller.text.length;
    final puedeEnviar = !escribiendo && controller.text.trim().isNotEmpty;
    final focused = focus.hasFocus;
    const max = AnalisisTheme.maxCaracteres;

    final counterColor = len >= max
        ? const Color(0xFFEF4444)
        : len >= max * 0.9
        ? const Color(0xFFF59E0B)
        : AnalisisTheme.textMuted;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 32, 16, narrow ? 16 : 32, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AnalisisTheme.line)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC0D0F1A), Color(0xF20D0F1A)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
                decoration: BoxDecoration(
                  gradient: AnalisisTheme.surfaceGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: focused
                        ? AnalisisTheme.accent
                        : AnalisisTheme.lineStrong,
                    width: 1,
                  ),
                  boxShadow: [
                    if (focused)
                      BoxShadow(
                        color: AnalisisTheme.accent.withOpacity(0.2),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    const BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                      child: Text(
                        '›',
                        style: AnalisisTheme.mono.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AnalisisTheme.accent,
                        ),
                      ),
                    ),
                    Expanded(
                      // Enter envía, Shift+Enter hace salto de línea
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter &&
                              !HardwareKeyboard.instance.isShiftPressed) {
                            onSend(controller.text);
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextField(
                          controller: controller,
                          focusNode: focus,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: max,
                          keyboardType: TextInputType.multiline,
                          cursorColor: AnalisisTheme.accent,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AnalisisTheme.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                "Escribe tu pregunta aquí... Ej: 'Cómo mejorar mi recepción'",
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: AnalisisTheme.textMuted,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Opacity(
                      opacity: puedeEnviar ? 1 : 0.35,
                      child: GestureDetector(
                        onTap: puedeEnviar
                            ? () => onSend(controller.text)
                            : null,
                        child: Container(
                          width: 42,
                          height: 42,
                          margin: const EdgeInsets.only(bottom: 2),
                          decoration: BoxDecoration(
                            gradient: AnalisisTheme.aiGradient,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: puedeEnviar
                                ? [
                                    BoxShadow(
                                      color: AnalisisTheme.accent.withOpacity(
                                        0.27,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$len/$max',
                    style: AnalisisTheme.mono.copyWith(
                      fontSize: 10.8,
                      color: counterColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final s in AnalisisTheme.sugerencias)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnalisisSuggestionChip(
                          glifo: s.$1,
                          texto: s.$2,
                          onTap: () => onSend(s.$2),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
