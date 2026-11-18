import 'package:flutter/material.dart';
import 'reportes_charts.dart';
import 'reportes_colors.dart';
import 'reportes_common_widget.dart';
import 'reportes_model.dart';

/// Tarjeta de vista previa rápida (paso 1, columna derecha).
class ReportesPreviewCard extends StatelessWidget {
  final String tipo, dep;
  final DateTime from, to;
  final Map<String, bool> checks;
  final Dep d;

  const ReportesPreviewCard({
    super.key,
    required this.tipo,
    required this.dep,
    required this.from,
    required this.to,
    required this.checks,
    required this.d,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: repBox(RC.card, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte $tipo',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: RC.t1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tipo == 'Grupal' ? 'Todos los deportistas' : dep,
            style: const TextStyle(fontSize: 11.5, color: RC.t2),
          ),
          const SizedBox(height: 2),
          Text(
            '${fmtDisp(from)} – ${fmtDisp(to)}',
            style: const TextStyle(fontSize: 11, color: RC.t3),
          ),
          const SizedBox(height: 16),
          if (checks['Rendimiento']!)
            Center(
              child: RepDonut(
                size: 140,
                stroke: 14,
                value: d.perf / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${d.perf}%',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Rendimiento',
                      style: TextStyle(fontSize: 9, color: RC.t2),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (checks['Asistencia']!)
                Expanded(
                  child: RepMiniStat(
                    label: 'Asistencia',
                    child: Center(
                      child: RepDonut(
                        size: 60,
                        stroke: 7,
                        value: d.asis / 100,
                        center: Text(
                          '${d.asis}%',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (checks['Asistencia']!) const SizedBox(width: 10),
              Expanded(
                child: RepMiniStat(
                  label: 'Sesiones',
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${d.ses}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RepMiniStat(
            label: 'Evolución',
            child: RepSparkline(points: d.spark, height: 56),
          ),
        ],
      ),
    );
  }
}
