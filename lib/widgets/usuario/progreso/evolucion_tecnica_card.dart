import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import '../sparkline.dart';
import 'progreso_shared.dart';

/// Tarjeta "Evolución de tu técnica" (`Evolucion` en `MiProgreso.jsx`).
/// Reutiliza `DashCard` y `Sparkline`.
class EvolucionTecnicaCard extends StatelessWidget {
  final ProgresoAnalisis analisis;
  final VoidCallback onStartAnalysis;

  const EvolucionTecnicaCard({
    super.key,
    required this.analisis,
    required this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final pts = analisis.evolucion;
    final values = pts.map((p) => p.puntuacion).toList();
    final variacion = analisis.variacion;

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgresoCardHeader(
            title: 'Evolución de tu técnica',
            tag: pts.isNotEmpty
                ? 'Últimas ${pts.length} sesiones'
                : 'Sin sesiones aún',
          ),
          const SizedBox(height: AppSpacing.dashGap),
          Row(
            children: [
              Expanded(
                child: _KpiBox(
                  value: '${analisis.promedio ?? '—'}',
                  label: 'Promedio',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiBox(
                  value: '${analisis.mejor ?? '—'}',
                  label: 'Mejor nota',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiBox(
                  value: '${analisis.sesiones}',
                  label: 'Sesiones',
                  delta: (variacion != null && variacion != 0)
                      ? '${variacion > 0 ? '+' : '−'}${variacion.abs()}'
                      : null,
                  deltaUp: (variacion ?? 0) > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.dashGap),
          if (values.length < 2)
            ProgresoEmptyBox(
              title: pts.isEmpty
                  ? 'Aún no tienes análisis'
                  : 'Falta una sesión más',
              subtitle: pts.isEmpty
                  ? 'Haz tu primera sesión con la IA para ver tu evolución.'
                  : 'Con dos sesiones ya se dibuja tu gráfica.',
              actionLabel: 'Iniciar análisis',
              actionIcon: Icons.photo_camera_rounded,
              onAction: onStartAnalysis,
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              decoration: BoxDecoration(
                color: DashColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.btn),
                border: Border.all(color: DashColors.border),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Sparkline(
                      values: values,
                      color: DashColors.blueLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatFechaCorta(pts.first.creadoEn),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: DashColors.textMuted,
                        ),
                      ),
                      Text(
                        'Última: ${values.last.round()}/100 · ${formatFechaCorta(pts.last.creadoEn)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: DashColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  final String value;
  final String label;
  final String? delta;
  final bool deltaUp;

  const _KpiBox({
    required this.value,
    required this.label,
    this.delta,
    this.deltaUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.btn),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: 4),
                Text(
                  delta!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: deltaUp ? DashColors.green : DashColors.deltaDown,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: DashColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
