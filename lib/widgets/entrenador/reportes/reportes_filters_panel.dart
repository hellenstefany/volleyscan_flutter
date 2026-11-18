import 'package:flutter/material.dart';
import 'reportes_colors.dart';
import 'reportes_common_widget.dart';
import 'reportes_model.dart';

/// Panel de filtros (paso 1, columna izquierda).
class ReportesFiltersPanel extends StatelessWidget {
  final String tipo, dep;
  final DateTime from, to;
  final Map<String, bool> checks;
  final ValueChanged<String> onTipo, onDep, onToggleCheck;
  final ValueChanged<bool> onPickDate; // true = desde, false = hasta

  const ReportesFiltersPanel({
    super.key,
    required this.tipo,
    required this.dep,
    required this.from,
    required this.to,
    required this.checks,
    required this.onTipo,
    required this.onDep,
    required this.onToggleCheck,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: repBox(RC.card2, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RepFieldLabel('Tipo de reporte'),
          for (final t in kTiposReporte)
            RepRadioOpt(label: t, selected: tipo == t, onTap: () => onTipo(t)),
          const SizedBox(height: 18),
          if (tipo == 'Individual') ...[
            const RepFieldLabel('Deportista'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: RC.hover,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: RC.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dep,
                  isExpanded: true,
                  dropdownColor: RC.hover,
                  style: const TextStyle(color: RC.t1, fontSize: 13),
                  icon: const Icon(Icons.arrow_drop_down, color: RC.t2),
                  items: [
                    for (final k in kData.keys)
                      DropdownMenuItem(value: k, child: Text(k)),
                  ],
                  onChanged: (v) => onDep(v ?? dep),
                ),
              ),
            ),
          ],
          const RepFieldLabel('Rango de fechas'),
          Row(
            children: [
              Expanded(
                child: RepDateBox(
                  text: fmtDisp(from),
                  onTap: () => onPickDate(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RepDateBox(
                  text: fmtDisp(to),
                  onTap: () => onPickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const RepFieldLabel('Incluir'),
          for (final k in checks.keys)
            RepCheckOpt(
              label: k,
              value: checks[k]!,
              onTap: () => onToggleCheck(k),
            ),
        ],
      ),
    );
  }
}
