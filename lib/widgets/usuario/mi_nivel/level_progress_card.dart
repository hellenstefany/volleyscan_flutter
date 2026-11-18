import 'package:flutter/material.dart';
import '../../../models/my_level_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Tarjeta de avance hacia el siguiente nivel, nivel máximo o sin entrenador (`.tarjeta`).
class LevelProgressCard extends StatelessWidget {
  final LevelAdvance? avance;

  const LevelProgressCard({super.key, required this.avance});

  @override
  Widget build(BuildContext context) {
    final av = avance;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.coachCardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: _buildBody(av),
    );
  }

  Widget _buildBody(LevelAdvance? av) {
    if (av == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aún no tienes entrenador',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Cuando tu entrenador acepte tu solicitud y te asigne rutinas, aquí verás tu avance hacia el siguiente nivel.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.45,
              color: DashColors.muted,
            ),
          ),
        ],
      );
    }

    if (av.siguiente == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nivel máximo',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Llegaste al nivel más alto de la plataforma. ¡Sigue así!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.45,
              color: DashColors.muted,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Qué te falta para ser ${formatLevelName(av.siguiente)}',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: DashColors.text,
          ),
        ),
        const SizedBox(height: 14),
        ...av.criterios.map((c) => _CriterionRow(criterion: c)),
        const SizedBox(height: 2),
        Text(
          av.sugerencia != null
              ? '¡Cumples todos los criterios! Tu entrenador evaluará tu ascenso.'
              : 'Cuenta desde tu último cambio de nivel. La decisión final siempre es de tu entrenador.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            height: 1.45,
            color: DashColors.muted,
          ),
        ),
      ],
    );
  }
}

class _CriterionRow extends StatelessWidget {
  final LevelCriterion criterion;

  const _CriterionRow({required this.criterion});

  String _formatNumber(double val) {
    if (criterion.clave == 'calificacion') {
      return formatDecimalComma(val);
    }
    return val == val.roundToDouble() ? '${val.toInt()}' : '$val';
  }

  @override
  Widget build(BuildContext context) {
    final c = criterion;
    final valorStr = c.valor == null
        ? 'Sin datos'
        : '${_formatNumber(c.valor!)}${c.clave == 'calificacion' ? '' : c.unidad}';
    final metaStr =
        '${_formatNumber(c.meta)}${c.clave == 'calificacion' ? '' : c.unidad}';
    final pct = c.percent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  c.titulo,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.5,
                    color: DashColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: valorStr,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: c.cumple
                            ? DashColors.badgeRecepcionText
                            : DashColors.text,
                      ),
                    ),
                    TextSpan(
                      text: ' · meta $metaStr',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: DashColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              width: double.infinity,
              color: DashColors.textPrimary.withValues(alpha: 0.08),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pct / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: c.cumple
                        ? const LinearGradient(
                            colors: [
                              DashColors.green,
                              DashColors.badgeRecepcionText,
                            ],
                          )
                        : AppGradients.coachPrimaryBtn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
