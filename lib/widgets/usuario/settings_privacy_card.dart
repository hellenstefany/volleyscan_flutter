import 'package:flutter/material.dart';
import '../../models/preferences_data.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';
import 'settings_general_card.dart';

/// Tarjeta lateral `.quick-privacy` de `SeccionGeneral.jsx` + botón "Cerrar sesión".
class SettingsPrivacyCard extends StatelessWidget {
  final PreferencesData data;
  final ValueChanged<PreferencesData> onChanged;
  final VoidCallback onLogout;

  const SettingsPrivacyCard({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacidad rápida',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Quién puede ver mis análisis',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SettingsDropdown(
            expand: true,
            value: data.visibilidadAnalisis,
            options: PreferencesData.visibilidadLabels,
            onChanged: (v) =>
                onChanged(data.copyWith(visibilidadAnalisis: v)),
          ),
          const SizedBox(height: 16),
          _quickToggle(
            label: 'Permitir comentarios',
            value: data.permitirComentarios,
            onChanged: (v) =>
                onChanged(data.copyWith(permitirComentarios: v)),
          ),
          const SizedBox(height: 14),
          _quickToggle(
            label: 'Compartir progreso',
            value: data.compartirProgreso,
            onChanged: (v) => onChanged(data.copyWith(compartirProgreso: v)),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: DashColors.border),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: DashColors.red,
              ),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: DashColors.red,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: DashColors.red,
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: DashColors.dangerOutlineBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SettingsSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
