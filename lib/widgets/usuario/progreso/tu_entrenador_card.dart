import 'package:flutter/material.dart';
import '../../../models/progreso_atleta_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../shared/dash_card.dart';
import 'progreso_shared.dart';

/// Tarjeta "Tu entrenador" (`Entrenador` en `MiProgreso.jsx`).
class TuEntrenadorCard extends StatelessWidget {
  final ProgresoEntrenador? entrenador;
  final VoidCallback? onOpenCoach;

  const TuEntrenadorCard({
    super.key,
    required this.entrenador,
    this.onOpenCoach,
  });

  @override
  Widget build(BuildContext context) {
    final e = entrenador;

    return DashCard(
      padding: AppSpacing.dashCardPadding,
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgresoCardHeader(title: 'Tu entrenador'),
          const SizedBox(height: AppSpacing.dashCardGap),
          if (e == null) ...[
            const Text(
              'Vincúlate con un entrenador para que vea tu progreso, revise tus sesiones y te asigne rutinas.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: DashColors.textSecondary,
              ),
            ),
            if (onOpenCoach != null) ...[
              const SizedBox(height: AppSpacing.dashCardGap),
              ElevatedButton.icon(
                onPressed: onOpenCoach,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DashColors.blueLight,
                  foregroundColor: DashColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                icon: const Icon(Icons.groups_rounded, size: 16),
                label: const Text(
                  'Buscar entrenador',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ] else ...[
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [DashColors.blueLight, DashColors.coachPurple],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(e.nombre),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: DashColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.dashGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.nombre.isNotEmpty ? e.nombre : 'Entrenador',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: DashColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: e.estado == 'aceptado'
                              ? DashColors.green.withValues(alpha: 0.14)
                              : DashColors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: e.estado == 'aceptado'
                                ? DashColors.green.withValues(alpha: 0.3)
                                : DashColors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          e.estado == 'aceptado'
                              ? 'VINCULADO'
                              : 'SOLICITUD ENVIADA',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: e.estado == 'aceptado'
                                ? DashColors.successBadgeText
                                : DashColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.dashCardGap),
            Text(
              e.estado == 'aceptado'
                  ? 'Ve tu progreso, revisa tus sesiones de análisis y te asigna rutinas.'
                  : 'Esperando que acepte tu solicitud. Te avisaremos cuando responda.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: DashColors.textSecondary,
              ),
            ),
            if (onOpenCoach != null) ...[
              const SizedBox(height: AppSpacing.dashCardGap),
              OutlinedButton(
                onPressed: onOpenCoach,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashColors.text,
                  side: const BorderSide(color: DashColors.border2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver mi entrenador',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 15),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }
}
