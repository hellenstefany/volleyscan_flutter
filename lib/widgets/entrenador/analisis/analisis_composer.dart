import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'analisis_models.dart';
import 'analisis_theme.dart';

/// Caja de escritura unificada (`.ai-composer` en `page.jsx` / `Analisis.css`).
/// Se reutiliza tanto en la vista de Bienvenida (`maxWidth: 760`) como en el pie del Chat (`maxWidth: 880`).
class AnalisisComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final bool escribiendo;
  final double maxWidth;
  final void Function(String texto) onSend;

  const AnalisisComposer({
    super.key,
    required this.controller,
    required this.focus,
    required this.escribiendo,
    required this.onSend,
    this.maxWidth = 760,
  });

  @override
  Widget build(BuildContext context) {
    final len = controller.text.length;
    final puedeEnviar = !escribiendo && controller.text.trim().isNotEmpty;
    final focused = focus.hasFocus;
    const max = AnalisisConfig.maxCaracteres;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
        decoration: BoxDecoration(
          color: AnalisisTheme.surface,
          borderRadius: BorderRadius.circular(AnalisisTheme.radiusComposer),
          border: Border.all(
            color: focused
                ? AnalisisTheme.accent.withValues(alpha: 0.7)
                : AnalisisTheme.lineStrong,
            width: 1,
          ),
          boxShadow: [
            if (focused)
              BoxShadow(
                color: AnalisisTheme.accent.withValues(alpha: 0.14),
                spreadRadius: 3,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 40,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── .ai-composer-field: ícono ✦ + textarea ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AnalisisTheme.spark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter &&
                          !HardwareKeyboard.instance.isShiftPressed) {
                        if (puedeEnviar) onSend(controller.text);
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
                        fontSize: 14.7,
                        height: 1.5,
                        color: AnalisisTheme.text,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'Pregúntame lo que quieras sobre tu entrenamiento...',
                        hintStyle: TextStyle(
                          fontSize: 14.7,
                          color: AnalisisTheme.text3,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        counterText: '',
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            // ── .ai-composer-bar: herramientas izquierda + contador y enviar derecha ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      _RoundToolBtn(
                        icon: Icons.add_rounded,
                        tooltip: 'Adjuntar',
                      ),
                      _PillToolBtn(
                        icon: Icons.tune_rounded,
                        label: 'Ajustes',
                      ),
                      _PillToolBtn(
                        icon: Icons.grid_view_rounded,
                        label: 'Opciones',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$len/$max',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10.9,
                        color: AnalisisTheme.text3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Opacity(
                      opacity: puedeEnviar ? 1 : 0.35,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(17),
                        onTap: puedeEnviar
                            ? () => onSend(controller.text)
                            : null,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AnalisisTheme.sendBg,
                            shape: BoxShape.circle,
                            boxShadow: puedeEnviar
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 15,
                            color: AnalisisTheme.sendFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundToolBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;

  const _RoundToolBtn({required this.icon, required this.tooltip});

  @override
  State<_RoundToolBtn> createState() => _RoundToolBtnState();
}

class _RoundToolBtnState extends State<_RoundToolBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Tooltip(
        message: widget.tooltip,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AnalisisTheme.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: _hover
                  ? AnalisisTheme.accent.withValues(alpha: 0.55)
                  : AnalisisTheme.lineStrong,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 15,
            color: _hover ? AnalisisTheme.text : AnalisisTheme.text2,
          ),
        ),
      ),
    );
  }
}

class _PillToolBtn extends StatefulWidget {
  final IconData icon;
  final String label;

  const _PillToolBtn({required this.icon, required this.label});

  @override
  State<_PillToolBtn> createState() => _PillToolBtnState();
}

class _PillToolBtnState extends State<_PillToolBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = _hover ? AnalisisTheme.text : AnalisisTheme.text2;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AnalisisTheme.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: _hover
                ? AnalisisTheme.accent.withValues(alpha: 0.55)
                : AnalisisTheme.lineStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 13, color: fg),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12.2,
                color: fg,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: fg.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
