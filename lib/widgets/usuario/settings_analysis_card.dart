import 'package:flutter/material.dart';
import '../../models/preferences_data.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'settings_general_card.dart';

/// Sección "Análisis" (`SeccionAnalisis.jsx` en Next):
/// solo vive en estado local con la nota aclaratoria y sin botones de guardar.
class SettingsAnalysisCard extends StatelessWidget {
  final LocalAnalysisSettings data;
  final ValueChanged<LocalAnalysisSettings> onChanged;

  const SettingsAnalysisCard({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análisis',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estos ajustes se aplican mientras la página esté abierta.',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          SettingsRow(
            label: 'Detección de pose en tiempo real',
            description: 'Muestra el esqueleto de pose mientras grabas',
            control: SettingsSwitch(
              value: data.pose,
              onChanged: (v) => onChanged(data.copyWith(pose: v)),
            ),
          ),
          SettingsRow(
            label: 'Alertas de errores durante el análisis',
            description: 'Resalta en rojo las articulaciones con error',
            control: SettingsSwitch(
              value: data.alertas,
              onChanged: (v) => onChanged(data.copyWith(alertas: v)),
            ),
          ),
          SettingsRow(
            label: 'Análisis automático al subir video',
            description: 'Procesa el video sin confirmación adicional',
            control: SettingsSwitch(
              value: data.automatico,
              onChanged: (v) => onChanged(data.copyWith(automatico: v)),
            ),
          ),
          SettingsRow(
            label: 'Sensibilidad de detección',
            showBottomBorder: false,
            control: SettingsDropdown(
              value: data.sensibilidad,
              options: LocalAnalysisSettings.sensibilidadLabels,
              onChanged: (v) => onChanged(data.copyWith(sensibilidad: v)),
            ),
          ),
        ],
      ),
    );
  }
}
