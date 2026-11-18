import 'package:flutter/material.dart';

import '../../../theme/dash_colors.dart';
import 'perfil_common_widgets.dart';
import 'perfil_model.dart';

/// Tarjeta "Información personal" (`.info-card` en `page.jsx` / `Perfil.module.css`).
class PerfilInfoCard extends StatelessWidget {
  final bool isEditing;
  final bool loading;
  final bool saving;
  final EntrenadorPerfilData? profile;
  final TextEditingController nombreCtrl;
  final TextEditingController apellidoCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController clubCtrl;
  final TextEditingController experienceCtrl;
  final String level;
  final ValueChanged<String> onLevel;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const PerfilInfoCard({
    super.key,
    required this.isEditing,
    required this.loading,
    required this.saving,
    required this.profile,
    required this.nombreCtrl,
    required this.apellidoCtrl,
    required this.phoneCtrl,
    required this.clubCtrl,
    required this.experienceCtrl,
    required this.level,
    required this.onLevel,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final expValue = (p != null && p.experiencia.trim().isNotEmpty)
        ? '${p.experiencia.trim()} años'
        : '—';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: perfilCardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PerfilCardHeader(
            icon: Icons.info_outline_rounded,
            title: 'Información personal',
          ),
          if (loading && p == null)
            Column(
              children: List.generate(
                7,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: DashColors.hover,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            )
          else ...[
            // 1. Nombre
            PerfilFormGroup(
              label: 'Nombre',
              child: isEditing
                  ? TextField(
                      controller: nombreCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(p?.nombre ?? ''),
            ),
            // 2. Apellido
            PerfilFormGroup(
              label: 'Apellido',
              child: isEditing
                  ? TextField(
                      controller: apellidoCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(p?.apellido ?? ''),
            ),
            // 3. Correo electrónico (No editable)
            PerfilFormGroup(
              label: 'Correo electrónico (No editable)',
              child: PerfilValueText(
                p?.email ?? '',
                color: DashColors.textMuted,
              ),
            ),
            // 4. Teléfono
            PerfilFormGroup(
              label: 'Teléfono',
              child: isEditing
                  ? TextField(
                      controller: phoneCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(p?.telefono ?? ''),
            ),
            // 5. Club
            PerfilFormGroup(
              label: 'Club',
              child: isEditing
                  ? TextField(
                      controller: clubCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(p?.club ?? ''),
            ),
            // 6. Años de experiencia
            PerfilFormGroup(
              label: 'Años de experiencia',
              child: isEditing
                  ? TextField(
                      controller: experienceCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                    )
                  : PerfilValueText(expValue),
            ),
            // 7. Nivel
            PerfilFormGroup(
              label: 'Nivel',
              child: isEditing
                  ? DropdownButtonFormField<String>(
                      initialValue: normalizeCoachNivelValue(level),
                      dropdownColor: DashColors.card2,
                      style: const TextStyle(
                        color: DashColors.text1,
                        fontSize: 14,
                      ),
                      decoration: perfilInputDeco(),
                      items: [
                        for (final opt in kCoachNivelesOptions)
                          DropdownMenuItem(
                            value: opt.$1,
                            child: Text(opt.$2),
                          ),
                      ],
                      onChanged: saving
                          ? null
                          : (v) {
                              if (v != null) onLevel(v);
                            },
                    )
                  : PerfilValueText(p?.nivelEtiqueta ?? ''),
            ),
            if (isEditing) ...[
              const SizedBox(height: 4),
              const Divider(color: DashColors.border, height: 1),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  PerfilGradientButton(
                    icon: Icons.check_rounded,
                    label: 'Guardar cambios',
                    loading: saving,
                    onTap: onSave,
                  ),
                  OutlinedButton.icon(
                    onPressed: saving ? null : onCancel,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DashColors.textMuted,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      side: const BorderSide(color: DashColors.border),
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
        ],
      ),
    );
  }
}
