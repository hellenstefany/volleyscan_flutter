import 'package:flutter/material.dart';
import '../../models/settings_data.dart';
import '../../theme/routine_colors.dart';

/// Desplegable compacto reutilizable en Configuración.
class SettingsDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool expand;

  const SettingsDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1022),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: expand,
          dropdownColor: RoutineColors.card,
          borderRadius: BorderRadius.circular(12),
          iconEnabledColor: Colors.white.withOpacity(0.6),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: [
            for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Interruptor con el estilo de la app.
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
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.all(Colors.white),
      activeTrackColor: RoutineColors.blue,
      inactiveTrackColor: const Color(0xFF374151),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    );
  }
}

class SettingsGeneralCard extends StatelessWidget {
  final SettingsData data;
  final ValueChanged<SettingsData> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;

  const SettingsGeneralCard({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onCancel,
    required this.onSave,
    this.saving = false,
  });

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
            'General',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _row(
            'Unidad de medida',
            SettingsDropdown(
              value: data.units,
              items: SettingsData.unitOptions,
              onChanged: (v) => onChanged(data.copyWith(units: v)),
            ),
            width: 170,
          ),
          _row(
            'Idioma',
            SettingsDropdown(
              value: data.language,
              items: SettingsData.languageOptions,
              onChanged: (v) => onChanged(data.copyWith(language: v)),
            ),
            width: 140,
          ),
          _row(
            'Tema',
            SettingsDropdown(
              value: data.theme,
              items: SettingsData.themeOptions,
              onChanged: (v) => onChanged(data.copyWith(theme: v)),
            ),
            width: 140,
          ),
          _row(
            'Calidad de video para análisis',
            SettingsDropdown(
              value: data.videoQuality,
              items: SettingsData.qualityOptions,
              onChanged: (v) => onChanged(data.copyWith(videoQuality: v)),
            ),
            width: 110,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Guardar videos automáticamente',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Los videos de análisis se guardan en tu historial',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SettingsSwitch(
                  value: data.autoSaveVideos,
                  onChanged: (v) => onChanged(data.copyWith(autoSaveVideos: v)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: saving ? null : onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0A1022),
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: saving ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Guardar cambios',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget control, {required double width}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: width, child: control),
        ],
      ),
    );
  }
}
