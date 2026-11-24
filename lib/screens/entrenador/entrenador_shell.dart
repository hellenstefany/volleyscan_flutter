import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/theme/app_theme.dart';
import 'package:volleyscan_mobile/theme/dash_colors.dart';
import 'package:volleyscan_mobile/widgets/entrenador/sidebar_entrenador.dart';
import 'dashboard_screen.dart' as entrenador;
import 'perfil_screen.dart';
import 'equipos_screen.dart';
import 'gestion_screen.dart';
import 'horario_screen.dart';
import 'partidos_screen.dart';
import 'estadisticas_screen.dart';
import 'rutinas_screen.dart';
import 'reportes_screen.dart';
import 'analisis_screen.dart';
import 'configuracion_screen.dart';

class EntrenadorShell extends StatefulWidget {
  const EntrenadorShell({super.key, this.initialId = 'dashboard'});

  final String initialId;

  @override
  State<EntrenadorShell> createState() => _EntrenadorShellState();
}

class _EntrenadorShellState extends State<EntrenadorShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _selectedId = widget.initialId;

  static const _pendientes = <String, String>{
    'registro_rutinas': 'Registro de rutinas',
  };

  Widget _page() {
    switch (_selectedId) {
      case 'dashboard':
        return const entrenador.DashboardScreen();
      case 'perfil':
        return const PerfilScreen();
      case 'gestion':
        return const GestionScreen();
      case 'equipos':
        return const EquiposScreen();
      case 'horario':
        return const HorarioScreen();
      case 'partidos':
        return const PartidosScreen();
      case 'estadisticas':
        return const EstadisticasScreen();
      case 'rutinas':
        return const RutinasScreen();
      case 'reportes':
        return const ReportesScreen();
      case 'analisis':
        return const AnalisisScreen();
      case 'configuracion':
        return const ConfiguracionScreen();
      default:
        return const entrenador.DashboardScreen();
    }
  }

  void _go(String id) {
    _scaffoldKey.currentState?.closeDrawer();
    final pendiente = _pendientes[id];
    if (pendiente != null) {
      showAppToast(context, 'Próximamente: $pendiente', type: 'info');
      return;
    }
    setState(() => _selectedId = id);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;

        // Escritorio: sidebar fija
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                EntrenadorSidebar(selectedId: _selectedId, onSelect: _go),
                Expanded(child: _page()),
              ],
            ),
          );
        }

        // Móvil: barra inferior + drawer con el menú completo
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: DashColors.bg,
          drawer: Drawer(
            width: 260,
            backgroundColor: DashColors.sidebarBg,
            child: EntrenadorSidebar(
              selectedId: _selectedId,
              onSelect: _go,
            ),
          ),
          body: Stack(
            children: [
              _page(),
              Positioned(
                top: 12,
                left: 12,
                child: SafeArea(
                  child: Material(
                    color: DashColors.sidebarBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: DashColors.border2),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.menu,
                          color: DashColors.text1,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              elevation: 6,
              backgroundColor: DashColors.blue,
              shape: const CircleBorder(
                side: BorderSide(color: DashColors.blueGlow, width: 4),
              ),
              onPressed: () => _go('analisis'),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: DashColors.sidebarBg,
            height: 66,
            padding: EdgeInsets.zero,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: DashColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  _BarItem(
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    active: _selectedId == 'dashboard',
                    onTap: () => _go('dashboard'),
                  ),
                  _BarItem(
                    icon: Icons.groups_rounded,
                    label: 'Deportistas',
                    active: _selectedId == 'gestion',
                    onTap: () => _go('gestion'),
                  ),
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
                            color: _selectedId == 'analisis'
                                ? DashColors.blueLight
                                : DashColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BarItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Estadísticas',
                    active: _selectedId == 'estadisticas',
                    onTap: () => _go('estadisticas'),
                  ),
                  _BarItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    active: _selectedId == 'perfil',
                    onTap: () => _go('perfil'),
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
    final color = active ? DashColors.blueLight : DashColors.textMuted;
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
