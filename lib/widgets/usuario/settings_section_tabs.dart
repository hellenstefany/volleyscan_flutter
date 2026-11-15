import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import 'dash_card.dart';

class SettingsSection {
  final String id;
  final String label;
  final IconData icon;
  const SettingsSection(this.id, this.label, this.icon);
}

/// Secciones de Configuración idénticas a `SECCIONES` en `VolleyScan_Next/src/app/usuario/configuracion/page.jsx`.
const settingsSections = <SettingsSection>[
  SettingsSection('general', 'General', Icons.settings_rounded),
  SettingsSection('analisis', 'Análisis', Icons.videocam_rounded),
  SettingsSection(
    'notificaciones',
    'Notificaciones',
    Icons.notifications_rounded,
  ),
  SettingsSection('privacidad', 'Privacidad', Icons.lock_rounded),
  SettingsSection(
    'dispositivos',
    'Dispositivos',
    Icons.laptop_mac_rounded,
  ),
  SettingsSection('ayuda', 'Ayuda', Icons.help_outline_rounded),
];

/// Contenedor `.config-sidebar` / `.config-nav` de `configuracion.css`
/// con pestaña activa usando `AppGradients.settingsActive`.
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
    return DashCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppRadii.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'SECCIONES',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: DashColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < settingsSections.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  _SectionTabButton(
                    section: settingsSections[i],
                    active: settingsSections[i].id == selectedId,
                    onTap: () => onSelect(settingsSections[i].id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTabButton extends StatelessWidget {
  const _SectionTabButton({
    required this.section,
    required this.active,
    required this.onTap,
  });

  final SettingsSection section;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: active ? AppGradients.settingsActive : null,
            color: active ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                section.icon,
                size: 16,
                color: active
                    ? DashColors.textPrimary
                    : DashColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                section.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: active
                      ? DashColors.textPrimary
                      : DashColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
