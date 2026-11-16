import 'package:flutter/material.dart';
import '../../../models/dashboard_data.dart';
import '../../../screens/login_screen.dart';
import '../../../services/api_service.dart';
import '../../../theme/dash_colors.dart';
import '../../../utils/drawer_router.dart';
import 'drawer_components.dart';

/// Menú lateral (sidebar) del panel de usuario replicando
/// `VolleyScan_Next/src/app/components/SidebarUsuario.jsx` y `SidebarUsuario.css`.
class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({
    super.key,
    this.userName = '',
    this.photoUrl,
    this.userRole,
    this.selectedId = 'dashboard',
    this.onSelect,
  });

  final String userName;
  final String? photoUrl;
  final String? userRole;
  final String selectedId;
  final ValueChanged<String>? onSelect;

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  String _sessionName = '';
  String? _sessionPhoto;
  String _sessionRole = 'atleta';
  int _sinLeer = 0;

  static const _sections = <DrawerSection>[
    DrawerSection('Principal', [
      DrawerItem('dashboard', 'Dashboard', Icons.home_rounded),
      DrawerItem('perfil', 'Perfil', Icons.person_rounded),
      DrawerItem('entrenador', 'Mi entrenador', Icons.badge_rounded),
      DrawerItem('equipos', 'Mis equipos', Icons.groups_rounded),
      DrawerItem('horario', 'Horario', Icons.calendar_month_rounded),
      DrawerItem('partidos', 'Mis partidos', Icons.emoji_events_rounded),
    ]),
    DrawerSection('Entrenamiento', [
      DrawerItem('rutinas', 'Rutinas', Icons.fitness_center_rounded),
      DrawerItem('mi_nivel', 'Mi nivel', Icons.military_tech_rounded),
      DrawerItem('historial', 'Historial', Icons.description_rounded),
      DrawerItem('contenido', 'Contenido', Icons.memory_rounded),
    ]),
    DrawerSection('Analisis', [
      DrawerItem('progreso', 'Progreso', Icons.show_chart_rounded),
      DrawerItem('analisis_ia', 'Analisis IA', Icons.photo_camera_rounded),
      DrawerItem(
        'historial_ia',
        'Historial de IA',
        Icons.photo_camera_outlined,
      ),
      DrawerItem(
        'notificaciones',
        'Notificaciones',
        Icons.notifications_rounded,
      ),
    ]),
    DrawerSection('Sistema', [
      DrawerItem('configuracion', 'Configuracion', Icons.settings_rounded),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _loadSessionUser();
  }

  Future<void> _loadSessionUser() async {
    try {
      final u = await ApiService.getUsuario();
      if (!mounted) return;
      if (u != null) {
        final nombre = (u['nombre'] ?? '').toString().trim();
        final apellido = (u['apellido'] ?? '').toString().trim();
        final full = [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
        final foto = u['foto_url']?.toString().trim();
        final rol = (u['rol'] ?? '').toString().trim();
        setState(() {
          if (full.isNotEmpty) _sessionName = full;
          if (foto != null && foto.isNotEmpty) _sessionPhoto = foto;
          if (rol.isNotEmpty) _sessionRole = rol;
        });
      }
      final c = await ApiService()
          .contadorAvisos(todas: true)
          .catchError((_) => const AvisosContadorResponse(noLeidas: 0));
      if (mounted && c.noLeidas > 0) {
        setState(() => _sinLeer = c.noLeidas);
      }
    } catch (_) {}
  }

  String get _effectiveName {
    if (_sessionName.isNotEmpty) return _sessionName;
    if (widget.userName.trim().isNotEmpty) return widget.userName.trim();
    return 'Usuario';
  }

  String? get _effectivePhoto =>
      (widget.photoUrl != null && widget.photoUrl!.trim().isNotEmpty)
          ? widget.photoUrl
          : _sessionPhoto;

  String get _effectiveRole {
    if (widget.userRole != null && widget.userRole!.trim().isNotEmpty) {
      return widget.userRole!.trim();
    }
    return _sessionRole;
  }

  bool _isActive(String id) {
    if (id == widget.selectedId) return true;
    if (id == 'dashboard' && widget.selectedId == 'panel') return true;
    if (id == 'panel' && widget.selectedId == 'dashboard') return true;
    if (id == 'analisis_ia' && widget.selectedId == 'analisis') return true;
    if (id == 'analisis' && widget.selectedId == 'analisis_ia') return true;
    if (id == 'historial_ia' && widget.selectedId == 'histtrial') return true;
    if (id == 'histtrial' && widget.selectedId == 'historial_ia') return true;
    return false;
  }

  void _onItemTap(DrawerItem item) {
    Scaffold.maybeOf(context)?.closeDrawer();
    if (widget.onSelect != null) {
      widget.onSelect!(item.id);
    } else {
      goToMenuItem(
        context,
        item.id,
        current: widget.selectedId,
        userName: _effectiveName,
      );
    }
  }

  Future<void> _handleLogout() async {
    final nav = ApiService.navigatorKey.currentState ?? Navigator.of(context);
    Scaffold.maybeOf(context)?.closeDrawer();
    try {
      await ApiService().cerrarSesionCompleta();
    } catch (_) {}
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: DashColors.sidebarBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            const DashboardDrawerHeader(),
            const Divider(height: 1, color: DashColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                children: [
                  for (final section in _sections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                      child: Text(
                        section.title.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: DashColors.text3,
                        ),
                      ),
                    ),
                    for (final item in section.items)
                      DrawerNavItemTile(
                        item: item,
                        isActive: _isActive(item.id),
                        onTap: () => _onItemTap(item),
                        badgeCount:
                            item.id == 'notificaciones' ? _sinLeer : 0,
                      ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: DashColors.border),
            DashboardDrawerFooter(
              name: _effectiveName,
              photoUrl: _effectivePhoto,
              role: _effectiveRole,
              onLogout: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
