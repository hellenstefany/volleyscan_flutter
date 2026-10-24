import 'package:flutter/material.dart';

const _bg = Color(0xFF0C1020);
const _text = Color(0xFFE8EAF6);
const _muted = Color(0xFF8892B0);
const _label = Color(0xFF4A5568);
const _hover = Color(0xFF161E33);
const _blue = Color(0xFF4F6EF7);
const _purple = Color(0xFF7C3AED);
const _border = Color(0x12FFFFFF); // blanco 7%

class _Item {
  final String label;
  final IconData icon;
  final int index;
  const _Item(this.label, this.icon, this.index);
}

class _Group {
  final String name;
  final List<_Item> items;
  const _Group(this.name, this.items);
}

// El índice de cada item corresponde a la página en EntrenadorShell
const _nav = [
  _Group('Principal', [
    _Item('Dashboard', Icons.home_rounded, 0),
    _Item('Perfil', Icons.person_rounded, 1),
    _Item('Deportistas', Icons.groups_rounded, 2),
    _Item('Horario', Icons.calendar_month_rounded, 3),
  ]),
  _Group('Análisis', [
    _Item('Estadísticas', Icons.bar_chart_rounded, 4),
    _Item('Rutinas', Icons.fitness_center_rounded, 5),
    _Item('Reportes', Icons.description_rounded, 6),
    _Item('Análisis IA', Icons.memory_rounded, 7),
  ]),
  _Group('Sistema', [_Item('Configuración', Icons.settings_rounded, 8)]),
];

class EntrenadorSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const EntrenadorSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildLogo(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                children: [
                  for (final g in _nav) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                      child: Text(
                        g.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: _label,
                        ),
                      ),
                    ),
                    for (final item in g.items)
                      _NavItem(
                        item: item,
                        active: item.index == selectedIndex,
                        onTap: () => onSelect(item.index),
                      ),
                  ],
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [_blue, _purple]),
              boxShadow: [
                BoxShadow(color: _blue.withOpacity(0.45), blurRadius: 22),
              ],
            ),
            // Para usar tu logo: reemplaza el Icon por
            // ClipRRect(borderRadius: BorderRadius.circular(12),
            //   child: Image.asset('assets/images/Logo.VS.jpg', fit: BoxFit.cover))
            child: const Icon(Icons.sports_volleyball, color: Colors.white),
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
                  color: _text,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text('Entrenador', style: TextStyle(fontSize: 11, color: _label)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
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
              gradient: const LinearGradient(colors: [_blue, _purple]),
              boxShadow: [
                BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 14),
              ],
            ),
            child: const Text(
              'AL',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agustín Luligo',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _text,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Entrenador principal',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: _muted),
                ),
              ],
            ),
          ),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22C55E),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.6),
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

class _NavItem extends StatelessWidget {
  final _Item item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(
                      colors: [
                        _blue.withOpacity(0.22),
                        _blue.withOpacity(0.04),
                      ],
                    )
                  : null,
            ),
            child: InkWell(
              onTap: onTap,
              hoverColor: _hover,
              child: Container(
                padding: const EdgeInsets.fromLTRB(9, 10, 12, 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      width: 3,
                      color: active ? _purple : Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 18, color: active ? _purple : _muted),
                    const SizedBox(width: 14),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? _text : _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
