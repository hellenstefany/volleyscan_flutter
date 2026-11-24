import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/estadisticas_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta con la gráfica de evolución de la puntuación media y volumen de análisis.
class EstadisticasEvolucionCard extends StatefulWidget {
  final List<CoachStatsPoint> puntos;
  final int? media;

  const EstadisticasEvolucionCard({super.key, required this.puntos, required this.media});

  @override
  State<EstadisticasEvolucionCard> createState() => _EstadisticasEvolucionCardState();
}

class _EstadisticasEvolucionCardState extends State<EstadisticasEvolucionCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final puntos = widget.puntos;
    final conDatos = puntos.any((p) => p.promedio != null);
    final sel = (_selected != null && _selected! < puntos.length) ? puntos[_selected!] : null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              const Text('Evolución de la puntuación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DashColors.text1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: DashColors.coachCard2, borderRadius: BorderRadius.circular(99), border: Border.all(color: DashColors.coachBorder)),
                child: const Text('Media de todos tus deportistas', style: TextStyle(fontSize: 11.5, color: DashColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (puntos.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('Sin puntos en este periodo', style: TextStyle(color: DashColors.textMuted))))
          else
            LayoutBuilder(
              builder: (_, c) => GestureDetector(
                onTapDown: (d) => _selectAt(d.localPosition.dx, c.maxWidth),
                onPanUpdate: (d) => _selectAt(d.localPosition.dx, c.maxWidth),
                onTapCancel: () => setState(() => _selected = null),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 225,
                      width: double.infinity,
                      child: CustomPaint(painter: _EvolucionPainter(puntos: puntos, media: widget.media, selected: _selected)),
                    ),
                    if (!conDatos)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(color: DashColors.cardDark.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(14), border: Border.all(color: DashColors.coachBorder)),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Aún no hay análisis en este periodo', textAlign: TextAlign.center, style: TextStyle(fontSize: 13.8, fontWeight: FontWeight.w700, color: DashColors.text1)),
                            SizedBox(height: 4),
                            Text('Cuando tus deportistas analicen su técnica con la IA, verás aquí su evolución.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.2, color: DashColors.textMuted)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (sel != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: DashColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DashColors.coachBorder)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sel.desde == sel.hasta ? formatStatsShortDate(sel.desde) : '${formatStatsShortDate(sel.desde)} – ${formatStatsShortDate(sel.hasta)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: DashColors.text1),
                    ),
                  ),
                  Text(
                    sel.promedio != null ? 'Media ${sel.promedio} · ${sel.sesiones} análisis' : 'Sin análisis · 0 sesiones',
                    style: const TextStyle(fontSize: 12.2, color: DashColors.accent2, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
          if (conDatos) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _legendItem(DashColors.blueLight, 'Puntuación media'),
                if (widget.media != null) _legendItem(DashColors.textMuted, 'Media del periodo: ${widget.media}'),
                _legendItem(DashColors.accent2.withValues(alpha: 0.55), 'Cantidad de análisis'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectAt(double dx, double width) {
    final n = widget.puntos.length;
    if (n == 0) return;
    final band = (width - 40.0) / n;
    if (band <= 0) return;
    setState(() => _selected = ((dx - 32.0) / band).floor().clamp(0, n - 1));
  }

  Widget _legendItem(Color c, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, color: DashColors.textMuted)),
        ],
      );
}

class _EvolucionPainter extends CustomPainter {
  final List<CoachStatsPoint> puntos;
  final int? media, selected;

  _EvolucionPainter({required this.puntos, required this.media, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 32.0, right = 8.0, top = 10.0, base = 148.0, volTop = 170.0, volBase = 196.0;
    final n = puntos.length;
    final band = (size.width - left - right) / math.max(1, n);
    double xAt(int i) => left + (i + 0.5) * band;
    double yAt(num p) => base - (p / 100.0) * (base - top);

    final gridPaint = Paint()..color = DashColors.coachBorder..strokeWidth = 1;
    for (final v in [0, 25, 50, 75, 100]) {
      final y = yAt(v);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      _drawText(canvas, '$v', Offset(left - 6, y - 6), alignRight: true);
    }

    if (media != null && puntos.any((p) => p.promedio != null)) {
      final ym = yAt(media!);
      final pMedia = Paint()..color = DashColors.textMuted.withValues(alpha: 0.55)..strokeWidth = 1.2;
      for (double dx = left; dx < size.width - right; dx += 8) {
        canvas.drawLine(Offset(dx, ym), Offset(math.min(dx + 4, size.width - right), ym), pMedia);
      }
    }

    final segments = <List<(int, int)>>[];
    for (var i = 0; i < n; i++) {
      final prom = puntos[i].promedio;
      if (prom == null) {
        if (segments.isEmpty || segments.last.isNotEmpty) segments.add([]);
      } else {
        if (segments.isEmpty) segments.add([]);
        segments.last.add((i, prom));
      }
    }

    for (final seg in segments.where((s) => s.length > 1)) {
      final line = Path(), area = Path();
      for (var k = 0; k < seg.length; k++) {
        final pt = Offset(xAt(seg[k].$1), yAt(seg[k].$2));
        if (k == 0) {
          line.moveTo(pt.dx, pt.dy);
          area..moveTo(pt.dx, base)..lineTo(pt.dx, pt.dy);
        } else {
          line.lineTo(pt.dx, pt.dy);
          area.lineTo(pt.dx, pt.dy);
        }
      }
      area..lineTo(xAt(seg.last.$1), base)..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [DashColors.blueLight.withValues(alpha: 0.34), DashColors.blueLight.withValues(alpha: 0.0)],
          ).createShader(Rect.fromLTWH(left, top, size.width - left - right, base - top)),
      );
      canvas.drawPath(line, Paint()..color = DashColors.blueLight..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    }

    for (var i = 0; i < n; i++) {
      final prom = puntos[i].promedio;
      if (prom != null) canvas.drawCircle(Offset(xAt(i), yAt(prom)), selected == i ? 5.2 : 3.4, Paint()..color = selected == i ? DashColors.accent2 : DashColors.blueLight);
    }

    final maxSes = math.max(1, puntos.map((p) => p.sesiones).reduce(math.max));
    final barW = math.min(band * 0.56, 18.0);
    for (var i = 0; i < n; i++) {
      final ses = puntos[i].sesiones;
      if (ses <= 0) continue;
      final h = math.max(3.0, (ses / maxSes) * (volBase - volTop));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(xAt(i) - barW / 2, volBase - h, barW, h), const Radius.circular(2.5)),
        Paint()..color = (selected == i ? DashColors.accent2 : DashColors.blueLight).withValues(alpha: selected == i ? 0.85 : 0.38),
      );
    }
    canvas.drawLine(Offset(left, volBase), Offset(size.width - right, volBase), gridPaint);

    final paso = math.max(1, (n / 5).ceil());
    for (var i = 0; i < n; i++) {
      if (i % paso == 0 || (i == n - 1 && (n - 1) % paso >= (paso / 2).ceil())) {
        _drawText(canvas, formatStatsShortDate(puntos[i].hasta), Offset(xAt(i), size.height - 16), center: true);
      }
    }
    if (selected != null && selected! < n) {
      final gx = xAt(selected!);
      canvas.drawLine(Offset(gx, top), Offset(gx, volBase), Paint()..color = DashColors.accent2.withValues(alpha: 0.45)..strokeWidth = 1.2);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, {bool alignRight = false, bool center = false}) {
    final tp = TextPainter(text: TextSpan(text: text, style: const TextStyle(fontSize: 10, color: DashColors.textMuted)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(alignRight ? pos.dx - tp.width : (center ? pos.dx - tp.width / 2 : pos.dx), pos.dy));
  }

  @override
  bool shouldRepaint(_EvolucionPainter old) => old.puntos != puntos || old.media != media || old.selected != selected;
}
