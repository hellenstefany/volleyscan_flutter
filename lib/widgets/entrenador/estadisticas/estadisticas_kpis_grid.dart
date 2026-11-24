import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/estadisticas_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Grid de 6 tarjetas KPI de Estadísticas del Entrenador.
class EstadisticasKpisGrid extends StatelessWidget {
  final CoachStatsKpis kpis;
  final List<CoachStatsPoint> evolucion;
  final double width;

  const EstadisticasKpisGrid({
    super.key,
    required this.kpis,
    required this.evolucion,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cols = width >= 1060 ? 3 : (width >= 600 ? 2 : 1);
    final cards = <Widget>[
      _KpiCard(
        icon: Icons.groups_rounded,
        accent: DashColors.blueLight,
        label: 'Deportistas activos',
        value: '${kpis.activos}',
        unit: '/ ${kpis.deportistas}',
        footer: const _DeltaText(text: 'Con actividad en el periodo'),
      ),
      _KpiCard(
        icon: Icons.track_changes_rounded,
        accent: DashColors.teal,
        label: 'Análisis de IA',
        value: '${kpis.analisis}',
        footer: _DeltaBadge(valor: kpis.analisisDelta),
        sparkValues: [for (final p in evolucion) p.sesiones.toDouble()],
        sparkColor: DashColors.teal,
      ),
      _KpiCard(
        icon: Icons.show_chart_rounded,
        accent: DashColors.green,
        label: 'Puntuación media',
        value: kpis.puntuacionMedia != null ? '${kpis.puntuacionMedia}' : '—',
        unit: kpis.puntuacionMedia != null ? '/100' : null,
        footer: _DeltaBadge(valor: kpis.puntuacionDelta, unit: ' pts'),
        sparkValues: [for (final p in evolucion) p.promedio?.toDouble()],
        sparkColor: DashColors.green,
      ),
      _KpiCard(
        icon: Icons.fact_check_rounded,
        accent: DashColors.amber,
        label: 'Cumplimiento de rutinas',
        value: kpis.cumplimiento != null ? '${kpis.cumplimiento}' : '—',
        unit: kpis.cumplimiento != null ? '%' : null,
        footer: kpis.ejerciciosTotales > 0
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeltaBadge(
                    valor: kpis.cumplimientoDelta,
                    unit: ' pts',
                    emptyText: '${kpis.ejerciciosHechos} de ${kpis.ejerciciosTotales} ejercicios',
                  ),
                  if (kpis.cumplimientoDelta != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${kpis.ejerciciosHechos} de ${kpis.ejerciciosTotales} ejercicios',
                        style: const TextStyle(fontSize: 11.5, color: DashColors.textMuted),
                      ),
                    ),
                ],
              )
            : const _DeltaText(text: 'Sin rutinas en el periodo'),
      ),
      _KpiCard(
        icon: Icons.how_to_reg_rounded,
        accent: DashColors.teal,
        label: 'Asistencia',
        value: kpis.asistencia != null ? '${kpis.asistencia}' : '—',
        unit: kpis.asistencia != null ? '%' : null,
        footer: kpis.asistencia != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DeltaBadge(
                    valor: kpis.asistenciaDelta,
                    unit: ' pts',
                    emptyText: '${kpis.asistenciaPresentes} asistencias',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${kpis.asistenciaPresentes} asistió · ${kpis.asistenciaAusencias} faltó',
                      style: const TextStyle(fontSize: 11.5, color: DashColors.textMuted),
                    ),
                  ),
                ],
              )
            : const _DeltaText(text: 'Sin listas pasadas'),
      ),
      _KpiCard(
        icon: Icons.visibility_rounded,
        accent: DashColors.orange,
        label: 'Análisis por revisar',
        value: '${kpis.porRevisar}',
        footer: _DeltaText(text: kpis.porRevisar > 0 ? 'Esperan tu revisión' : 'Estás al día'),
      ),
    ];

    if (cols == 1) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += cols) {
      final slice = cards.skip(i).take(cols).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < slice.length; j++) ...[
                if (j > 0) const SizedBox(width: 12),
                Expanded(child: slice[j]),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          rows[i],
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String label, value;
  final String? unit;
  final Widget footer;
  final List<double?>? sparkValues;
  final Color? sparkColor;

  const _KpiCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.unit,
    required this.footer,
    this.sparkValues,
    this.sparkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 15, color: accent),
              ),
              const SizedBox(width: 9),
              Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: DashColors.textMuted))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: value,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: DashColors.text1, height: 1.05),
                    children: [
                      if (unit != null) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DashColors.textMuted)),
                    ],
                  ),
                ),
              ),
              if (sparkValues != null && sparkColor != null)
                SizedBox(
                  width: 84,
                  height: 28,
                  child: CustomPaint(painter: _SparkPainter(sparkValues!, sparkColor!)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _DeltaText extends StatelessWidget {
  final String text;
  const _DeltaText({required this.text});

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, color: DashColors.textMuted));
}

class _DeltaBadge extends StatelessWidget {
  final int? valor;
  final String unit, emptyText;
  const _DeltaBadge({required this.valor, this.unit = '', this.emptyText = 'Sin periodo previo'});

  @override
  Widget build(BuildContext context) {
    final v = valor;
    if (v == null) return _DeltaText(text: emptyText);
    if (v == 0) return const _DeltaText(text: '= Igual que antes');
    final up = v > 0;
    final fg = up ? DashColors.badgeRecepcionText : DashColors.warningText;
    final sign = up ? '+$v' : '$v';
    return Text('${up ? '▲' : '▼'} $sign$unit vs. periodo anterior', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg));
  }
}

class _SparkPainter extends CustomPainter {
  final List<double?> values;
  final Color color;
  _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = <(int, double)>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v != null) pts.add((i, v));
    }
    if (pts.length < 2) return;
    final n = math.max(1, values.length - 1);
    final top = math.max(1.0, pts.map((e) => e.$2).reduce(math.max));
    final path = Path();
    for (var k = 0; k < pts.length; k++) {
      final x = (pts[k].$1 / n) * size.width;
      final y = size.height - 3 - (pts[k].$2 / top) * (size.height - 6);
      if (k == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values || old.color != color;
}
