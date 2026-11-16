import 'package:flutter/material.dart';
import '../../../models/preferences_data.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/dash_colors.dart';
import '../shared/dash_card.dart';
import '../shared/form_action_buttons.dart';

/// Desplegable reutilizable (`.field-select` en `ControlesConfig.jsx`).
class SettingsDropdown extends StatelessWidget {
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  final bool expand;
  final bool small;

  const SettingsDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.expand = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue =
        options.containsKey(value) ? value : options.keys.first;
    return Container(
      height: 42,
      constraints: BoxConstraints(
        minWidth: expand ? double.infinity : (small ? 105 : 170),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: DashColors.border2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isExpanded: expand,
          dropdownColor: DashColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: DashColors.textMuted,
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: DashColors.textPrimary,
            fontSize: 13.5,
          ),
          items: [
            for (final entry in options.entries)
              DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Interruptor `.toggle-switch` de `ControlesConfig.jsx` con `AppGradients.settingsActive`.
class SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value ? AppGradients.settingsActive : null,
          color: value ? null : DashColors.switchTrackOff,
          borderRadius: BorderRadius.circular(24),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: DashColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila `.setting-row` de `ControlesConfig.jsx` (select o toggle).
class SettingsRow extends StatelessWidget {
  final String label;
  final String? description;
  final Widget control;
  final bool showBottomBorder;

  const SettingsRow({
    super.key,
    required this.label,
    required this.control,
    this.description,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: showBottomBorder
            ? const Border(bottom: BorderSide(color: DashColors.border))
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340 && description == null;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: DashColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: control),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: DashColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: DashColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              control,
            ],
          );
        },
      ),
    );
  }
}

/// Columna principal de `SeccionGeneral.jsx` (sin selector de Tema, comentado en Next).
class SettingsGeneralCard extends StatelessWidget {
  final PreferencesData data;
  final ValueChanged<PreferencesData> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;
  final bool canSave;

  const SettingsGeneralCard({
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
            'General',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: DashColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SettingsRow(
            label: 'Unidad de medida',
            control: SettingsDropdown(
              value: data.unidadMedida,
              options: PreferencesData.unidadLabels,
              onChanged: (v) => onChanged(data.copyWith(unidadMedida: v)),
            ),
          ),
          SettingsRow(
            label: 'Idioma',
            control: SettingsDropdown(
              value: data.idioma,
              options: PreferencesData.idiomaLabels,
              onChanged: (v) => onChanged(data.copyWith(idioma: v)),
            ),
          ),
          SettingsRow(
            label: 'Calidad de video para análisis',
            control: SettingsDropdown(
              value: data.calidadVideo,
              options: PreferencesData.calidadLabels,
              small: true,
              onChanged: (v) => onChanged(data.copyWith(calidadVideo: v)),
            ),
          ),
          SettingsRow(
            label: 'Guardar videos automáticamente',
            description: 'Los videos de análisis se guardan en tu historial',
            showBottomBorder: false,
            control: SettingsSwitch(
              value: data.guardarVideos,
              onChanged: (v) => onChanged(data.copyWith(guardarVideos: v)),
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
