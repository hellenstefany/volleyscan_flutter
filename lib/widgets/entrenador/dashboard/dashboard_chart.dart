import 'package:flutter/material.dart';

import 'dashboard_models.dart';
import 'dashboard_performance_painter.dart';
import 'dashboard_theme.dart';

/// Gráfica de efectividad en últimos partidos (`% Sets`) con estados de carga, error y vacío.
class DashboardChart extends StatefulWidget {
  final bool narrow;
  final List<EntrenadorUltimoPartido> partidos;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const DashboardChart({
    super.key,
    required this.narrow,
    required this.partidos,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  String? _tip;

  @override
  Widget build(BuildContext context) {
    final chartHeight = widget.narrow ? 220.0 : 200.0;

    if (widget.error != null && widget.partidos.isEmpty) {
      return SizedBox(
        height: chartHeight,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: DashboardTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onRetry,
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DashboardTheme.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.loading && widget.partidos.isEmpty) {
      return Container(
        height: chartHeight,
        decoration: BoxDecoration(
          color: DashboardTheme.bgCardHover,
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    // Exactamente como en `page.jsx`:
    // `const partidosOrdenados = [...ultimosPartidos].reverse();`
    final ordenados = widget.partidos.reversed.toList();
    final labels = ordenados.isNotEmpty
        ? ordenados.map((p) => 'vs ${p.rival}').toList()
        : const <String>['Sin partidos registrados'];
    final values = ordenados.isNotEmpty
        ? ordenados.map((p) => p.porcentajeSets.toDouble()).toList()
        : const <double>[0.0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final painter = DashboardPerformancePainter(labels, values);
            final size = Size(c.maxWidth, chartHeight);

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
                color: DashboardTheme.bgCardHover,
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
