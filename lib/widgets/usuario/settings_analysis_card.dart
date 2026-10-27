import 'package:flutter/material.dart';
import '../../models/settings_data.dart';
import '../../theme/routine_colors.dart';
import 'settings_general_card.dart';

/// Sección "Análisis" de Configuración.
class SettingsAnalysisCard extends StatelessWidget {
  final SettingsData data;
  final ValueChanged<SettingsData> onChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool saving;

  const SettingsAnalysisCard({
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
            'Análisis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _switchRow(
            title: 'Detección de pose en tiempo real',
            subtitle: 'Muestra el esqueleto de pose mientras grabas',
            value: data.poseDetection,
            onChanged: (v) => onChanged(data.copyWith(poseDetection: v)),
          ),
          _switchRow(
            title: 'Alertas de errores durante análisis',
            subtitle: 'Resalta en rojo las articulaciones con error',
            value: data.errorAlerts,
            onChanged: (v) => onChanged(data.copyWith(errorAlerts: v)),
          ),
          _switchRow(
            title: 'Análisis automático al subir video',
            subtitle: 'Procesa el video sin confirmación adicional',
            value: data.autoAnalysis,
            onChanged: (v) => onChanged(data.copyWith(autoAnalysis: v)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sensibilidad de detección',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 190,
                  child: SettingsDropdown(
                    expand: true,
                    value: data.sensitivity,
                    items: SettingsData.sensitivityOptions,
                    onChanged: (v) => onChanged(data.copyWith(sensitivity: v)),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SettingsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
