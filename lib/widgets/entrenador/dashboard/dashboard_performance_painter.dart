import 'package:flutter/material.dart';

import 'dashboard_theme.dart';

/// Gráfica de efectividad en últimos partidos (% de sets ganados).
class DashboardPerformancePainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;

  static const padL = 40.0, padR = 16.0, padT = 12.0, padB = 28.0;

  DashboardPerformancePainter(this.labels, this.values);

  Offset _point(int i, Size s) {
    final cW = s.width - padL - padR;
    final cH = s.height - padT - padB;
    final x = values.length <= 1
        ? padL + cW / 2
        : padL + (i / (values.length - 1)) * cW;
    final y = padT + cH - (values[i].clamp(0, 100) / 100) * cH;
    return Offset(x, y);
  }

  void _drawText(Canvas canvas, String t, Offset pos, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(
          color: DashboardTheme.textSecondary,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 120);

    double dx = pos.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cH = size.height - padT - padB;

    // Rejilla + etiquetas Y (0%, 25%, 50%, 75%, 100%)
    final grid = Paint()
      ..color = DashboardTheme.border
      ..strokeWidth = 1;

    for (final v in [0, 25, 50, 75, 100]) {
      final y = padT + cH - (v / 100) * cH;
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), grid);
      _drawText(canvas, '$v%', Offset(padL - 8, y), TextAlign.right);
    }

    if (values.isEmpty) return;

    // Etiquetas X
    for (var i = 0; i < labels.length && i < values.length; i++) {
      _drawText(
        canvas,
        labels[i],
        Offset(_point(i, size).dx, size.height - 8),
        TextAlign.center,
      );
    }

    final pts = [for (var i = 0; i < values.length; i++) _point(i, size)];

    if (pts.length >= 2) {
      final line = Path()..moveTo(pts.first.dx, pts.first.dy);

      for (var i = 0; i < pts.length - 1; i++) {
        final p0 = i > 0 ? pts[i - 1] : pts[i];
        final p1 = pts[i];
        final p2 = pts[i + 1];
        final p3 = i + 2 < pts.length ? pts[i + 2] : p2;

        const k = 0.45 / 3; // tension 0.45 de Chart.js en page.jsx

        final c1 = Offset(
          p1.dx + (p2.dx - p0.dx) * k * 1.5,
          p1.dy + (p2.dy - p0.dy) * k * 1.5,
        );
        final c2 = Offset(
          p2.dx - (p3.dx - p1.dx) * k * 1.5,
          p2.dy - (p3.dy - p1.dy) * k * 1.5,
        );

        line.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }

      // Área degradada
      final area = Path.from(line)
        ..lineTo(pts.last.dx, padT + cH)
        ..lineTo(pts.first.dx, padT + cH)
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DashboardTheme.blue.withValues(alpha: 0.35),
              DashboardTheme.blue.withValues(alpha: 0.01),
            ],
          ).createShader(Rect.fromLTWH(0, padT, size.width, cH)),
      );

      // Línea
      canvas.drawPath(
        line,
        Paint()
          ..color = DashboardTheme.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Puntos
    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = DashboardTheme.blue);
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = DashboardTheme.bgSecondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  /// Devuelve el tooltip del punto más cercano al toque (`"<rival>: <pct>% sets ganados"`).
  String? findPoint(Offset pos, Size size) {
    double best = 24;
    String? result;

    for (var i = 0; i < values.length && i < labels.length; i++) {
      final d = (_point(i, size) - pos).distance;
      if (d < best) {
        best = d;
        result = '${labels[i]}: ${values[i].round()}% sets ganados';
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant DashboardPerformancePainter old) =>
      old.labels != labels || old.values != values;
}
