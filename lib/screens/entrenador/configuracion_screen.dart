import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../../services/api_service.dart';

import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_danger_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_data.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_general_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_nav.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_notifications_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_security_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_team_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_theme_section.dart';
import 'package:volleyscan_mobile/widgets/entrenador/configuracion/config_topbar.dart';

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

  Map<String, dynamic> _v = configDefaults();
  Map<String, dynamic> _saved = configDefaults();

  void _set(String key, dynamic value) {
    setState(() {
      _v[key] = value;
      _dirty = true;
    });
  }

  void _toast(String icon, String msg, [Color color = ConfigTheme.accent]) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: ConfigTheme.panel2,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.6)),
        ),
        content: Row(
          children: [
            if (icon.isNotEmpty) ...[
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: ConfigTheme.text, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _reset() {
    setState(() {
      _v = configDefaults();
      _dirty = true;
    });
  }

  Future<void> _logout() async {
    _toast('👋', 'Sesión cerrada', ConfigTheme.danger);
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else {
      final nav = ApiService.navigatorKey.currentState ?? Navigator.of(context);
      await ApiService().cerrarSesionCompleta();
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildSection(double w) {
    switch (_section) {
      case 'seguridad':
        return ConfigSecuritySection(
          values: _v,
          onSet: _set,
          onToast: _toast,
          onDirty: _markDirty,
        );
      case 'tema':
        return ConfigThemeSection(values: _v, onSet: _set, onToast: _toast);
      case 'notificaciones':
        return ConfigNotificationsSection(values: _v, onSet: _set);
      case 'equipo':
        return ConfigTeamSection(onToast: _toast);
      case 'peligro':
        return ConfigDangerSection(onToast: _toast, onReset: _reset);
      default:
        return ConfigGeneralSection(
          width: w,
          values: _v,
          onSet: _set,
          onLogout: _logout,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outer) {
        // Ancho REAL disponible (respeta el límite de 480 px de main.dart)
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
                              child: SingleChildScrollView(
                                child: _buildSection(c.maxWidth),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      // abajo: espacio para la barra inferior
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
