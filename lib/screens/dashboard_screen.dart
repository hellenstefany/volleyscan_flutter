import 'package:flutter/material.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/daily_routine_card.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../widgets/usuario/dashboard_drawer.dart';
import '../widgets/usuario/dashboard_header.dart';
import '../widgets/usuario/last_analysis_card.dart';
import '../widgets/usuario/sparkline.dart';
import '../widgets/usuario/stat_card.dart';
import '../widgets/usuario/streak_card.dart';
import 'profile_screen.dart';
import 'routines_screen.dart';
import 'progress_screen.dart';

/// Panel de usuario (Inicio).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.userName = 'Agustin'});

  final String userName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _navIndex = 0;

  // TODO: reemplazar por los datos reales de tu backend.
  static const _progressTrend = <double>[
    0.20,
    0.24,
    0.30,
    0.38,
    0.42,
    0.36,
    0.28,
    0.40,
    0.95,
  ];

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userName: widget.userName),
      ),
    );
  }

  void _onMenuSelect(String id) {
    if (id == 'perfil') {
      _openProfile();
      return;
    }
    // TODO: navegar según el id: 'rutinas', 'historial', 'contenido',
    // 'progreso', 'analisis_ia', 'historial_ia', 'notificaciones',
    // 'configuracion'.
  }

  void _onNavTap(int index) {
    if (index == 4) {
      _openProfile();
      return;
    }
    setState(() => _navIndex = index);
    // TODO: navegar a Rutinas / Scan IA / Historial.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: DashboardDrawer(
        userName: widget.userName,
        selectedId: 'panel',
        onSelect: (id) {
          switch (id) {
            case 'perfil':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
            case 'rutinas':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoutinesScreen()),
              );
              break;
            case 'progreso':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
              break;
          }
        },
      ),
      bottomNavigationBar: DashboardBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DashboardHeader(
              userName: widget.userName,
              notifications: 3,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onBellTap: () {
                // TODO: abrir notificaciones
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 156,
                          child: Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.trending_up_rounded,
                                  iconColor: DashColors.blueLight,
                                  iconBg: const Color(0xFF14264D),
                                  label: 'Progreso general',
                                  value: '78%',
                                  delta: '12%',
                                  caption: 'vs. semana pasada',
                                  chart: const Sparkline(
                                    values: _progressTrend,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: StatCard(
                                  icon: Icons.gps_fixed_rounded,
                                  iconColor: DashColors.green,
                                  iconBg: Color(0xFF0F3A33),
                                  label: 'Sesiones completadas',
                                  value: '12',
                                  delta: '2',
                                  caption: 'esta semana',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const StreakCard(days: 5),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 160,
                          child: Row(
                            children: [
                              const Expanded(
                                child: LastAnalysisCard(
                                  technique: 'remate',
                                  timeAgo: 'Hace 3 días',
                                  score: 87,
                                  // Pon aquí una imagen declarada en pubspec.yaml;
                                  // si no existe se muestra un placeholder.
                                  imagePath:
                                      'assets/images/ultimo_analisis.jpg',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DailyRoutineCard(
                                  title: 'Recepción + Pase',
                                  completed: 3,
                                  total: 3,
                                  onViewRoutine: () {
                                    // TODO: abrir la rutina
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
