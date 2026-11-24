import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_filters_bar.dart';
import 'registro_row_card.dart';
import 'registro_rutinas_common.dart';

/// Pestaña "Registro": KPIs resumen, filtros y lista de rutinas completadas.
class RegistroRutinasTab extends StatelessWidget {
  final double width;
  final String estado;
  final int? atletaId;
  final String desde;
  final String hasta;
  final List<DeportistaNivelResumen> deportistas;
  final RegistroRutinasResponse? datos;
  final bool cargando;
  final String error;
  final ValueChanged<String> onEstado;
  final ValueChanged<int?> onAtleta;
  final ValueChanged<String> onDesde;
  final ValueChanged<String> onHasta;
  final VoidCallback onLimpiarFiltros;
  final VoidCallback onReintentar;
  final ValueChanged<int> onRevisar;

  const RegistroRutinasTab({
    super.key,
    required this.width,
    required this.estado,
    required this.atletaId,
    required this.desde,
    required this.hasta,
    required this.deportistas,
    required this.datos,
    required this.cargando,
    required this.error,
    required this.onEstado,
    required this.onAtleta,
    required this.onDesde,
    required this.onHasta,
    required this.onLimpiarFiltros,
    required this.onReintentar,
    required this.onRevisar,
  });

  @override
  Widget build(BuildContext context) {
    final r = datos?.resumen;
    final hayFiltro = atletaId != null || desde.isNotEmpty || hasta.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKpis(r),
        const SizedBox(height: 18),
        RegistroFiltersBar(
          estado: estado,
          atletaId: atletaId,
          desde: desde,
          hasta: hasta,
          hayFiltro: hayFiltro,
          deportistas: deportistas,
          onEstado: onEstado,
          onAtleta: onAtleta,
          onDesde: onDesde,
          onHasta: onHasta,
          onLimpiarFiltros: onLimpiarFiltros,
        ),
        const SizedBox(height: 18),
        if (error.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DashColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: DashColors.orange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(color: DashColors.warningText),
                  ),
                ),
                TextButton(
                  onPressed: onReintentar,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else if (cargando && datos == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: DashColors.blueLight),
                  SizedBox(height: 12),
                  Text(
                    'Cargando el registro…',
                    style: TextStyle(color: DashColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else if (datos != null && datos!.items.isEmpty)
          _buildEmpty(r, hayFiltro)
        else if (datos != null)
          Column(
            children: [
              for (final item in datos!.items) ...[
                RegistroRowCard(
                  item: item,
                  onRevisar: () => onRevisar(item.id),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildKpis(RegistroResumen? r) {
    final kpis = [
      (
        'Por revisar',
        r != null ? '${r.pendientes}' : '–',
        DashColors.warningText,
      ),
      (
        'Revisadas',
        r != null ? '${r.revisadas}' : '–',
        DashColors.successBadgeText,
      ),
      (
        'Calificación promedio',
        r?.calificacionPromedio != null
            ? regDec(r!.calificacionPromedio!)
            : '–',
        DashColors.text,
      ),
      (
        'Completadas a tiempo',
        r?.aTiempoPct != null ? '${r!.aTiempoPct}%' : '–',
        DashColors.text,
      ),
    ];
    const gap = 12.0;
    final cols = width >= 820 ? 4 : 2;
    final itemW = math.max(120.0, (width - gap * (cols - 1)) / cols);

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final k in kpis)
          SizedBox(
            width: itemW,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppGradients.coachCardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: DashColors.coachBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    k.$2,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: k.$3,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    k.$1.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                      color: DashColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty(RegistroResumen? r, bool hayFiltro) {
    final title = estado == 'pendientes'
        ? 'No tienes rutinas por revisar'
        : estado == 'revisadas'
            ? 'Aún no has revisado rutinas'
            : 'Todavía no hay rutinas completadas';
    final desc = (r != null && r.total == 0 && !hayFiltro)
        ? 'Cuando un deportista complete todos los ejercicios de una rutina que le asignaste, aparecerá aquí para que la observes.'
        : 'Prueba con otro estado o quita los filtros.';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
      decoration: BoxDecoration(
        color: DashColors.coachCard2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            size: 36,
            color: DashColors.accent2,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: DashColors.textMuted),
          ),
        ],
      ),
    );
  }
}
