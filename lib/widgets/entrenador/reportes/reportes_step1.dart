import 'package:flutter/material.dart';
import 'reportes_common_widget.dart';
import 'reportes_filters_panel.dart';
import 'reportes_model.dart';
import 'reportes_preview_card.dart';

/// Paso 1: filtros + vista previa rápida + botones.
class ReportesStep1 extends StatelessWidget {
  final String tipo, dep;
  final DateTime from, to;
  final Map<String, bool> checks;
  final Dep d;
  final ValueChanged<String> onTipo, onDep, onToggleCheck;
  final ValueChanged<bool> onPickDate;
  final VoidCallback onReset, onPreview;

  const ReportesStep1({
    super.key,
    required this.tipo,
    required this.dep,
    required this.from,
    required this.to,
    required this.checks,
    required this.d,
    required this.onTipo,
    required this.onDep,
    required this.onToggleCheck,
    required this.onPickDate,
    required this.onReset,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancho = c.maxWidth >= 800;
        final filtros = ReportesFiltersPanel(
          tipo: tipo,
          dep: dep,
          from: from,
          to: to,
          checks: checks,
          onTipo: onTipo,
          onDep: onDep,
          onToggleCheck: onToggleCheck,
          onPickDate: onPickDate,
        );
        final preview = ReportesPreviewCard(
          tipo: tipo,
          dep: dep,
          from: from,
          to: to,
          checks: checks,
          d: d,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ancho)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: filtros),
                  const SizedBox(width: 18),
                  Expanded(child: preview),
                ],
              )
            else ...[
              filtros,
              const SizedBox(height: 18),
              preview,
            ],
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                RepSecButton(
                  icon: Icons.restart_alt,
                  label: 'Restablecer',
                  onTap: onReset,
                ),
                RepPriButton(
                  icon: Icons.visibility,
                  label: 'Vista previa',
                  onTap: onPreview,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
