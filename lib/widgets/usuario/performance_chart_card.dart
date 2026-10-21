import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

class PerformanceChartCard extends StatelessWidget {
  final List<double> values;
  const PerformanceChartCard({super.key, required this.values});

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
            'EVOLUCIÓN DE RENDIMIENTO',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(painter: _LineChartPainter(values)),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    const padX = 10.0;
    const padY = 12.0;
    final w = size.width - padX * 2;
    final h = size.height - padY * 2;

    // Líneas de la cuadrícula
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = padY + h * i / 4;
      canvas.drawLine(Offset(padX, y), Offset(padX + w, y), grid);
    }

    final minV = values.reduce((a, b) => a < b ? a : b) - 4;
    final maxV = values.reduce((a, b) => a > b ? a : b) + 4;
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          padX + w * i / (values.length - 1),
          padY + h - ((values[i] - minV) / range) * h,
        ),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = RoutineColors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final dot = Paint()..color = const Color(0xFF22C55E);
    for (final p in points) {
      canvas.drawCircle(p, 5.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.values != values;
}
