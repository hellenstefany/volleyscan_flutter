import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/dash_colors.dart';
import 'profile_avatar.dart';

/// Menú lateral (las tres rayas): secciones, opciones y usuario al pie.
class DashboardDrawer extends StatefulWidget {
  const DashboardDrawer({
    super.key,
    this.userName = '',
    this.photoUrl,
    this.userRole = 'usuario',
    this.selectedId = 'panel',
    this.onSelect,
  });

  final String userName;
  final String? photoUrl;
  final String userRole;
  final String selectedId;

  /// Se llama con el id de la opción tocada (ej. 'rutinas', 'progreso').
  final ValueChanged<String>? onSelect;

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  String _sessionName = '';
  String? _sessionPhoto;

  static const _bg = Color(0xFF0B1022);
  static const _accent = Color(0xFF8B5CF6);

  static const _sections = <_Section>[
    _Section('PRINCIPAL', [
      _Item('panel', 'Panel', Icons.space_dashboard_rounded),
      _Item('perfil', 'Perfil', Icons.person_rounded),
    ]),
    _Section('ENTRENAMIENTO', [
      _Item('rutinas', 'Rutinas', Icons.fitness_center_rounded),
      _Item('historial', 'Historial', Icons.description_rounded),
      _Item('contenido', 'Contenido', Icons.memory_rounded),
    ]),
    _Section('ANÁLISIS', [
      _Item('progreso', 'Progreso', Icons.show_chart_rounded),
      _Item('analisis_ia', 'Análisis IA', Icons.photo_camera_rounded),
      _Item('historial_ia', 'Historial de IA', Icons.photo_camera_rounded),
      _Item('notificaciones', 'Notificaciones', Icons.notifications_rounded),
    ]),
    _Section('SISTEMA', [
      _Item('configuracion', 'Configuración', Icons.settings_rounded),
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
      if (!mounted || u == null) return;
      final nombre = (u['nombre'] ?? '').toString().trim();
      final apellido = (u['apellido'] ?? '').toString().trim();
      final full = [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
      final foto = u['foto_url']?.toString().trim();
      setState(() {
        if (full.isNotEmpty) _sessionName = full;
        if (foto != null && foto.isNotEmpty) _sessionPhoto = foto;
      });
    } catch (_) {}
  }

  String get _effectiveName {
    if (_sessionName.isNotEmpty) return _sessionName;
    if (widget.userName.trim().isNotEmpty) return widget.userName.trim();
    return 'Atleta';
  }

  String? get _effectivePhoto =>
      (widget.photoUrl != null && widget.photoUrl!.trim().isNotEmpty)
          ? widget.photoUrl
          : _sessionPhoto;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            _header(context),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final s in _sections) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        s.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    for (final item in s.items) _tile(context, item),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DashColors.cyan.withValues(alpha: 0.25),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/Logo.VS.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.sports_volleyball,
                  size: 26,
                  color: DashColors.cyan,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VolleyScan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Deportista/Usuario',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              size: 22,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, _Item item) {
    final active = item.id == widget.selectedId;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 20,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          widget.onSelect?.call(item.id);
        },
        child: active
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B1E4B), Color(0xFF121A3A)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 3,
                        child: ColoredBox(color: _accent),
                      ),
                      content,
                    ],
                  ),
                ),
              )
            : content,
      ),
    );
  }

  Widget _footer() {
    final name = _effectiveName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          ProfileAvatar(name: name, photoPath: _effectivePhoto, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.userRole,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: DashColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  const _Section(this.title, this.items);
  final String title;
  final List<_Item> items;
}

class _Item {
  const _Item(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}
