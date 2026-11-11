import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

/// Sección "Accesos rápidos" (`.quick-access` en `Dashboard.css`).
class DashboardQuickAccess extends StatelessWidget {
  final VoidCallback onStartAnalysis;
  final VoidCallback onViewHistory;
  final VoidCallback onDailyRoutine;
  final VoidCallback onExercises;

  const DashboardQuickAccess({
    super.key,
    required this.onStartAnalysis,
    required this.onViewHistory,
    required this.onDailyRoutine,
    required this.onExercises,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <_QuickBtnConfig>[
      _QuickBtnConfig(
        label: 'Iniciar análisis',
        icon: Icons.photo_camera_rounded,
        bgColor: DashColors.blueLight,
        textColor: Colors.white,
        onTap: onStartAnalysis,
      ),
      _QuickBtnConfig(
        label: 'Ver historial',
        icon: Icons.history_rounded,
        bgColor: DashColors.card,
        textColor: DashColors.textSecondary,
        borderColor: DashColors.border,
        onTap: onViewHistory,
      ),
      _QuickBtnConfig(
        label: 'Rutina del día',
        icon: Icons.event_available_rounded,
        bgColor: DashColors.green,
        textColor: Colors.white,
        onTap: onDailyRoutine,
      ),
      _QuickBtnConfig(
        label: 'Ejercicios',
        icon: Icons.fitness_center_rounded,
        bgColor: DashColors.purple,
        textColor: Colors.white,
        onTap: onExercises,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCESOS RÁPIDOS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: DashColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.dashCardGap),
        Row(
          children: [
            Expanded(child: _QuickButton(config: buttons[0])),
            const SizedBox(width: AppSpacing.dashCardGap),
            Expanded(child: _QuickButton(config: buttons[1])),
          ],
        ),
        const SizedBox(height: AppSpacing.dashCardGap),
        Row(
          children: [
            Expanded(child: _QuickButton(config: buttons[2])),
            const SizedBox(width: AppSpacing.dashCardGap),
            Expanded(child: _QuickButton(config: buttons[3])),
          ],
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final _QuickBtnConfig config;

  const _QuickButton({required this.config});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showAppToast(context, 'Abriendo: ${config.label}', type: 'info');
          config.onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: config.bgColor,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: config.borderColor != null
                ? Border.all(color: config.borderColor!)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(config.icon, size: 22, color: config.textColor),
              const SizedBox(height: 8),
              Text(
                config.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: config.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickBtnConfig {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _QuickBtnConfig({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });
}
