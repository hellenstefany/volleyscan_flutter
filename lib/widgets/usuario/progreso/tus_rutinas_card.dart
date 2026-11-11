import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Tus rutinas" (`Rutinas` en `MiProgreso.jsx`).
class TusRutinasCard extends StatelessWidget {
  final ProgresoRutinas rutinas;
  final VoidCallback onOpenRoutines;

  const TusRutinasCard({
    super.key,
    required this.rutinas,
    required this.onOpenRoutines,
  });

  @override
  Widget build(BuildContext context) {
    final asignadas = rutinas.asignadas;
    final completadas = rutinas.completadas;
    final ejerciciosTotal = rutinas.ejerciciosTotal;
    final ejerciciosHechos = rutinas.ejerciciosHechos;
    final porcentaje = rutinas.porcentaje;
    final sig = rutinas.siguiente;

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgresoCardHeader(
            title: 'Tus rutinas',
            tag: '$asignadas ${asignadas == 1 ? 'asignada' : 'asignadas'}',
          ),
          const SizedBox(height: AppSpacing.dashGap),
          if (asignadas == 0)
            const ProgresoEmptyBox(
              title: 'Aún no tienes rutinas',
              subtitle:
                  'Cuando tu entrenador te asigne una, verás aquí tu avance.',
            )
          else ...[
            Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (porcentaje.clamp(0, 100)) / 100,
                          strokeWidth: 7.5,
                          strokeCap: StrokeCap.round,
                          color: porcentaje >= 100
                              ? DashColors.green
                              : DashColors.blueLight,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: DashColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '$ejerciciosHechos',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: ' de $ejerciciosTotal ejercicios hechos',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: DashColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '$completadas',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: ' de $asignadas rutinas completas',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.dashGap),
            if (sig != null)
              InkWell(
                onTap: onOpenRoutines,
                borderRadius: BorderRadius.circular(AppRadii.btn),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: DashColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.btn),
                    border: Border.all(color: DashColors.border2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sig.nombre.isNotEmpty ? sig.nombre : 'Rutina',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${sig.hechos}/${sig.total} ejercicios',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    color: DashColors.textSecondary,
                                  ),
                                ),
                                if (sig.fecha != null) ...[
                                  const Text(
                                    ' · ',
                                    style: TextStyle(
                                      color: DashColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    sig.vencida
                                        ? 'Vencida (${formatFechaCorta(sig.fecha)})'
                                        : formatFechaCorta(sig.fecha),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.5,
                                      fontWeight: sig.vencida
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: sig.vencida
                                          ? DashColors.errorText
                                          : DashColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: DashColors.blueLight.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: DashColors.infoBadgeText,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                '🎉 Completaste todas tus rutinas asignadas.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: DashColors.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
