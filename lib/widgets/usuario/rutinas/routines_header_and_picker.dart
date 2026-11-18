import 'package:flutter/material.dart';
import '../../../models/routine_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';

/// Barra superior con botón del menú lateral y título "Rutinas".
class RoutinesTopBar extends StatelessWidget {
  final VoidCallback onOpenDrawer;

  const RoutinesTopBar({super.key, required this.onOpenDrawer});

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
              'Mis rutinas',
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

/// Encabezado de página con título, subtítulo y contador de rutinas (`.top`).
class RoutinesPageHeader extends StatelessWidget {
  final int routineCount;

  const RoutinesPageHeader({super.key, required this.routineCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis rutinas',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: DashColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Entrenamiento personalizado asignado por tu entrenador',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  color: DashColors.muted,
                ),
              ),
            ],
          ),
          if (routineCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DashColors.blueLight.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: DashColors.blueLight.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                '$routineCount ${routineCount == 1 ? 'rutina' : 'rutinas'}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selector horizontal cuando el atleta tiene más de una rutina (`.picker`).
class RoutinePickerStrip extends StatelessWidget {
  final List<RoutineSummary> routines;
  final int selectedId;
  final ValueChanged<int> onSelect;

  const RoutinePickerStrip({
    super.key,
    required this.routines,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (routines.length <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: routines.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final r = routines[index];
            final selected = r.id == selectedId;
            final pct = r.porcentaje.clamp(0, 100);
            final complete = r.totalEjercicios > 0 && pct >= 100;

            return GestureDetector(
              onTap: () => onSelect(r.id),
              child: Container(
                width: 196,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? DashColors.blueLight.withValues(alpha: 0.16)
                      : DashColors.cardDark,
                  borderRadius: BorderRadius.circular(AppRadii.panel),
                  border: Border.all(
                    color: selected ? DashColors.blueLight : DashColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: DashColors.text,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            formatRoutineLevelLabel(r.nivel),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              color: DashColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          complete ? '✔ Completada' : '$pct%',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: complete
                                ? DashColors.green
                                : DashColors.muted,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: pct / 100.0,
                        minHeight: 4,
                        backgroundColor: DashColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          complete ? DashColors.green : DashColors.blueLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Estado vacío cuando el atleta aún no tiene rutinas asignadas (`.msg`).
class RoutinesEmptyState extends StatelessWidget {
  const RoutinesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: DashColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: DashColors.border2),
      ),
      child: const Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 38, color: DashColors.muted),
          SizedBox(height: 12),
          Text(
            'Aún no tienes rutinas asignadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cuando tu entrenador te asigne una, aparecerá aquí y recibirás un aviso.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              height: 1.45,
              color: DashColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de error con botón "Reintentar" (`.msg.err`).
class RoutinesErrorBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const RoutinesErrorBox({
    super.key,
    required this.title,
    this.subtitle = 'Revisa tu conexión e inténtalo de nuevo.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DashColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: DashColors.red.withValues(alpha: 0.40)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              color: DashColors.errorText,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
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
              foregroundColor: DashColors.cyan,
              side: BorderSide(color: DashColors.cyan.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.btn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
