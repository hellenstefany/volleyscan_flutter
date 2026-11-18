import 'package:flutter/material.dart';
import '../../../theme/entrenador_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Tarjeta "Información personal" (modo lectura / edición).
class PerfilInfoCard extends StatelessWidget {
  final bool isEditing;
  final Map<String, String> profile;
  final Map<String, TextEditingController> ctrl;
  final String level;
  final ValueChanged<String> onLevel;
  final VoidCallback onSave, onCancel;

  const PerfilInfoCard({
    super.key,
    required this.isEditing,
    required this.profile,
    required this.ctrl,
    required this.level,
    required this.onLevel,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: perfilCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PerfilCardHeader(
            icon: Icons.info_outline,
            title: 'Información personal',
            trailing: isEditing
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: EC.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✎ Modo edición',
                      style: TextStyle(fontSize: 11, color: EC.accent2),
                    ),
                  )
                : null,
          ),
          for (final c in kCampos)
            PerfilFormGroup(
              label: c.$1,
              child: isEditing
                  ? TextField(
                      controller: ctrl[c.$2],
                      keyboardType: c.$3,
                      style: const TextStyle(color: EC.text1, fontSize: 14),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(
                      c.$2 == 'experience'
                          ? '${profile[c.$2]} años'
                          : profile[c.$2]!,
                    ),
            ),
          PerfilFormGroup(
            label: 'Nivel',
            child: isEditing
                ? DropdownButtonFormField<String>(
                    value: level,
                    dropdownColor: EC.bgCard2,
                    style: const TextStyle(color: EC.text1, fontSize: 14),
                    decoration: perfilInputDeco(),
                    items: [
                      for (final n in kNiveles)
                        DropdownMenuItem(value: n, child: Text(n)),
                    ],
                    onChanged: (v) => onLevel(v ?? level),
                  )
                : PerfilValueText(profile['level']!),
          ),
          if (isEditing) ...[
            const SizedBox(height: 4),
            const Divider(color: EC.border, height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PerfilGradientButton(
                  icon: Icons.check,
                  label: 'Guardar cambios',
                  onTap: onSave,
                ),
                OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EC.text2,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    side: const BorderSide(color: EC.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
