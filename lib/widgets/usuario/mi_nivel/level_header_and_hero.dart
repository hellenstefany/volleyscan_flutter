import 'package:flutter/material.dart';
import '../../../models/my_level_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Barra superior con botón del menú lateral y título "Mi nivel".
class LevelTopBar extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const LevelTopBar({super.key, required this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onOpenDrawer,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: DashColors.card,
                borderRadius: BorderRadius.circular(AppRadii.panel),
                border: Border.all(color: DashColors.border),
              ),
              child: const Icon(
                Icons.menu_rounded,
                size: 22,
                color: DashColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Mi nivel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: DashColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera de contenido (`.head` en `mi-nivel.module.css`).
class LevelPageHeader extends StatelessWidget {
  const LevelPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MI PROGRESO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: DashColors.accent2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Mi nivel',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: DashColors.text,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tu entrenador decide cuándo subes de nivel según cómo cumples y ejecutas tus rutinas.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.45,
              color: DashColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta principal con el nivel actual, cifras y escalera de 4 niveles (`.hero`).
class LevelHeroCard extends StatelessWidget {
  final MyLevelResponse data;

  const LevelHeroCard({super.key, required this.data});

  Color _colorForLevel(String nivel) {
    switch (nivel) {
      case 'intermedio':
        return DashColors.badgePrepText;
      case 'avanzado':
        return DashColors.badgeRecepcionText;
      case 'profesional':
        return DashColors.orange;
      case 'principiante':
      default:
        return DashColors.accent2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = myLevelSteps.indexOf(data.nivel);
    final levelColor = _colorForLevel(data.nivel);
    final avgText = data.calificacionPromedio != null
        ? formatDecimalComma(data.calificacionPromedio!)
        : '–';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DashColors.surface,
            DashColors.coachCard2,
          ],
        ),
        border: Border.all(color: DashColors.coachBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NIVEL ACTUAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: DashColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatLevelName(data.nivel),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: levelColor,
                    ),
                  ),
                  if (data.entrenador != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Entrenador: ${data.entrenador}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        color: DashColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeroMetric(
                    value: '${data.totalRevisadas}',
                    label: 'RUTINAS REVISADAS',
                  ),
                  const SizedBox(width: 24),
                  _HeroMetric(
                    value: avgText,
                    label: 'PROMEDIO',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: List.generate(myLevelSteps.length, (i) {
              final step = myLevelSteps[i];
              final isDone = idx >= 0 && i < idx;
              final isCurrent = i == idx;
              final stepColor = _colorForLevel(step);

              Color barColor = DashColors.textPrimary.withValues(alpha: 0.08);
              if (isCurrent) {
                barColor = stepColor;
              } else if (isDone) {
                barColor = stepColor.withValues(alpha: 0.80);
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < myLevelSteps.length - 1 ? 8 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: stepColor.withValues(alpha: 0.45),
                                    blurRadius: 14,
                                  ),
                                ]
                              : null,
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: DashColors.checkIconDark,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatLevelName(step).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isCurrent
                              ? stepColor
                              : (isDone ? DashColors.muted : DashColors.text3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: DashColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: DashColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Botón "Reintentar" para el estado de error.
class LevelErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const LevelErrorRetry({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: const Text(
        'Reintentar',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: DashColors.cardDark,
        foregroundColor: DashColors.textSecondary,
        side: const BorderSide(color: DashColors.coachBorder),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.btn),
        ),
      ),
    );
  }
}
