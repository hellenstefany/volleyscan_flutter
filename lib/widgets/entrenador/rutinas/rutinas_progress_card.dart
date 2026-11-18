import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'rutinas_colors.dart';
import 'rutinas_common_widgets.dart';

/// Tarjeta "Progreso semanal" con anillos por tipo.
class RutinasProgressCard extends StatelessWidget {
  const RutinasProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    const rings = [
      ('Técnico', 75),
      ('Físico', 60),
      ('Táctico', 45),
      ('Recuperación', 90),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: rtBox(RtC.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RtCardTitle(icon: '📊', title: 'Progreso semanal'),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              for (final r in rings)
                Column(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CustomPaint(
                        painter: _RingPainter(r.$2 / 100, kTypeColors[r.$1]!),
                        child: Center(
                          child: Text(
                            '${r.$2}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTypeColors[r.$1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.$1,
                      style: const TextStyle(fontSize: 11, color: RtC.muted),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  _RingPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 7.0;
    final rect = (Offset.zero & size).deflate(sw / 2 + 3);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) =>
      o.value != value || o.color != color;
}
