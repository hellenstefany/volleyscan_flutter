import 'package:flutter/material.dart';
import '../../../models/my_level_data.dart';
import '../../../models/registro_rutina_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import 'registro_rutinas_common.dart';

/// Tarjeta de nivel y criterios de ascenso de un deportista.
class RegistroNivelCard extends StatelessWidget {
  final DeportistaNivelResumen d;
  final VoidCallback onCambiarNivel;
  final VoidCallback onVerRegistro;

  const RegistroNivelCard({
    super.key,
    required this.d,
    required this.onCambiarNivel,
    required this.onVerRegistro,
  });

  @override
  Widget build(BuildContext context) {
    final a = d.avance;
    final idx = kNivelesOrden.indexOf(d.nivel);
    final sug = a.sugerencia != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sug
              ? DashColors.green.withValues(alpha: 0.45)
              : DashColors.coachBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RegAvatar(fotoUrl: d.fotoUrl, iniciales: d.iniciales, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.nombreCompleto,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DashColors.text,
                      ),
                    ),
                    Text(
                      d.ultimoCambio != null
                          ? 'Último cambio: ${regFormatFecha(d.ultimoCambio)}'
                          : 'Sin cambios de nivel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              RegChipNivel(nivel: d.nivel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < kNivelesOrden.length; i++) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: i <= idx
                              ? regNivelColor(kNivelesOrden[i]).withValues(
                                  alpha: i == idx ? 1.0 : 0.55,
                                )
                              : Colors.white.withValues(alpha: 0.09),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombreNivelRegistro(kNivelesOrden[i]),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: i == idx
                              ? regNivelColor(kNivelesOrden[i])
                              : i < idx
                                  ? DashColors.textMuted
                                  : DashColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < kNivelesOrden.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (a.siguiente != null) ...[
            Text(
              'AVANCE HACIA ${nombreNivelRegistro(a.siguiente).toUpperCase()}',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.9,
                color: DashColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            for (final c in a.criterios) _CriterioBar(c: c),
          ] else
            const Text(
              'Nivel máximo alcanzado.',
              style: TextStyle(fontSize: 13, color: DashColors.textMuted),
            ),
          if (sug) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: DashColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DashColors.green.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: DashColors.successBadgeText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cumple los criterios: listo para ${nombreNivelRegistro(a.siguiente)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DashColors.successBadgeText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(color: DashColors.coachBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onVerRegistro,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DashColors.textSecondary,
                    side: const BorderSide(color: DashColors.coachBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Ver registro${d.pendientesRevision > 0 ? ' · ${d.pendientesRevision}' : ''}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: sug
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.coachPrimaryBtn,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton(
                          onPressed: onCambiarNivel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Subir a ${nombreNivelRegistro(a.siguiente)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onCambiarNivel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DashColors.textSecondary,
                          side: const BorderSide(color: DashColors.coachBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cambiar nivel',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriterioBar extends StatelessWidget {
  final LevelCriterion c;
  const _CriterioBar({required this.c});

  @override
  Widget build(BuildContext context) {
    final valTxt = c.valor == null
        ? 'Sin datos'
        : c.clave == 'calificacion'
            ? regDec(c.valor!)
            : '${c.valor!.round()}${c.unidad}';
    final metaTxt = c.clave == 'calificacion'
        ? regDec(c.meta)
        : '${c.meta.round()}${c.unidad}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  c.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: DashColors.textSecondary,
                  ),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: valTxt,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.cumple
                            ? DashColors.badgeRecepcionText
                            : DashColors.text,
                      ),
                    ),
                    TextSpan(
                      text: ' · meta $metaTxt',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: DashColors.textMuted,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 12.5),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: c.percent / 100,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(
                c.cumple ? DashColors.green : DashColors.blueLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
