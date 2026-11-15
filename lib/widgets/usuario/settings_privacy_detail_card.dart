import 'package:flutter/material.dart';
import '../../models/preferences_data.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'form_action_buttons.dart';
import 'settings_general_card.dart';

/// Sección "Privacidad" (`SeccionPrivacidad.jsx` en Next):
/// conectada a `visibilidad_analisis`, `permitir_comentarios` y `compartir_progreso`.
class SettingsPrivacyDetailCard extends StatelessWidget {
  final PreferencesData data;
  final ValueChanged<PreferencesData> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;
  final bool canSave;

  const SettingsPrivacyDetailCard({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onCancel,
    required this.onSave,
    this.saving = false,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacidad',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SettingsRow(
            label: 'Quién puede ver mis análisis',
            control: SettingsDropdown(
              value: data.visibilidadAnalisis,
              options: PreferencesData.visibilidadLabels,
              onChanged: (v) =>
                  onChanged(data.copyWith(visibilidadAnalisis: v)),
            ),
          ),
          SettingsRow(
            label: 'Permitir comentarios',
            description: 'Tu entrenador puede dejar comentarios en tus sesiones',
            control: SettingsSwitch(
              value: data.permitirComentarios,
              onChanged: (v) =>
                  onChanged(data.copyWith(permitirComentarios: v)),
            ),
          ),
          SettingsRow(
            label: 'Compartir progreso',
            description:
                'Muestra tu evolución semanal a quienes tengan acceso',
            showBottomBorder: false,
            control: SettingsSwitch(
              value: data.compartirProgreso,
              onChanged: (v) => onChanged(data.copyWith(compartirProgreso: v)),
            ),
          ),
          const SizedBox(height: 16),
          FormActionButtons(
            saving: saving,
            enabled: canSave,
            onCancel: onCancel,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}
