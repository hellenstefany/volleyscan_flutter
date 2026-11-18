import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/profile_data.dart';
import '../../screens/login_screen.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/dash_colors.dart';

class _NavItem {
  final String id, label;
  final FaIconData icon;
  const _NavItem(this.id, this.icon, this.label);
}

class _NavGroup {
  final String group;
  final List<_NavItem> items;
  const _NavGroup(this.group, this.items);
}

const _nav = <_NavGroup>[
  _NavGroup('Principal', [
    _NavItem('dashboard', FontAwesomeIcons.house, 'Dashboard'),
    _NavItem('perfil', FontAwesomeIcons.user, 'Perfil'),
    _NavItem('gestion', FontAwesomeIcons.users, 'Deportistas'),
    _NavItem('equipos', FontAwesomeIcons.peopleGroup, 'Equipos'),
    _NavItem('horario', FontAwesomeIcons.calendarDays, 'Horario'),
    _NavItem('partidos', FontAwesomeIcons.trophy, 'Partidos'),
  ]),
  _NavGroup('Análisis', [
    _NavItem('estadisticas', FontAwesomeIcons.chartBar, 'Estadísticas'),
    _NavItem('rutinas', FontAwesomeIcons.dumbbell, 'Rutinas'),
    _NavItem('registro_rutinas', FontAwesomeIcons.clipboardCheck, 'Registro de rutinas'),
    _NavItem('reportes', FontAwesomeIcons.fileLines, 'Reportes'),
    _NavItem('analisis', FontAwesomeIcons.microchip, 'Análisis IA'),
  ]),
  _NavGroup('Sistema', [
    _NavItem('configuracion', FontAwesomeIcons.gear, 'Configuración'),
  ]),
];

/// Sidebar / Drawer del panel de entrenador alineado con `VolleyScan_Next/src/app/components/Sidebar.jsx`.
class EntrenadorSidebar extends StatefulWidget {
  final String selectedId;
  final ValueChanged<String> onSelect;
  final String? nombre, apellido, fotoUrl, role;

  const EntrenadorSidebar({
    super.key,
    required this.selectedId,
    required this.onSelect,
    this.nombre,
    this.apellido,
    this.fotoUrl,
    this.role,
  });

  @override
  State<EntrenadorSidebar> createState() => _EntrenadorSidebarState();
}

class _EntrenadorSidebarState extends State<EntrenadorSidebar> {
  ProfileData? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarEntrenador();
  }

  Future<void> _cargarEntrenador() async {
    try {
      final guardado = await ApiService.getUsuario();
      if (mounted && guardado != null) {
        setState(() => _usuario = ProfileData.fromJson(guardado));
      }
      final remoto = await ApiService().me();
      if (mounted) setState(() => _usuario = ProfileData.fromJson(remoto));
    } on ApiException catch (e) {
      if (e.isUnauthorized && mounted) {
        final nav = ApiService.navigatorKey.currentState ?? Navigator.of(context);
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      // Fallback silencioso: conserva el usuario en caché local si no hay red.
    }
  }

  String get _nombre {
    final prop = '${widget.nombre ?? ''} ${widget.apellido ?? ''}'.trim();
    if (prop.isNotEmpty) return prop;
    final n = _usuario?.nombre.trim() ?? '';
    final a = _usuario?.apellido.trim() ?? '';
    final full = [n, a].where((s) => s.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : 'Entrenador';
  }

  String get _iniciales {
    final parts = _nombre.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return 'EN';
  }

  String? get _fotoResuelta {
    final raw = (widget.fotoUrl ?? _usuario?.fotoUrl ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final origin = Uri.parse(ApiService.baseUrl).origin;
    return raw.startsWith('/') ? '$origin$raw' : '$origin/$raw';
  }

  String get _rol =>
      (widget.role ?? '').trim().isNotEmpty ? widget.role!.trim() : 'Entrenador';

  Future<void> _confirmarCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierColor: DashColors.modalOverlay,
      builder: (ctx) => AlertDialog(
        backgroundColor: DashColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: DashColors.border2),
        ),
        title: const Text('Cerrar sesión', style: TextStyle(color: DashColors.text1, fontWeight: FontWeight.w700)),
        content: const Text(
          '¿Seguro que quieres cerrar sesión en VolleyScan?',
          style: TextStyle(color: DashColors.textMuted, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: DashColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DashColors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final nav = ApiService.navigatorKey.currentState ?? Navigator.of(context);
    Scaffold.maybeOf(context)?.closeDrawer();
    await ApiService().cerrarSesionCompleta();
    nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: DashColors.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                children: [
                  for (final g in _nav) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                      child: Text(
                        g.group.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: DashColors.text3,
                        ),
                      ),
                    ),
                    for (final item in g.items) _tile(item, item.id == widget.selectedId),
                  ],
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DashColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.sidebarLogoIcon,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: DashColors.sidebarActiveGlow, blurRadius: 16)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/Logo.VS.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.sports_volleyball, size: 22, color: DashColors.text1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VolleyAI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: DashColors.text1)),
                Text('Entrenador', style: TextStyle(fontSize: 11, color: DashColors.text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(_NavItem item, bool active) {
    final color = active ? DashColors.text1 : DashColors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            hoverColor: DashColors.sidebarItemHover,
            onTap: () => widget.onSelect(item.id),
            child: Ink(
              height: 42,
              decoration: active ? const BoxDecoration(gradient: AppGradients.sidebarActiveItem) : null,
              child: Row(
                children: [
                  Container(width: 3, height: 42, color: active ? DashColors.sidebarActiveBorder : Colors.transparent),
                  const SizedBox(width: 9),
                  SizedBox(width: 15, child: FaIcon(item.icon, size: 15, color: active ? DashColors.sidebarActiveBorder : color)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    final foto = _fotoResuelta;
    final fallback = Text(_iniciales, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: DashColors.borderSubtle))),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.sidebarLogoIcon,
              boxShadow: [BoxShadow(color: DashColors.sidebarActiveGlow, blurRadius: 14)],
            ),
            child: foto != null
                ? ClipOval(child: Image.network(foto, width: 38, height: 38, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback))
                : fallback,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: DashColors.text1)),
                Text(_rol, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: DashColors.textMuted)),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: DashColors.green, boxShadow: [BoxShadow(color: DashColors.greenGlow, blurRadius: 8)]),
          ),
          const SizedBox(width: 2),
          IconButton(
            onPressed: _confirmarCerrarSesion,
            icon: const Icon(Icons.logout_rounded, size: 18, color: DashColors.red),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }
}
