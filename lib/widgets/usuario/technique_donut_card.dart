import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/progress_data.dart';
import '../../theme/routine_colors.dart';

class TechniqueDonutCard extends StatelessWidget {
  final List<TechniquePerformance> techniques;
  const TechniqueDonutCard({super.key, required this.techniques});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RoutineColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RENDIMIENTO POR TÉCNICA',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: _DonutPainter(techniques)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (final t in techniques)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: t.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                t.name,
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '${t.percent}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<TechniquePerformance> techniques;
  _DonutPainter(this.techniques);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 20.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    final total = techniques.fold<int>(0, (s, t) => s + t.percent);
    if (total == 0) return;

    const gap = 0.05; // radianes entre segmentos
    var start = -math.pi / 2;

    for (final t in techniques) {
      final sweep = (t.percent / total) * 2 * math.pi;
      canvas.drawArc(
        rect,
        start + gap / 2,
        sweep - gap,
        false,
        Paint()
          ..color = t.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.techniques != techniques;
}
