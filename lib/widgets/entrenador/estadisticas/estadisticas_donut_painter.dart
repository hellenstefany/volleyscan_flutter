import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'estadisticas_theme.dart';

class EstadisticasDonutPainter extends CustomPainter {
  final double progress;
  EstadisticasDonutPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - sw / 2 - 12; // equivale a r=60 en 160px
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [EstadisticasTheme.accent, EstadisticasTheme.accent5],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant EstadisticasDonutPainter old) =>
      old.progress != progress;
}
