import 'package:flutter/material.dart';

import 'analisis_theme.dart';

/// Barra de "analizando" con segmento que se desplaza.
class AnalisisThinkingBar extends StatefulWidget {
  const AnalisisThinkingBar({super.key});

  @override
  State<AnalisisThinkingBar> createState() => _AnalisisThinkingBarState();
}

class _AnalisisThinkingBarState extends State<AnalisisThinkingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const w = 72.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: w,
        height: 4,
        color: AnalisisTheme.line,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final seg = w * 0.4;
            final dx = -seg + (w + seg) * Curves.easeInOut.transform(_c.value);
            return Stack(
              children: [
                Positioned(
                  left: dx,
                  width: seg,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AnalisisTheme.aiGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AnalisisTheme.accent.withOpacity(0.53),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
