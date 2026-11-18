import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'reportes_colors.dart';

// ───────── Dona animada ─────────
class RepDonut extends StatelessWidget {
  final double size, stroke, value;
  final Widget center;
  const RepDonut({
    super.key,
    required this.size,
    required this.stroke,
    required this.value,
    required this.center,
  });

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeOut,
    builder: (_, v, __) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(v, stroke),
          ),
          center,
        ],
      ),
    ),
  );
}

class _DonutPainter extends CustomPainter {
  final double value, stroke;
  _DonutPainter(this.value, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    final sweep = math.pi * 2 * value;
    if (sweep <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.max(0.01, sweep),
          colors: const [RC.mint, RC.blue],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter o) =>
      o.value != value || o.stroke != stroke;
}

// ───────── Sparkline ─────────
class RepSparkline extends StatelessWidget {
  final List<double> points;
  final double height;
  const RepSparkline({super.key, required this.points, required this.height});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: CustomPaint(size: Size.infinite, painter: _SparkPainter(points)),
  );
}

class _SparkPainter extends CustomPainter {
  final List<double> pts;
  _SparkPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 4.0;
    final mn = pts.reduce(math.min);
    final mx = pts.reduce(math.max);
    double xp(int i) => pad + i * (size.width - pad * 2) / (pts.length - 1);
    double yp(double v) =>
        size.height -
        pad -
        (v - mn) / (mx - mn == 0 ? 1 : mx - mn) * (size.height - pad * 2);

    final line = Path()..moveTo(xp(0), yp(pts[0]));
    for (var i = 1; i < pts.length; i++) {
      line.lineTo(xp(i), yp(pts[i]));
    }
    final area = Path.from(line)
      ..lineTo(xp(pts.length - 1), size.height)
      ..lineTo(xp(0), size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            RC.blue.withValues(alpha: 0.4),
            RC.blue.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = RC.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(
        Offset(xp(i), yp(pts[i])),
        3,
        Paint()..color = RC.blue2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter o) => o.pts != pts;
}
