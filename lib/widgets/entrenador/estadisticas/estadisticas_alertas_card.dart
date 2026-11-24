import 'package:flutter/material.dart';

import '../../../models/estadisticas_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';

/// Tarjeta "Requiere atención" con alertas ordenadas por prioridad.
class EstadisticasAlertasCard extends StatefulWidget {
  final List<CoachStatsAlertItem> lista;
  const EstadisticasAlertasCard({super.key, required this.lista});

  @override
  State<EstadisticasAlertasCard> createState() =>
      _EstadisticasAlertasCardState();
}

class _EstadisticasAlertasCardState extends State<EstadisticasAlertasCard> {
  bool _verTodas = false;

  @override
  Widget build(BuildContext context) {
    final ordenadas = List.of(widget.lista)
      ..sort((a, b) {
        final o = a.orden.compareTo(b.orden);
        return o != 0 ? o : a.nombre.compareTo(b.nombre);
      });
    final visibles = _verTodas ? ordenadas : ordenadas.take(6).toList();

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
          Row(
            children: [
              const Expanded(
                child: Text('Requiere atención', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DashColors.text1)),
              ),
              if (ordenadas.isNotEmpty) EquipoChip(text: '${ordenadas.length}', tone: EquipoChipTone.naranja),
            ],
          ),
          const SizedBox(height: 14),
          if (ordenadas.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              decoration: BoxDecoration(color: DashColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: DashColors.coachBorder)),
              child: const Column(
                children: [
                  Text('Todo en orden', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                  SizedBox(height: 4),
                  Text('Ningún deportista necesita atención ahora mismo.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.2, color: DashColors.textMuted)),
                ],
              ),
            )
          else ...[
            for (var i = 0; i < visibles.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _AlertaTile(item: visibles[i]),
            ],
            if (ordenadas.length > 6) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _verTodas = !_verTodas),
                  child: Text(
                    _verTodas ? 'Ver menos' : 'Ver las ${ordenadas.length} alertas',
                    style: const TextStyle(color: DashColors.accent2, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  final CoachStatsAlertItem item;
  const _AlertaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color c) = switch (item.tipo) {
      'baja' => (Icons.trending_down_rounded, DashColors.red),
      'inasistencia' => (Icons.person_off_rounded, DashColors.red),
      'inactivo' || 'sin_actividad' => (Icons.history_rounded, DashColors.orange),
      'asistencia_baja' => (Icons.person_off_rounded, DashColors.orange),
      'por_revisar' => (Icons.visibility_outlined, DashColors.blueLight),
      _ => (Icons.assignment_turned_in_outlined, DashColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.descripcion, style: const TextStyle(fontSize: 13, color: DashColors.text1, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
