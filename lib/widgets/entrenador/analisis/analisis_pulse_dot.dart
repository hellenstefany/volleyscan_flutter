import 'package:flutter/material.dart';

import 'analisis_theme.dart';

/// Punto verde que pulsa (equivale a .ai-status-dot).
class AnalisisPulseDot extends StatefulWidget {
  const AnalisisPulseDot({super.key});

  @override
  State<AnalisisPulseDot> createState() => _AnalisisPulseDotState();
}

class _AnalisisPulseDotState extends State<AnalisisPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Opacity(
          opacity: 1 - 0.6 * t,
          child: Transform.scale(
            scale: 1 - 0.15 * t,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AnalisisTheme.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AnalisisTheme.success, blurRadius: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
