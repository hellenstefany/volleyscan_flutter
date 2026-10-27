import 'package:flutter/material.dart';
import '../models/device_data.dart';
import '../models/settings_data.dart';
import '../theme/routine_colors.dart';
import '../widgets/usuario/settings_analysis_card.dart';
import '../widgets/usuario/settings_devices_card.dart';
import '../widgets/usuario/settings_general_card.dart';
import '../widgets/usuario/settings_help_card.dart';
import '../widgets/usuario/settings_notifications_card.dart';
import '../widgets/usuario/settings_privacy_card.dart';
import '../widgets/usuario/settings_privacy_detail_card.dart';
import '../widgets/usuario/settings_section_tabs.dart';
import '../widgets/usuario/menu_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // TODO: cargar los ajustes guardados del usuario.
  SettingsData _saved = SettingsData.defaults;
  late SettingsData _draft = _saved;

  String _section = 'general';
  bool _saving = false;

  // TODO: cargar los dispositivos reales del usuario.
  List<ConnectedDevice> _devices = ConnectedDevice.sample;

  void _cancel() => setState(() => _draft = _saved);

  Future<void> _save() async {
    setState(() => _saving = true);
    // TODO: enviar _draft al backend.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _saved = _draft;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada correctamente')),
    );
  }

  Future<bool> _confirm(String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RoutineColors.card,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _logoutDevice(ConnectedDevice device) async {
    final ok = await _confirm(
      'Cerrar sesión',
      '¿Cerrar la sesión en ${device.name}?',
    );
    if (!ok || !mounted) return;
    // TODO: revocar la sesión de este dispositivo en el backend.
    setState(
      () => _devices = _devices.where((d) => d.id != device.id).toList(),
    );
  }

  Future<void> _logoutAllDevices() async {
    final ok = await _confirm(
      'Cerrar sesión en todos',
      'Se cerrará la sesión en los demás dispositivos.',
    );
    if (!ok || !mounted) return;
    // TODO: revocar todas las sesiones excepto la actual en el backend.
    setState(() => _devices = _devices.where((d) => d.isCurrent).toList());
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: RoutineColors.card,
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Seguro que quieres salir?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      // TODO: limpiar sesión y volver al login, por ejemplo:
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (_) => const LoginScreen()),
      //   (route) => false,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RoutineColors.background,
      appBar: AppBar(
        backgroundColor: RoutineColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const MenuButton(),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      drawer: const UserDrawer(
        selectedId: 'notificaciones',
      ), // cambia el id en cada archivo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionTabs(
                selectedId: _section,
                onSelect: (id) => setState(() => _section = id),
              ),
              const SizedBox(height: 16),
              if (_section == 'general') ...[
                SettingsGeneralCard(
                  data: _draft,
                  saving: _saving,
                  onChanged: (d) => setState(() => _draft = d),
                  onCancel: _cancel,
                  onSave: _save,
                ),
                const SizedBox(height: 16),
                SettingsPrivacyCard(
                  data: _draft,
                  onChanged: (d) => setState(() => _draft = d),
                  onLogout: _logout,
                ),
              ] else if (_section == 'analisis')
                SettingsAnalysisCard(
                  data: _draft,
                  saving: _saving,
                  onChanged: (d) => setState(() => _draft = d),
                  onCancel: _cancel,
                  onSave: _save,
                )
              else if (_section == 'notificaciones')
                SettingsNotificationsCard(
                  data: _draft,
                  saving: _saving,
                  onChanged: (d) => setState(() => _draft = d),
                  onCancel: _cancel,
                  onSave: _save,
                )
              else if (_section == 'privacidad')
                SettingsPrivacyDetailCard(
                  data: _draft,
                  saving: _saving,
                  onChanged: (d) => setState(() => _draft = d),
                  onCancel: _cancel,
                  onSave: _save,
                )
              else if (_section == 'dispositivos')
                SettingsDevicesCard(
                  devices: _devices,
                  onLogoutDevice: _logoutDevice,
                  onLogoutAll: _logoutAllDevices,
                )
              else if (_section == 'ayuda')
                const SettingsHelpCard()
              else
                _comingSoon(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comingSoon() {
    final label = settingsSections.firstWhere((s) => s.id == _section).label;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: RoutineColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RoutineColors.border),
      ),
      child: Text(
        'Sección "$label" próximamente.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: RoutineColors.textMuted, fontSize: 14),
      ),
    );
  }
}
