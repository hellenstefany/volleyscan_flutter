import 'package:flutter/material.dart';
import '../../theme/routine_colors.dart';

class SettingsSection {
  final String id;
  final String label;
  final IconData icon;
  const SettingsSection(this.id, this.label, this.icon);
}

const settingsSections = <SettingsSection>[
  SettingsSection('general', 'General', Icons.settings_rounded),
  SettingsSection('analisis', 'Análisis', Icons.photo_camera_rounded),
  SettingsSection(
    'notificaciones',
    'Notificaciones',
    Icons.notifications_rounded,
  ),
  SettingsSection('privacidad', 'Privacidad', Icons.lock_rounded),
  SettingsSection(
    'dispositivos',
    'Dispositivos',
    Icons.desktop_windows_rounded,
  ),
  SettingsSection('ayuda', 'Ayuda', Icons.help_rounded),
];

/// Chips horizontales para cambiar de sección.
class SettingsSectionTabs extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelect;

  const SettingsSectionTabs({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: settingsSections.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = settingsSections[i];
          final active = s.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(s.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? RoutineColors.blue : RoutineColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? RoutineColors.blue : RoutineColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(s.icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    s.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
