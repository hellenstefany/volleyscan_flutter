import 'package:flutter/material.dart';

import '../../models/device_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';
import '../../widgets/entrenador/configuracion/config_confirm_dialog.dart';
import '../../widgets/entrenador/configuracion/config_danger_section.dart';
import '../../widgets/entrenador/configuracion/config_data.dart';
import '../../widgets/entrenador/configuracion/config_devices_card.dart';
import '../../widgets/entrenador/configuracion/config_general_section.dart';
import '../../widgets/entrenador/configuracion/config_nav.dart';
import '../../widgets/entrenador/configuracion/config_notifications_section.dart';
import '../../widgets/entrenador/configuracion/config_security_section.dart';
import '../../widgets/entrenador/configuracion/config_team_section.dart';
import '../../widgets/entrenador/configuracion/config_theme.dart';
import '../../widgets/entrenador/configuracion/config_theme_section.dart';
import '../../widgets/entrenador/configuracion/config_topbar.dart';
import '../login_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  /// Se llama al pulsar "Cerrar sesión". Úsalo para ir a tu LoginScreen.
  final VoidCallback? onLogout;

  const ConfiguracionScreen({super.key, this.onLogout});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  String _section = 'General';
  bool _dirty = false;
  bool _loggingOut = false;

  // TODO(backend): preferencias locales en memoria igual que Next
  // (`/panel_entrenador/configuracion/page.jsx`); `/api/usuario/configuracion/`
  // es exclusivo para atletas (`EsAtleta`).
  Map<String, dynamic> _v = configDefaults();
  Map<String, dynamic> _saved = configDefaults();

  // Dispositivos conectados reales (`/api/usuario/dispositivos/`)
  List<ConnectedDevice> _devices = const <ConnectedDevice>[];
  bool _loadingDevices = true;
  String _devicesError = '';
  int? _closingDeviceId;
  bool _closingOtherDevices = false;

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  Future<void> _cargarDispositivos() async {
    if (mounted) {
      setState(() {
        _loadingDevices = true;
        _devicesError = '';
      });
    }
    try {
      final list = await ApiService().listarDispositivos();
      if (!mounted) return;
      setState(() {
        _devices = list;
        _loadingDevices = false;
        _devicesError = '';
      });
    } on ApiException catch (e) {
      if (!mounted || e.isUnauthorized) return;
      setState(() {
        _loadingDevices = false;
        _devicesError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDevices = false;
        _devicesError = 'No se pudieron cargar los dispositivos conectados.';
      });
    }
  }

  Future<void> _cerrarDispositivo(ConnectedDevice device) async {
    if (_closingDeviceId != null || _closingOtherDevices) return;
    setState(() => _closingDeviceId = device.id);
    try {
      await ApiService().cerrarDispositivo(device.id);
      if (!mounted) return;
      setState(() {
        _devices = _devices.where((d) => d.id != device.id).toList();
      });
      showAppToast(context, 'Sesión cerrada en "${device.nombre}".');
    } catch (e) {
      if (!mounted) return;
      showConfigApiError(context, e, 'No se pudo cerrar el dispositivo.');
    } finally {
      if (mounted) setState(() => _closingDeviceId = null);
    }
  }

  Future<void> _cerrarOtrosDispositivos() async {
    if (_closingOtherDevices || _closingDeviceId != null) return;
    setState(() => _closingOtherDevices = true);
    try {
      final cerrados = await ApiService().cerrarOtrosDispositivos();
      if (!mounted) return;
      setState(() {
        _devices = _devices.where((d) => d.actual).toList();
      });
      showAppToast(
        context,
        cerrados > 0
            ? 'Se cerraron $cerrados sesiones en otros dispositivos.'
            : 'No había otras sesiones activas.',
      );
    } catch (e) {
      if (!mounted) return;
      showConfigApiError(context, e, 'No se pudieron cerrar las otras sesiones.');
    } finally {
      if (mounted) setState(() => _closingOtherDevices = false);
    }
  }

  void _set(String key, dynamic value) {
    setState(() {
      _v[key] = value;
      _dirty = true;
    });
  }

  void _toast(String icon, String msg, [Color color = ConfigTheme.accent]) {
    final type = color == ConfigTheme.danger
        ? 'error'
        : color == ConfigTheme.accent5
            ? 'success'
            : 'info';
    showAppToast(context, icon.isNotEmpty ? '$icon $msg' : msg, type: type);
  }

  void _saveAll() {
    setState(() {
      _saved = Map.of(_v);
      _dirty = false;
    });
    _toast('✅', 'Configuración guardada correctamente', ConfigTheme.accent5);
  }

  void _discard() {
    setState(() {
      _v = Map.of(_saved);
      _dirty = false;
    });
    _toast('↩', 'Cambios descartados', ConfigTheme.muted);
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    final ok = await showConfigConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Seguro que deseas cerrar tu sesión en este dispositivo?',
      confirmLabel: 'Cerrar sesión',
    );
    if (!ok || !mounted) return;
    setState(() => _loggingOut = true);
    if (widget.onLogout != null) {
      widget.onLogout!();
      return;
    }
    final nav = ApiService.navigatorKey.currentState ?? Navigator.of(context);
    await ApiService().cerrarSesionCompleta();
    if (mounted) showAppToast(context, '👋 Sesión cerrada', type: 'info');
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildSection(double w) {
    switch (_section) {
      case 'seguridad':
        return ConfigSecuritySection(
          values: _v,
          onSet: _set,
          onToast: _toast,
          onDirty: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          devices: _devices,
          loadingDevices: _loadingDevices,
          devicesError: _devicesError,
          closingDeviceId: _closingDeviceId,
          closingOtherDevices: _closingOtherDevices,
          onRetryDevices: _cargarDispositivos,
          onCloseDevice: _cerrarDispositivo,
          onCloseOtherDevices: _cerrarOtrosDispositivos,
        );
      case 'tema':
        return ConfigThemeSection(values: _v, onSet: _set, onToast: _toast);
      case 'notificaciones':
        return ConfigNotificationsSection(values: _v, onSet: _set);
      case 'equipo':
        return ConfigTeamSection(onToast: _toast);
      case 'peligro':
        return ConfigDangerSection(
          onToast: _toast,
          onReset: () => setState(() {
            _v = configDefaults();
            _dirty = true;
          }),
        );
      default:
        return ConfigGeneralSection(
          width: w,
          values: _v,
          onSet: _set,
          onLogout: _logout,
          loggingOut: _loggingOut,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outer) {
        final narrow = outer.maxWidth < 900;

        return Material(
          color: ConfigTheme.bg,
          child: Column(
            children: [
              ConfigTopbar(
                narrow: narrow,
                dirty: _dirty,
                onDiscard: _discard,
                onSave: _saveAll,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final wideLayout = c.maxWidth >= 760;
                    final pad = narrow ? 16.0 : 28.0;

                    if (wideLayout) {
                      return Padding(
                        padding: EdgeInsets.all(pad),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 180,
                              child: ConfigNav(
                                section: _section,
                                onSelect: (s) => setState(() => _section = s),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: RefreshIndicator(
                                color: DashColors.coachPurple,
                                onRefresh: _cargarDispositivos,
                                child: SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: _buildSection(c.maxWidth),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: DashColors.coachPurple,
                      onRefresh: _cargarDispositivos,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(pad, pad, pad, 110),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ConfigNav(
                              horizontal: true,
                              section: _section,
                              onSelect: (s) => setState(() => _section = s),
                            ),
                            const SizedBox(height: 16),
                            _buildSection(c.maxWidth),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
