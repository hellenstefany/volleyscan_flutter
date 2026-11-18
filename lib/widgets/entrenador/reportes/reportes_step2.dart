import 'package:flutter/material.dart';
import 'reportes_charts.dart';
import 'reportes_colors.dart';
import 'reportes_common_widget.dart';
import 'reportes_model.dart';

/// Paso 2: vista previa completa del reporte.
class ReportesStep2 extends StatelessWidget {
  final String tipo, dep;
  final DateTime from, to;
  final Map<String, bool> checks;
  final Dep d;
  final VoidCallback onBack, onExport;

  const ReportesStep2({
    super.key,
    required this.tipo,
    required this.dep,
    required this.from,
    required this.to,
    required this.checks,
    required this.d,
    required this.onBack,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: repBox(RC.card2, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reporte $tipo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: RC.t1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${tipo == 'Grupal' ? 'Equipo completo' : dep} · ${fmtDisp(from)} – ${fmtDisp(to)}',
                        style: const TextStyle(fontSize: 12, color: RC.t2),
                      ),
                    ],
                  ),
                  RepSecButton(
                    icon: Icons.fullscreen,
                    label: 'Pantalla completa',
                    onTap: () => showReportesFullPreview(
                      context,
                      tipo: tipo,
                      dep: dep,
                      checks: checks,
                      d: d,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              RepStatsGrid(stats: buildStats(d, checks)),
              const SizedBox(height: 12),
              RepMiniStat(
                label: 'Evolución del rendimiento',
                child: RepSparkline(points: d.spark, height: 70),
              ),
              if (checks['Recomendaciones']!) ...[
                const SizedBox(height: 14),
                const RepFieldLabel('Recomendaciones IA'),
                for (final r in kRecs[dep] ?? const <String>[])
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: RC.hover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 13,
                          color: RC.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: RC.t1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 10,
          runSpacing: 10,
          children: [
            RepSecButton(
              icon: Icons.arrow_back,
              label: 'Volver',
              onTap: onBack,
            ),
            RepPriButton(
              icon: Icons.file_upload_outlined,
              label: 'Exportar',
              onTap: onExport,
            ),
          ],
        ),
      ],
    );
  }
}

/// Diálogo de vista previa en "pantalla completa".
void showReportesFullPreview(
  BuildContext context, {
  required String tipo,
  required String dep,
  required Map<String, bool> checks,
  required Dep d,
}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: RC.card2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: RC.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reporte $tipo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: RC.t1,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: RC.hover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, size: 16, color: RC.t2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(dep, style: const TextStyle(fontSize: 12, color: RC.t2)),
              const SizedBox(height: 16),
              RepStatsGrid(stats: buildStats(d, checks)),
              const SizedBox(height: 14),
              RepMiniStat(
                label: 'Evolución del rendimiento',
                child: RepSparkline(points: d.spark, height: 70),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
