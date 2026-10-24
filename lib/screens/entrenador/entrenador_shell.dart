import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/widgets/entrenador/sidebar_entrenador.dart';
import 'dashboard_screen.dart' as entrenador;
import 'perfil_screen.dart';
import 'gestion_screen.dart';
import 'horario_screen.dart';
import 'estadisticas_screen.dart';
import 'rutinas_screen.dart';
import 'reportes_screen.dart';
import 'analisis_screen.dart';
import 'configuracion_screen.dart';

const _bar = Color(0xFF0C1020);
const _barBorder = Color(0x12FFFFFF);
const _active = Color(0xFF3B82F6);
const _inactive = Color(0xFF8892B0);

class EntrenadorShell extends StatefulWidget {
  const EntrenadorShell({super.key});

  @override
  State<EntrenadorShell> createState() => _EntrenadorShellState();
}

class _EntrenadorShellState extends State<EntrenadorShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  // Mismo orden que los índices del sidebar. Ajusta los nombres de clase.
  Widget _page() {
    switch (_index) {
      case 0:
        return const entrenador.DashboardScreen();
      case 1:
        return const PerfilScreen();
      case 2:
        return const GestionScreen();
      case 3:
        return const HorarioScreen();
      case 4:
        return const EstadisticasScreen();
      case 5:
        return const RutinasScreen();
      case 6:
        return const ReportesScreen();
      case 7:
        return const AnalisisScreen();
      default:
        return const ConfiguracionScreen();
    }
  }

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Se decide con el ancho real disponible, no con el de la ventana
        final wide = c.maxWidth >= 900;

        // Escritorio: sidebar fija
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                EntrenadorSidebar(selectedIndex: _index, onSelect: _go),
                Expanded(child: _page()),
              ],
            ),
          );
        }

        // Móvil: barra inferior + drawer con el menú completo
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFF0F1425),
          drawer: Drawer(
            width: 260,
            backgroundColor: _bar,
            child: EntrenadorSidebar(
              selectedIndex: _index,
              onSelect: (i) {
                _go(i);
                Navigator.pop(context); // cierra el drawer
              },
            ),
          ),
          body: Stack(
            children: [
              _page(),
              // Botón de menú flotante
              Positioned(
                top: 12,
                left: 12,
                child: SafeArea(
                  child: Material(
                    color: _bar,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0x1FFFFFFF)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.menu,
                          color: Color(0xFFE8EAF6),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Botón central redondo "Scan IA" → Análisis IA (índice 7)
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              elevation: 6,
              backgroundColor: const Color(0xFF2563EB),
              shape: const CircleBorder(
                side: BorderSide(color: Color(0x663B82F6), width: 4),
              ),
              onPressed: () => _go(7),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: _bar,
            height: 66,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _barBorder)),
              ),
              child: Row(
                children: [
                  _BarItem(
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    active: _index == 0,
                    onTap: () => _go(0),
                  ),
                  _BarItem(
                    icon: Icons.groups_rounded,
                    label: 'Deportistas',
                    active: _index == 2,
                    onTap: () => _go(2),
                  ),
                  // Hueco para el botón central, con su etiqueta
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Scan IA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _index == 7 ? _active : _inactive,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BarItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Estadísticas',
                    active: _index == 4,
                    onTap: () => _go(4),
                  ),
                  _BarItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    active: _index == 1,
                    onTap: () => _go(1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _active : _inactive;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
