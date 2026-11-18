import 'package:flutter/material.dart';
import 'reportes_colors.dart';
import 'reportes_common_widget.dart';
import 'reportes_model.dart';

// (id, ícono, color, título, descripción)
const _formatos = [
  ('pdf', Icons.picture_as_pdf, Color(0xFFF87171), 'PDF', 'Documento portátil'),
  ('csv', Icons.table_chart, Color(0xFF22D3A5), 'CSV', 'Hoja de cálculo'),
  ('json', Icons.code, Color(0xFF60A5FA), 'JSON', 'Datos estructurados'),
];

/// Paso 3: elegir formato y exportar (con barra de progreso).
class ReportesStep3 extends StatelessWidget {
  final String tipo, dep, fmt, fileName, progressLabel;
  final DateTime from, to;
  final int progress;
  final bool exporting, exportDone;
  final ValueChanged<String> onFmt;
  final VoidCallback onBack, onExport, onNew;

  const ReportesStep3({
    super.key,
    required this.tipo,
    required this.dep,
    required this.from,
    required this.to,
    required this.fmt,
    required this.fileName,
    required this.progress,
    required this.progressLabel,
    required this.exporting,
    required this.exportDone,
    required this.onFmt,
    required this.onBack,
    required this.onExport,
    required this.onNew,
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
              const Text(
                'Selecciona el formato de exportación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: RC.t1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$tipo · $dep · ${fmtDisp(from)} – ${fmtDisp(to)}',
                style: const TextStyle(fontSize: 12.5, color: RC.t2),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var i = 0; i < _formatos.length; i++) ...[
                    Expanded(child: _formatCard(_formatos[i])),
                    if (i < _formatos.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
              if (exporting) _progressView(),
              if (exportDone) _doneView(),
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
            if (!exportDone && !exporting)
              RepPriButton(
                icon: Icons.download,
                label: 'Exportar ahora',
                onTap: onExport,
                colors: const [RC.green2, RC.green],
              ),
            if (exportDone)
              RepSecButton(label: '+ Nuevo reporte', onTap: onNew),
          ],
        ),
      ],
    );
  }

  Widget _formatCard((String, IconData, Color, String, String) o) {
    final selected = fmt == o.$1;
    return InkWell(
      onTap: () => onFmt(o.$1),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? RC.purple2.withValues(alpha: 0.1) : RC.card2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? RC.purple2 : RC.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(o.$2, size: 26, color: o.$3),
            const SizedBox(height: 8),
            Text(
              o.$4,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: RC.t1,
              ),
            ),
            Text(
              o.$5,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: RC.t3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressView() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      children: [
        Text(
          progressLabel.isEmpty ? 'Generando reporte...' : progressLabel,
          style: const TextStyle(fontSize: 13, color: RC.t2),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: RC.hover,
            valueColor: const AlwaysStoppedAnimation(RC.purple2),
          ),
        ),
        const SizedBox(height: 12),
        Text('$progress%', style: const TextStyle(fontSize: 12, color: RC.t3)),
      ],
    ),
  );

  Widget _doneView() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 36, color: RC.green),
          const SizedBox(height: 10),
          const Text(
            '¡Reporte exportado!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: RC.t1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$fileName listo',
            style: const TextStyle(fontSize: 12.5, color: RC.t2),
          ),
        ],
      ),
    ),
  );
}
