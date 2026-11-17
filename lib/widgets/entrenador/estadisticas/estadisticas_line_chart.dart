import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'estadisticas_line_painter.dart';
import 'estadisticas_models.dart';
import 'estadisticas_theme.dart';

/// Gráfica de evolución con leyenda interactiva y tooltip al tocar un punto.
///
/// El estado (series ocultas y tooltip) lo maneja la pantalla.
class EstadisticasLineChart extends StatelessWidget {
  final List<EstadisticasSeries> series;
  final Set<String> hidden;
  final String? chartTip;
  final ValueChanged<String?> onTip;
  final ValueChanged<String> onToggleSeries;

  const EstadisticasLineChart({
    super.key,
    required this.series,
    required this.hidden,
    required this.chartTip,
    required this.onTip,
    required this.onToggleSeries,
  });

  @override
  Widget build(BuildContext context) {
    final visible = series.where((s) => !hidden.contains(s.name)).toList();
    final vals = series.expand((s) => s.values).toList();
    final minV = vals.isEmpty ? 0.0 : vals.reduce(math.min) - 5.0;
    final maxV = vals.isEmpty ? 100.0 : vals.reduce(math.max) + 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final painter = EstadisticasLinePainter(
              series: visible,
              dates: estadisticasDates,
              minV: minV,
              maxV: maxV,
            );
            return GestureDetector(
              onTapDown: (d) {
                final hit = painter.findPoint(
                  d.localPosition,
                  Size(c.maxWidth, 150),
                );
                onTip(hit);
              },
              child: CustomPaint(size: Size(c.maxWidth, 150), painter: painter),
            );
          },
        ),
        if (chartTip != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2235),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EstadisticasTheme.border),
              ),
              child: Text(
                chartTip!,
                style: const TextStyle(
                  fontSize: 12,
                  color: EstadisticasTheme.text,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: series.map((s) {
            final isHidden = hidden.contains(s.name);
            return GestureDetector(
              onTap: () => onToggleSeries(s.name),
              child: Opacity(
                opacity: isHidden ? 0.4 : 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: EstadisticasTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
