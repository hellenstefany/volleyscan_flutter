import 'package:flutter/material.dart';
import '../../models/settings_data.dart';
import '../../theme/routine_colors.dart';
import 'settings_general_card.dart';

/// Tarjeta "Privacidad rápida" + botón Cerrar sesión.
class SettingsPrivacyCard extends StatelessWidget {
  final SettingsData data;
  final ValueChanged<SettingsData> onChanged;
  final VoidCallback onLogout;

  const SettingsPrivacyCard({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onLogout,
  });

  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RoutineColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacidad rápida',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Quién puede ver mis análisis',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 10),
          SettingsDropdown(
            expand: true,
            value: data.analysisVisibility,
            items: SettingsData.visibilityOptions,
            onChanged: (v) => onChanged(data.copyWith(analysisVisibility: v)),
          ),
          const SizedBox(height: 14),
          _switchRow(
            'Permitir comentarios',
            data.allowComments,
            (v) => onChanged(data.copyWith(allowComments: v)),
          ),
          _switchRow(
            'Compartir progreso',
            data.shareProgress,
            (v) => onChanged(data.copyWith(shareProgress: v)),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 20, color: _red),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: _red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _red,
                backgroundColor: const Color(0xFF0A1022),
                side: const BorderSide(color: Color(0xFF7F1D1D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        SettingsSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}
