import 'package:flutter/material.dart';

import '../../../models/device_data.dart';
import 'config_btn.dart';
import 'config_card.dart';
import 'config_data.dart';
import 'config_devices_card.dart';
import 'config_field_row.dart';
import 'config_section_header.dart';
import 'config_theme.dart';
import 'config_toggle.dart';

class ConfigSecuritySection extends StatefulWidget {
  final Map<String, dynamic> values;
  final ConfigSetter onSet;
  final ConfigToast onToast;
  final VoidCallback onDirty;
  final List<ConnectedDevice> devices;
  final bool loadingDevices;
  final String devicesError;
  final int? closingDeviceId;
  final bool closingOtherDevices;
  final VoidCallback onRetryDevices;
  final Future<void> Function(ConnectedDevice device) onCloseDevice;
  final Future<void> Function() onCloseOtherDevices;

  const ConfigSecuritySection({
    super.key,
    required this.values,
    required this.onSet,
    required this.onToast,
    required this.onDirty,
    required this.devices,
    required this.loadingDevices,
    required this.devicesError,
    required this.closingDeviceId,
    required this.closingOtherDevices,
    required this.onRetryDevices,
    required this.onCloseDevice,
    required this.onCloseOtherDevices,
  });

  @override
  State<ConfigSecuritySection> createState() => _ConfigSecuritySectionState();
}

class _ConfigSecuritySectionState extends State<ConfigSecuritySection> {
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _cambiarPassword() {
    final actual = _actualCtrl.text.trim();
    final nueva = _nuevaCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (actual.isEmpty || nueva.isEmpty || confirm.isEmpty) {
      widget.onToast('⚠️', 'Completa todos los campos de contraseña.', ConfigTheme.danger);
      return;
    }
    if (nueva.length < 8) {
      widget.onToast('⚠️', 'La nueva contraseña debe tener al menos 8 caracteres.', ConfigTheme.danger);
      return;
    }
    if (nueva != confirm) {
      widget.onToast('⚠️', 'Las contraseñas nuevas no coinciden.', ConfigTheme.danger);
      return;
    }

    // TODO(backend): conectar cuando exista endpoint de cambio de contraseña
    // para entrenador (en Backend_VolleyScan PUT /api/usuario/perfil/password/
    // exige EsAtleta y Next /panel_entrenador/configuracion también lo simula).
    _actualCtrl.clear();
    _nuevaCtrl.clear();
    _confirmCtrl.clear();
    widget.onToast('🔑', 'Contraseña actualizada correctamente', ConfigTheme.accent5);
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('CONTRASEÑA ACTUAL', _actualCtrl),
      ('NUEVA CONTRASEÑA', _nuevaCtrl),
      ('CONFIRMAR CONTRASEÑA', _confirmCtrl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ConfigSectionHeader(
          'Seguridad',
          'Protege tu cuenta con contraseñas seguras y administra tus sesiones.',
        ),
        ConfigCard(
          title: 'Contraseña',
          children: [
            for (final f in fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.$1,
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
                        controller: f.$2,
                        obscureText: true,
                        onChanged: (_) => widget.onDirty(),
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
                onTap: _cambiarPassword,
              ),
            ),
          ],
        ),
        ConfigDevicesCard(
          devices: widget.devices,
          loading: widget.loadingDevices,
          error: widget.devicesError,
          closingId: widget.closingDeviceId,
          closingOthers: widget.closingOtherDevices,
          onRetry: widget.onRetryDevices,
          onCloseDevice: widget.onCloseDevice,
          onCloseOthers: widget.onCloseOtherDevices,
        ),
        ConfigCard(
          title: '📱 Autenticación de dos factores',
          children: [
            // TODO(backend): 2FA simulado igual que en Next.
            ConfigFieldRow(
              name: 'Activar 2FA',
              desc: 'Protección adicional al iniciar sesión',
              trailing: ConfigValueToggle(
                values: widget.values,
                id: '2fa',
                onSet: widget.onSet,
              ),
            ),
            ConfigFieldRow(
              name: '2FA por SMS',
              desc: 'Código vía mensaje de texto',
              trailing: ConfigValueToggle(
                values: widget.values,
                id: '2faSms',
                onSet: widget.onSet,
              ),
              last: true,
            ),
          ],
        ),
      ],
    );
  }
}
