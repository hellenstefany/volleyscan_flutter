import 'package:flutter/material.dart';

import 'config_btn.dart';
import 'config_card.dart';
import 'config_data.dart';
import 'config_field_row.dart';
import 'config_section_header.dart';
import 'config_theme.dart';
import 'config_toggle.dart';

class ConfigSecuritySection extends StatelessWidget {
  final Map<String, dynamic> values;
  final ConfigSetter onSet;
  final ConfigToast onToast;

  /// Se llama cuando el usuario escribe en un campo de contraseña.
  final VoidCallback onDirty;

  const ConfigSecuritySection({
    super.key,
    required this.values,
    required this.onSet,
    required this.onToast,
    required this.onDirty,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Seguridad',
          'Protege tu cuenta con contraseñas seguras.',
        ),
        ConfigCard(
          title: 'Contraseña',
          children: [
            for (final l in const [
              'CONTRASEÑA ACTUAL',
              'NUEVA CONTRASEÑA',
              'CONFIRMAR CONTRASEÑA',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ConfigTheme.muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: ConfigTheme.panel2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ConfigTheme.border),
                      ),
                      child: TextField(
                        obscureText: true,
                        onChanged: (_) => onDirty(),
                        cursorColor: ConfigTheme.accent,
                        style: const TextStyle(
                          color: ConfigTheme.text,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: ConfigTheme.muted),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: ConfigBtn(
                label: 'Cambiar contraseña',
                style: ConfigBtnStyle.success,
                onTap: () => onToast(
                  '🔑',
                  'Contraseña actualizada correctamente',
                  ConfigTheme.accent5,
                ),
              ),
            ),
          ],
        ),
        ConfigCard(
          title: '📱 Autenticación de dos factores',
          children: [
            ConfigFieldRow(
              name: 'Activar 2FA',
              desc: 'Protección adicional al iniciar sesión',
              trailing: ConfigValueToggle(
                values: values,
                id: '2fa',
                onSet: onSet,
              ),
            ),
            ConfigFieldRow(
              name: '2FA por SMS',
              desc: 'Código vía mensaje de texto',
              trailing: ConfigValueToggle(
                values: values,
                id: '2faSms',
                onSet: onSet,
              ),
              last: true,
            ),
          ],
        ),
      ],
    );
  }
}
