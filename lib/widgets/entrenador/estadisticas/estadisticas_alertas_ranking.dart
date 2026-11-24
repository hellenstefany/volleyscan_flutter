import 'package:flutter/material.dart';

import '../../../models/estadisticas_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../equipos/equipos_common_widgets.dart';
import 'estadisticas_tecnica_errores.dart';

export 'estadisticas_alertas_card.dart';

/// Tarjeta "Ranking de deportistas" con buscador, chips de estado y ordenamiento.
class EstadisticasRankingCard extends StatefulWidget {
  final List<CoachStatsRankingItem> lista;
  const EstadisticasRankingCard({super.key, required this.lista});

  @override
  State<EstadisticasRankingCard> createState() =>
      _EstadisticasRankingCardState();
}

class _EstadisticasRankingCardState extends State<EstadisticasRankingCard> {
  final _buscaCtrl = TextEditingController();
  String _estado = 'todos';
  String _sortKey = 'promedio:desc';

  @override
  void dispose() {
    _buscaCtrl.dispose();
    super.dispose();
  }

  List<CoachStatsRankingItem> get _filas {
    final q = _buscaCtrl.text.trim().toLowerCase();
    final filtered = widget.lista.where((d) {
      if (_estado != 'todos' && d.estado != _estado) return false;
      if (q.isNotEmpty && !d.nombreCompleto.toLowerCase().contains(q)) return false;
      return true;
    }).toList();

    final parts = _sortKey.split(':');
    final col = parts[0], dir = parts[1];
    filtered.sort((a, b) {
      if (col == 'nombre') {
        final cmp = a.nombreCompleto.toLowerCase().compareTo(b.nombreCompleto.toLowerCase());
        return dir == 'asc' ? cmp : -cmp;
      }
      num? valOf(CoachStatsRankingItem x) => switch (col) {
            'promedio' => x.promedio,
            'delta' => x.delta,
            'sesiones' => x.sesiones,
            'cumplimiento' => x.cumplimiento,
            'asistencia' => x.asistencia,
            'diasSinActividad' => x.diasSinActividad,
            _ => x.promedio,
          };
      final va = valOf(a), vb = valOf(b);
      if (va == null && vb == null) return 0;
      if (va == null) return 1;
      if (vb == null) return -1;
      final cmp = va.compareTo(vb);
      return dir == 'asc' ? cmp : -cmp;
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.lista;
    final filas = _filas;
    final counts = {
      'todos': lista.length,
      'activo': lista.where((d) => d.estado == 'activo').length,
      'inactivo': lista.where((d) => d.estado == 'inactivo').length,
      'sin_datos': lista.where((d) => d.estado == 'sin_datos').length,
    };

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
              const Text('Ranking de deportistas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DashColors.text1)),
              Text('${lista.length} ${lista.length == 1 ? 'deportista' : 'deportistas'}', style: const TextStyle(fontSize: 11.8, color: DashColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _buscaCtrl,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13, color: DashColors.text1),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: DashColors.bg,
                    prefixIcon: const Icon(Icons.search_rounded, size: 17, color: DashColors.textMuted),
                    hintText: 'Buscar deportista…',
                    hintStyle: const TextStyle(color: DashColors.text3, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DashColors.coachBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DashColors.blue)),
                  ),
                ),
              ),
              for (final e in const [('todos', 'Todos'), ('activo', 'Activos'), ('inactivo', 'Inactivos'), ('sin_datos', 'Sin datos')])
                ChoiceChip(
                  label: Text('${e.$2} (${counts[e.$1] ?? 0})'),
                  selected: _estado == e.$1,
                  onSelected: (_) => setState(() => _estado = e.$1),
                  selectedColor: DashColors.blue.withValues(alpha: 0.25),
                  backgroundColor: DashColors.bg,
                  labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _estado == e.$1 ? DashColors.accent2 : DashColors.textMuted),
                  side: BorderSide(color: _estado == e.$1 ? DashColors.blueLight : DashColors.coachBorder),
                ),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: DashColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: DashColors.coachBorder)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortKey,
                    dropdownColor: DashColors.cardDark,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DashColors.text1),
                    items: const [
                      DropdownMenuItem(value: 'promedio:desc', child: Text('Mejor puntuación')),
                      DropdownMenuItem(value: 'promedio:asc', child: Text('Menor puntuación')),
                      DropdownMenuItem(value: 'delta:desc', child: Text('Mayor mejora')),
                      DropdownMenuItem(value: 'delta:asc', child: Text('Mayor caída')),
                      DropdownMenuItem(value: 'sesiones:desc', child: Text('Más análisis')),
                      DropdownMenuItem(value: 'cumplimiento:desc', child: Text('Mejor cumplimiento')),
                      DropdownMenuItem(value: 'asistencia:desc', child: Text('Mejor asistencia')),
                      DropdownMenuItem(value: 'asistencia:asc', child: Text('Peor asistencia')),
                      DropdownMenuItem(value: 'diasSinActividad:asc', child: Text('Actividad reciente')),
                      DropdownMenuItem(value: 'nombre:asc', child: Text('Nombre (A–Z)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _sortKey = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Ningún deportista coincide. Prueba con otro nombre o quita el filtro.', style: TextStyle(fontSize: 13, color: DashColors.textMuted))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 740),
                child: Column(
                  children: [
                    _tableRow(
                      isHeader: true,
                      cells: const [
                        (220, Text('DEPORTISTA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted))),
                        (70, Center(child: Text('ANÁLISIS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                        (86, Center(child: Text('PUNTUACIÓN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                        (80, Center(child: Text('TENDENCIA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                        (92, Center(child: Text('RUTINAS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                        (92, Center(child: Text('ASISTENCIA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                        (95, Center(child: Text('ACTIVIDAD', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: DashColors.textMuted)))),
                      ],
                    ),
                    for (var i = 0; i < filas.length; i++) _buildRow(i + 1, filas[i]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(int pos, CoachStatsRankingItem d) {
    final act = d.diasSinActividad == null ? '—' : (d.diasSinActividad == 0 ? 'Hoy' : (d.diasSinActividad == 1 ? 'Ayer' : 'Hace ${d.diasSinActividad} d'));
    final deltaTxt = d.delta == null ? '—' : (d.delta == 0 ? '= 0' : '${d.delta! > 0 ? '▲' : '▼'} ${d.delta!.abs()}');
    final deltaColor = d.delta == null || d.delta == 0 ? DashColors.textMuted : (d.delta! > 0 ? DashColors.badgeRecepcionText : DashColors.warningText);

    return _tableRow(
      cells: [
        (
          220,
          Row(
            children: [
              SizedBox(width: 22, child: Text('$pos', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DashColors.textMuted))),
              EquipoAvatar(fotoUrl: d.fotoUrl, iniciales: d.iniciales, size: 30),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.nombreCompleto, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.8, fontWeight: FontWeight.w700, color: DashColors.text1)),
                    Text(
                      '${kEstadisticasEstados[d.estado] ?? d.estado}${d.posicion != null ? ' · ${d.posicion}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: DashColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        (70, Center(child: Text('${d.sesiones}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DashColors.text1)))),
        (86, Center(child: Text(d.promedio != null ? '${d.promedio}/100' : '—', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statsScoreColor(d.promedio))))),
        (80, Center(child: Text(deltaTxt, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: deltaColor)))),
        (92, Center(child: Text(d.cumplimiento != null ? '${d.cumplimiento}%' : 'Sin rutinas', style: const TextStyle(fontSize: 12.5, color: DashColors.textSecondary)))),
        (92, Center(child: Text(d.asistencia != null ? '${d.asistencia}%' : (d.eventosConLista > 0 ? 'Solo justif.' : 'Sin lista'), style: const TextStyle(fontSize: 12.5, color: DashColors.textSecondary)))),
        (95, Center(child: Text(act, style: const TextStyle(fontSize: 12.2, color: DashColors.textMuted)))),
      ],
    );
  }

  Widget _tableRow({required List<(double, Widget)> cells, bool isHeader = false}) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isHeader ? 8 : 9),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: DashColors.coachBorder.withValues(alpha: 0.7)))),
        child: Row(children: [for (final c in cells) SizedBox(width: c.$1, child: c.$2)]),
      );
}
