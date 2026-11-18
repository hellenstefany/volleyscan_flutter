import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'gestion_athlete.dart';
import 'gestion_colors.dart';
import 'gestion_common_widgets.dart';

String etiquetaPuntajeIa(int? n) {
  final v = n ?? 0;
  if (v >= 85) return 'Excelente';
  if (v >= 70) return 'Bueno';
  if (v >= 50) return 'Regular';
  return 'A mejorar';
}

String _uni(String? u) {
  if (u == null || u.isEmpty) return '';
  return u == '°' ? u : ' $u';
}

String _rango(List<double>? r, [String? u]) {
  if (r == null || r.length < 2) return '—';
  String fmt(double v) =>
      v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
  return '${fmt(r[0])}–${fmt(r[1])}${_uni(u)}';
}

/// Barra de rango ideal vs valor medido (`<RangoBarra>` en `HistorialIA.jsx`).
class DeportistaRangoBarra extends StatelessWidget {
  final double? valor;
  final List<double>? ideal;
  final bool ok;

  const DeportistaRangoBarra({
    super.key,
    required this.valor,
    required this.ideal,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    if (valor == null || ideal == null || ideal!.length < 2) {
      return const SizedBox.shrink();
    }
    final a = ideal![0];
    final b = ideal![1];
    final span = (b - a).abs() < 1e-6 ? 1e-6 : (b - a);
    final lo = a - span * 0.9;
    final hi = b + span * 0.9;
    double pos(double v) => ((v - lo) / (hi - lo)).clamp(0.0, 1.0);

    final startPct = pos(a);
    final widthPct = (pos(b) - startPct).clamp(0.02, 1.0);
    final valPct = pos(valor!);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return Container(
          height: 8,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: GestionColors.card2,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: w * startPct,
                width: w * widthPct,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: GestionColors.green.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Positioned(
                left: (w * valPct - 5).clamp(0.0, (w - 10).clamp(0.0, w)),
                top: -1,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ok ? GestionColors.green : GestionColors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: GestionColors.bg, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Panel de detalle de una sesión de análisis (`<article className={s.detalle}>` en `HistorialIA.jsx`).
class DeportistaSesionDetailCard extends StatelessWidget {
  final DeportistaSesionDetalle detalle;
  final int? repSeleccionada;
  final bool revisando;
  final ValueChanged<int> onSelectRep;
  final ValueChanged<bool> onToggleRevision;

  const DeportistaSesionDetailCard({
    super.key,
    required this.detalle,
    required this.repSeleccionada,
    required this.revisando,
    required this.onSelectRep,
    required this.onToggleRevision,
  });

  @override
  Widget build(BuildContext context) {
    final eval = detalle.evaluada;
    final durStr = formatDuracionSeg(detalle.duracionSeg);
    final reps = detalle.repeticiones;
    DeportistaRepeticion? repActiva;
    if (reps.isNotEmpty) {
      for (final r in reps) {
        if (r.numero == repSeleccionada) {
          repActiva = r;
          break;
        }
      }
      repActiva ??= reps.firstWhere(
        (r) => r.valida,
        orElse: () => reps.first,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── .dHead ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeportistaScoreRing(
                valor: detalle.puntuacion,
                size: 80,
                strokeWidth: 7,
                sinDato: !eval,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatFechaHoraDeportista(detalle.creadoEn),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: GestionColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (eval)
                          _MetaChip(
                            label: etiquetaPuntajeIa(detalle.puntuacion),
                            fg: colorNotaDeportista(detalle.puntuacion),
                          ),
                        _MetaChip(
                          label:
                              '${detalle.repeticionesValidas} de ${detalle.totalRepeticiones} remates medidos',
                        ),
                        if (durStr != null) _MetaChip(label: durStr),
                        if (detalle.nivel != null && detalle.nivel!.isNotEmpty)
                          _MetaChip(label: 'nivel ${detalle.nivel}'),
                        if (detalle.revisadoPorEntrenador)
                          _MetaChip(
                            label:
                                '✓ Revisada · ${formatFechaCortaDeportista(detalle.fechaRevision, includeYear: false)}',
                            fg: GestionColors.successText,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: revisando ? 0.6 : 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: revisando
                            ? null
                            : () => onToggleRevision(
                                  !detalle.revisadoPorEntrenador,
                                ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: detalle.revisadoPorEntrenador
                                ? null
                                : AppGradients.coachPrimaryBtn,
                            color: detalle.revisadoPorEntrenador
                                ? GestionColors.card
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: detalle.revisadoPorEntrenador
                                ? Border.all(color: GestionColors.border)
                                : null,
                          ),
                          child: Text(
                            detalle.revisadoPorEntrenador
                                ? 'Quitar revisión'
                                : 'Marcar como revisada',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: detalle.revisadoPorEntrenador
                                  ? GestionColors.text2
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!eval) ...[
            const SizedBox(height: 14),
            const Text(
              'En esta sesión no se pudo medir ningún remate (poca visibilidad del cuerpo o poca luz). Revisa el encuadre y vuelve a intentarlo.',
              style: TextStyle(fontSize: 13.5, color: GestionColors.muted),
            ),
          ],
          // ── Errores: Trabaja primero ──
          if (detalle.errores.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Trabaja primero',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: GestionColors.text,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Ordenado por los puntos que te costó cada error en esta sesión.',
              style: TextStyle(fontSize: 13, color: GestionColors.muted),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < detalle.errores.length; i++)
              _ErrorPrioItem(index: i + 1, error: detalle.errores[i]),
          ] else if (eval) ...[
            const SizedBox(height: 16),
            const Text(
              'Sin errores que corregir en esta sesión. ¡Buen trabajo!',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: GestionColors.successText,
              ),
            ),
          ],
          // ── Fortalezas: Lo que hizo bien ──
          if (detalle.fortalezas.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Lo que hizo bien',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: GestionColors.text,
              ),
            ),
            const SizedBox(height: 8),
            for (final f in detalle.fortalezas)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '✓ $f',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: GestionColors.successText,
                  ),
                ),
              ),
          ],
          // ── Medidas frente al ideal ──
          if (detalle.puntos.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Sus medidas frente al ideal',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: GestionColors.text,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'La banda verde es el rango correcto; el punto es su promedio.',
              style: TextStyle(fontSize: 13, color: GestionColors.muted),
            ),
            const SizedBox(height: 10),
            for (final p in detalle.puntos)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GestionColors.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GestionColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p.nombre,
                            style: const TextStyle(
                              fontSize: 13.2,
                              color: GestionColors.text2,
                            ),
                          ),
                        ),
                        Text(
                          '${p.valor ?? '—'}${_uni(p.unidad)}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: p.aprobado
                                ? GestionColors.successText
                                : GestionColors.warningText,
                          ),
                        ),
                      ],
                    ),
                    DeportistaRangoBarra(
                      valor: p.valor,
                      ideal: p.ideal,
                      ok: p.aprobado,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ideal',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: GestionColors.muted,
                          ),
                        ),
                        Text(
                          _rango(p.ideal, p.unidad),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: GestionColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
          // ── Remate por remate ──
          if (reps.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Remate por remate',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: GestionColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final r in reps)
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelectRep(r.numero),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: r.numero == repActiva?.numero
                            ? GestionColors.blue.withValues(alpha: 0.18)
                            : GestionColors.card2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: r.numero == repActiva?.numero
                              ? GestionColors.blue
                              : GestionColors.border,
                        ),
                      ),
                      child: Text(
                        '#${r.numero} ${r.valida ? '${r.puntuacion ?? '—'}' : '—'}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: r.valida
                              ? colorNotaDeportista(r.puntuacion)
                              : GestionColors.faint,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (repActiva != null) ...[
              const SizedBox(height: 10),
              _RepDetailBox(rep: repActiva),
            ],
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color? fg;

  const _MetaChip({required this.label, this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: GestionColors.muted.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg ?? GestionColors.text2,
        ),
      ),
    );
  }
}

class _ErrorPrioItem extends StatelessWidget {
  final int index;
  final DeportistaErrorDetectado error;

  const _ErrorPrioItem({required this.index, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GestionColors.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GestionColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '#$index',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: GestionColors.orange,
                ),
              ),
              Text(
                error.nombre ?? error.medidaId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GestionColors.text,
                ),
              ),
              if (error.severidad != null)
                _MetaChip(
                  label: error.severidad!,
                  fg: error.severidad == 'grave'
                      ? GestionColors.warningText
                      : GestionColors.text2,
                ),
              _MetaChip(
                label:
                    '${error.ocurrencias} ${error.ocurrencias == 1 ? 'vez' : 'veces'}',
              ),
            ],
          ),
          if (error.mensaje != null) ...[
            const SizedBox(height: 6),
            Text(
              error.mensaje!,
              style: const TextStyle(fontSize: 13.2, color: GestionColors.text2),
            ),
          ],
          if (error.valorPromedio != null && error.ideal != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promedio: ${error.valorPromedio}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: GestionColors.warningText,
                  ),
                ),
                Text(
                  'Ideal: ${_rango(error.ideal)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GestionColors.muted,
                  ),
                ),
              ],
            ),
            DeportistaRangoBarra(
              valor: error.valorPromedio,
              ideal: error.ideal,
              ok: false,
            ),
          ],
          if (error.porQue != null) ...[
            const SizedBox(height: 6),
            Text(
              'Por qué importa: ${error.porQue}',
              style: const TextStyle(fontSize: 12.8, color: GestionColors.muted),
            ),
          ],
          if (error.ejercicio != null) ...[
            const SizedBox(height: 4),
            Text(
              'Ejercicio: ${error.ejercicio}',
              style: const TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                color: GestionColors.blueLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepDetailBox extends StatelessWidget {
  final DeportistaRepeticion rep;

  const _RepDetailBox({required this.rep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GestionColors.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GestionColors.border),
      ),
      child: !rep.valida
          ? Text(
              'Remate descartado: ${rep.motivo ?? 'no se pudo medir'}.',
              style: const TextStyle(fontSize: 13, color: GestionColors.muted),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remate #${rep.numero}'
                  '${rep.brazo != null ? ' · brazo ${rep.brazo}' : ''}'
                  '${rep.confianza != null ? ' · confianza ${rep.confianza}' : ''}'
                  '${rep.fpsMedio != null ? ' · ${rep.fpsMedio} fps' : ''}',
                  style: const TextStyle(
                    fontSize: 12.8,
                    color: GestionColors.muted,
                  ),
                ),
                if (rep.principalMensaje != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Lo principal: ${rep.principalMensaje}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GestionColors.blueLight,
                    ),
                  ),
                ],
                for (final f in rep.fortalezas)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '✓ $f',
                      style: const TextStyle(
                        fontSize: 12.8,
                        color: GestionColors.successText,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
