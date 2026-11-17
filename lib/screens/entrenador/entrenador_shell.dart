import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/widgets/entrenador/sidebar_entrenador.dart';
import 'package:volleyscan_mobile/widgets/entrenador/pantalla_pendiente.dart';
import 'dashboard_screen.dart' as entrenador;
import 'perfil_screen.dart';
import 'equipos_screen.dart';
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

// Índices del menú (mismo orden que el sidebar)
const _iDashboard = 0;
const _iPerfil = 1;
const _iDeportistas = 2;
const _iEquipos = 3;
const _iHorario = 4;
const _iPartidos = 5;
const _iEstadisticas = 6;
const _iRutinas = 7;
const _iRegistroRutinas = 8;
const _iReportes = 9;
const _iAnalisis = 10;
// 11 = Configuración

class EntrenadorShell extends StatefulWidget {
  const EntrenadorShell({super.key});

  @override
  State<EntrenadorShell> createState() => _EntrenadorShellState();
}

class _EntrenadorShellState extends State<EntrenadorShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = _iDashboard;

  Widget _page() {
    switch (_index) {
      case _iDashboard:
        return const entrenador.DashboardScreen();
      case _iPerfil:
        return const PerfilScreen();
      case _iDeportistas:
        return const GestionScreen();
      case _iEquipos:
        return const EquiposScreen();
      case _iHorario:
        return const HorarioScreen();
      case _iPartidos:
        return const PantallaPendiente(titulo: 'Partidos');
      case _iEstadisticas:
        return const EstadisticasScreen();
      case _iRutinas:
        return const RutinasScreen();
      case _iRegistroRutinas:
        return const PantallaPendiente(titulo: 'Registro de rutinas');
      case _iReportes:
        return const ReportesScreen();
      case _iAnalisis:
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
                _scaffoldKey.currentState?.closeDrawer();
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
          // Botón central redondo "Scan IA" → Análisis IA
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
              onPressed: () => _go(_iAnalisis),
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
                    active: _index == _iDashboard,
                    onTap: () => _go(_iDashboard),
                  ),
                  _BarItem(
                    icon: Icons.groups_rounded,
                    label: 'Deportistas',
                    active: _index == _iDeportistas,
                    onTap: () => _go(_iDeportistas),
                  ),
                  // Hueco para el botón central, con su etiqueta
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'chat IA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _index == _iAnalisis ? _active : _inactive,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BarItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Estadísticas',
                    active: _index == _iEstadisticas,
                    onTap: () => _go(_iEstadisticas),
                  ),
                  _BarItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    active: _index == _iPerfil,
                    onTap: () => _go(_iPerfil),
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
