import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_performance_painter.dart';
import 'dashboard_theme.dart';

/// Gráfica de rendimiento semanal con tooltip al tocar un punto.
class DashboardChart extends StatefulWidget {
  final bool narrow;
  const DashboardChart({super.key, required this.narrow});

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  String? _tip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final painter = DashboardPerformancePainter(
              dashboardChartLabels,
              dashboardChartValues,
            );
            final size = Size(c.maxWidth, widget.narrow ? 220 : 200);

            return GestureDetector(
              onTapDown: (d) {
                setState(() => _tip = painter.findPoint(d.localPosition, size));
              },
              child: CustomPaint(size: size, painter: painter),
            );
          },
        ),
        if (_tip != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2235),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DashboardTheme.border),
              ),
              child: Text(
                _tip!,
                style: const TextStyle(
                  fontSize: 12,
                  color: DashboardTheme.textPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
