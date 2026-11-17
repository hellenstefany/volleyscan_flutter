import 'package:flutter/material.dart';

import 'estadisticas_models.dart';
import 'estadisticas_theme.dart';

/// Gráfica de líneas: evolución de rendimiento.
class EstadisticasLinePainter extends CustomPainter {
  final List<EstadisticasSeries> series;
  final List<String> dates;
  final double minV;
  final double maxV;

  static const padL = 34.0, padR = 10.0, padT = 10.0, padB = 30.0;

  EstadisticasLinePainter({
    required this.series,
    required this.dates,
    required this.minV,
    required this.maxV,
  });

  double _x(int i, Size s) =>
      padL + (i / (dates.length - 1)) * (s.width - padL - padR);

  double _y(num v, Size s) {
    final cH = s.height - padT - padB;
    return padT + cH - ((v - minV) / (maxV - minV)) * cH;
  }

  void _label(Canvas canvas, String t, Offset pos, TextAlign align) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(color: EstadisticasTheme.muted, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    double dx = pos.dx;
    if (align == TextAlign.right) dx -= tp.width;
    if (align == TextAlign.center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cH = size.height - padT - padB;

    // Rejilla + etiquetas Y
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      final y = padT + cH * (1 - t);
      canvas.drawLine(Offset(padL, y), Offset(size.width - padR, y), grid);
      _label(
        canvas,
        '${(minV + t * (maxV - minV)).round()}%',
        Offset(padL - 4, y),
        TextAlign.right,
      );
    }

    // Etiquetas X
    for (var i = 0; i < dates.length; i++) {
      _label(
        canvas,
        dates[i],
        Offset(_x(i, size), size.height - 6),
        TextAlign.center,
      );
    }

    // Series
    for (final s in series) {
      final pts = s.values.take(dates.length).toList();
      final line = Path();
      for (var i = 0; i < pts.length; i++) {
        final p = Offset(_x(i, size), _y(pts[i], size));
        i == 0 ? line.moveTo(p.dx, p.dy) : line.lineTo(p.dx, p.dy);
      }

      final area = Path.from(line)
        ..lineTo(_x(pts.length - 1, size), padT + cH)
        ..lineTo(_x(0, size), padT + cH)
        ..close();

      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [s.color.withOpacity(0.25), s.color.withOpacity(0)],
          ).createShader(Rect.fromLTWH(0, padT, size.width, cH)),
      );

      canvas.drawPath(
        line,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

      for (var i = 0; i < pts.length; i++) {
        final c = Offset(_x(i, size), _y(pts[i], size));
        canvas.drawCircle(c, 4, Paint()..color = s.color);
        canvas.drawCircle(
          c,
          4,
          Paint()
            ..color = EstadisticasTheme.panel2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  /// Devuelve el texto del punto más cercano al toque (o null).
  String? findPoint(Offset pos, Size size) {
    double best = 18;
    String? result;
    for (final s in series) {
      final pts = s.values.take(dates.length).toList();
      for (var i = 0; i < pts.length; i++) {
        final d = (Offset(_x(i, size), _y(pts[i], size)) - pos).distance;
        if (d < best) {
          best = d;
          result = '${s.name} (${dates[i]}): ${pts[i]}%';
        }
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant EstadisticasLinePainter old) => true;
}
