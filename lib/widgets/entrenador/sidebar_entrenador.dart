import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ── Colores (tomados de Sidebar.css de Next) ──────────────────────
const _bg = Color(0xFF0C1020);
const _border = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
const _textMain = Color(0xFFE8EAF6);
const _textMuted = Color(0xFF8892B0);
const _textGroup = Color(0xFF4A5568);
const _violet = Color(0xFF7C3AED);
const _blue = Color(0xFF4F6EF7);
const _online = Color(0xFF22C55E);

class _NavItem {
  final FaIconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _NavGroup {
  final String group;
  final List<_NavItem> items;
  const _NavGroup(this.group, this.items);
}

/// El índice de cada ítem es su posición en este orden (de arriba hacia abajo):
///  0 Dashboard · 1 Perfil · 2 Deportistas · 3 Equipos · 4 Horario · 5 Partidos
///  6 Estadísticas · 7 Rutinas · 8 Registro de rutinas · 9 Reportes · 10 Análisis IA
///  11 Configuración
const _nav = <_NavGroup>[
  _NavGroup('Principal', [
    _NavItem(FontAwesomeIcons.house, 'Dashboard'),
    _NavItem(FontAwesomeIcons.user, 'Perfil'),
    _NavItem(FontAwesomeIcons.users, 'Deportistas'),
    _NavItem(FontAwesomeIcons.peopleGroup, 'Equipos'),
    _NavItem(FontAwesomeIcons.calendarDays, 'Horario'),
    _NavItem(FontAwesomeIcons.trophy, 'Partidos'),
  ]),
  _NavGroup('Análisis', [
    _NavItem(FontAwesomeIcons.chartBar, 'Estadísticas'),
    _NavItem(FontAwesomeIcons.dumbbell, 'Rutinas'),
    _NavItem(FontAwesomeIcons.clipboardCheck, 'Registro de rutinas'),
    _NavItem(FontAwesomeIcons.fileLines, 'Reportes'),
    _NavItem(FontAwesomeIcons.microchip, 'Análisis IA'),
  ]),
  _NavGroup('Sistema', [_NavItem(FontAwesomeIcons.gear, 'Configuración')]),
];

class EntrenadorSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Opcionales: si no pasas nombre, el pie (avatar + nombre) no se muestra.
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String role;

  const EntrenadorSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.nombre = '',
    this.apellido = '',
    this.fotoUrl,
    this.role = 'Entrenador',
  });

  String get _iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    final r = '$n$a'.toUpperCase();
    return r.isEmpty ? 'EN' : r;
  }

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = '$nombre $apellido'.trim();

    // Recorre los grupos asignando el índice de cada ítem
    var i = 0;
    final menu = <Widget>[];
    for (final g in _nav) {
      menu.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
          child: Text(
            g.group.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _textGroup,
            ),
          ),
        ),
      );
      for (final item in g.items) {
        final index = i++;
        menu.add(_tile(item, index, index == selectedIndex));
      }
    }

    return Container(
      width: 230,
      color: _bg,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 10,
                ),
                children: menu,
              ),
            ),
            if (nombreCompleto.isNotEmpty) _footer(nombreCompleto),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Logo.VS.jpg', // cambia por el nombre real de tu logo
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VolleyAI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: _textMain,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Entrenador',
                style: TextStyle(fontSize: 11, color: _textGroup),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(_NavItem item, int index, bool active) {
    final color = active ? _textMain : _textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            hoverColor: const Color(0xFF161E33),
            onTap: () => onSelect(index),
            child: Ink(
              height: 42,
              decoration: active
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _blue.withValues(alpha: 0.22),
                          _blue.withValues(alpha: 0.04),
                        ],
                      ),
                    )
                  : null,
              child: Row(
                children: [
                  // Barra izquierda de 3px (Flutter no permite Border + borderRadius)
                  Container(
                    width: 3,
                    height: 42,
                    color: active ? _violet : Colors.transparent,
                  ),
                  const SizedBox(width: 9),
                  SizedBox(
                    width: 15,
                    child: FaIcon(item.icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: color,
                      ),
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

  Widget _footer(String nombreCompleto) {
    final tieneFoto = fotoUrl != null && fotoUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_blue, _violet],
              ),
              boxShadow: [
                BoxShadow(color: _blue.withValues(alpha: 0.35), blurRadius: 14),
              ],
              image: tieneFoto
                  ? DecorationImage(
                      image: NetworkImage(fotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: tieneFoto
                ? null
                : Text(
                    _iniciales,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombreCompleto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  role,
                  style: const TextStyle(fontSize: 10.5, color: _textMuted),
                ),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _online,
              boxShadow: [
                BoxShadow(color: _online.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
