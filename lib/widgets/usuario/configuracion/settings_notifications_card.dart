import 'package:flutter/material.dart';
import '../../../models/preferences_data.dart';
import '../../../theme/dash_colors.dart';
import '../shared/dash_card.dart';
import '../shared/form_action_buttons.dart';
import 'settings_general_card.dart';

/// Sección "Notificaciones" (`SeccionNotificaciones.jsx` en Next):
/// conectada a los 3 switches reales de `configuracion` (`notif_sesion`, `notif_analisis`, `notif_contenido`).
class SettingsNotificationsCard extends StatelessWidget {
  final PreferencesData data;
  final ValueChanged<PreferencesData> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;
  final bool canSave;

  const SettingsNotificationsCard({
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
            'Notificaciones',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SettingsRow(
            label: 'Recordatorio de sesión',
            description: '30 min antes del entrenamiento',
            control: SettingsSwitch(
              value: data.notifSesion,
              onChanged: (v) => onChanged(data.copyWith(notifSesion: v)),
            ),
          ),
          SettingsRow(
            label: 'Análisis completado',
            description: 'Cuando la IA termine de procesar un análisis',
            control: SettingsSwitch(
              value: data.notifAnalisis,
              onChanged: (v) => onChanged(data.copyWith(notifAnalisis: v)),
            ),
          ),
          SettingsRow(
            label: 'Nuevos contenidos',
            description: 'Videos y ejercicios nuevos disponibles',
            showBottomBorder: false,
            control: SettingsSwitch(
              value: data.notifContenido,
              onChanged: (v) => onChanged(data.copyWith(notifContenido: v)),
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
