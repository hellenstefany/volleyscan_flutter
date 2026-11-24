import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/estadisticas_entrenador_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

Color statsScoreColor(int? score) {
  if (score == null) return DashColors.textMuted;
  if (score >= 80) return DashColors.badgeRecepcionText;
  if (score >= 60) return DashColors.accent2;
  if (score >= 40) return DashColors.amber;
  return DashColors.warningText;
}

/// Tarjeta "Por técnica" (`remate`, `saque`, `recepcion`, `bloqueo`, `pase`).
class EstadisticasPorTecnicaCard extends StatelessWidget {
  final List<CoachStatsTechnique> lista;
  const EstadisticasPorTecnicaCard({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    final hay = lista.any((t) => t.sesiones > 0);
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
            children: const [
              Expanded(
                child: Text(
                  'Por técnica',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DashColors.text1),
                ),
              ),
              Text('Puntuación media', style: TextStyle(fontSize: 11.5, color: DashColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          if (!hay)
            const _CardEmpty(
              title: 'Sin análisis por técnica',
              subtitle: 'Aparecerán cuando haya sesiones en el periodo.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < lista.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _TecnicaRow(item: lista[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _TecnicaRow extends StatelessWidget {
  final CoachStatsTechnique item;
  const _TecnicaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = statsScoreColor(item.promedio);
    final pct = ((item.promedio ?? 0) / 100.0).clamp(0.0, 1.0);
    final delta = item.delta;
    return Opacity(
      opacity: item.sesiones > 0 ? 1.0 : 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: DashColors.text1),
                ),
              ),
              Text(
                '${item.sesiones} análisis',
                style: const TextStyle(fontSize: 12, color: DashColors.textMuted),
              ),
              if (delta != null && delta != 0) ...[
                const SizedBox(width: 6),
                Text(
                  '${delta > 0 ? '▲' : '▼'} ${delta.abs()}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: delta > 0 ? DashColors.badgeRecepcionText : DashColors.warningText,
                  ),
                ),
              ],
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text(
                  item.promedio != null ? '${item.promedio}' : '—',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: DashColors.bg,
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta "Errores más frecuentes" detectados por la IA en el periodo.
class EstadisticasErroresCard extends StatelessWidget {
  final List<CoachStatsErrorItem> lista;
  const EstadisticasErroresCard({super.key, required this.lista});

  @override
  Widget build(BuildContext context) {
    final maxSes = lista.isEmpty
        ? 1
        : math.max(1, lista.map((e) => e.sesiones).reduce(math.max));

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
            children: const [
              Expanded(
                child: Text(
                  'Errores más frecuentes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: DashColors.text1),
                ),
              ),
              Text('Detectados por la IA', style: TextStyle(fontSize: 11.5, color: DashColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            const _CardEmpty(
              title: 'Sin errores registrados',
              subtitle: 'Los errores que detecte la IA en los análisis aparecerán aquí.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < lista.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _ErrorRow(index: i + 1, item: lista[i], maxSes: maxSes),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  final int index, maxSes;
  final CoachStatsErrorItem item;
  const _ErrorRow({required this.index, required this.item, required this.maxSes});

  @override
  Widget build(BuildContext context) {
    final sevColor = switch (item.severidad) {
      'grave' => DashColors.red,
      'moderado' => DashColors.orange,
      _ => DashColors.amber,
    };
    final sevText = kEstadisticasSeveridad[item.severidad] ?? item.severidad;
    final depTxt = '${item.atletas} ${item.atletas == 1 ? 'deportista' : 'deportistas'}';
    final vecTxt = '${item.ocurrencias} ${item.ocurrencias == 1 ? 'vez' : 'veces'}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DashColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DashColors.coachBorder),
          ),
          child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: DashColors.textMuted)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nombre,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.text1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(99)),
                    child: Text(sevText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sevColor)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (item.sesiones / maxSes).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: DashColors.bg,
                  valueColor: const AlwaysStoppedAnimation<Color>(DashColors.orange),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${item.sesiones} análisis · $depTxt · $vecTxt',
                style: const TextStyle(fontSize: 11.8, color: DashColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardEmpty extends StatelessWidget {
  final String title, subtitle;
  const _CardEmpty({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      decoration: BoxDecoration(
        color: DashColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.2, color: DashColors.textMuted)),
        ],
      ),
    );
  }
}
