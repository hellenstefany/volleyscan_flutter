import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/progreso_atleta_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../widgets/usuario/dashboard_drawer.dart';
import '../widgets/usuario/dashboard_header.dart';
import '../widgets/usuario/dashboard_quick_access.dart';
import '../widgets/usuario/dashboard_top_summary.dart';
import '../widgets/usuario/progreso/mi_progreso_section.dart';
import 'ai_history_screen.dart';
import 'analysis_screen.dart';
import 'content_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'routines_screen.dart';
import 'settings_screen.dart';

/// Panel de usuario (Inicio) alineado con `VolleyScan_Next/src/app/usuario/dashboard/page.jsx`.
/// Contiene únicamente estado, carga en paralelo (`Future.wait`), pull-to-refresh y armado de secciones.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.userName = ''});

  final String userName;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final int _navIndex = 0;

  String _nombre = '';
  String? _fotoUrl;

  // Estado de `/api/usuario/dashboard/`
  bool _loadingDash = true;
  String? _errorDash;
  DashboardResponse? _dashData;

  // Estado de `/api/ia/progreso`
  bool _loadingProgreso = true;
  String? _errorProgreso;
  ProgresoAtletaResponse? _progresoData;

  // Estado de `/api/ia/avisos/contador`
  int? _avisosNoLeidos;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _cargarUsuarioSesion() async {
    try {
      final guardado = await ApiService.getUsuario();
      if (mounted && guardado != null) {
        final nombreGuardado = (guardado['nombre'] ?? '').toString().trim();
        final fotoGuardada = guardado['foto_url']?.toString().trim();
        setState(() {
          if (nombreGuardado.isNotEmpty) _nombre = nombreGuardado;
          _fotoUrl = (fotoGuardada != null && fotoGuardada.isNotEmpty)
              ? fotoGuardada
              : null;
        });
      }
    } catch (_) {}
  }

  Future<void> _inicializar() async {
    await _cargarUsuarioSesion();
    await _cargarTodoEnParalelo();
  }

  /// Lanza las 3 peticiones en paralelo con `Future.wait`.
  /// Cada una maneja su propio error para que si un endpoint falla, no tumbe el resto.
  Future<void> _cargarTodoEnParalelo() async {
    if (!mounted) return;
    setState(() {
      _loadingDash = true;
      _errorDash = null;
      _loadingProgreso = true;
      _errorProgreso = null;
    });

    await Future.wait([
      _cargarResumenDashboard(),
      _cargarProgreso(),
      _cargarContadorAvisos(),
    ]);
  }

  Future<void> _cargarResumenDashboard() async {
    if (mounted && !_loadingDash) {
      setState(() {
        _loadingDash = true;
        _errorDash = null;
      });
    }
    try {
      final data = await ApiService().dashboardUsuario();
      if (!mounted) return;
      setState(() {
        _dashData = data;
        if (data.usuarioNombre != null && data.usuarioNombre!.isNotEmpty) {
          _nombre = data.usuarioNombre!;
        }
        _loadingDash = false;
        _errorDash = null;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _loadingDash = false;
        _errorDash = err.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDash = false;
        _errorDash = 'No se pudo cargar el dashboard.';
      });
    }
  }

  Future<void> _cargarProgreso() async {
    if (mounted && !_loadingProgreso) {
      setState(() {
        _loadingProgreso = true;
        _errorProgreso = null;
      });
    }
    try {
      final data = await ApiService().progresoAtleta();
      if (!mounted) return;
      setState(() {
        _progresoData = data;
        _loadingProgreso = false;
        _errorProgreso = null;
      });
    } on ApiException catch (err) {
      if (!mounted) return;
      setState(() {
        _loadingProgreso = false;
        _errorProgreso = err.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProgreso = false;
        _errorProgreso = 'No se pudo cargar tu progreso.';
      });
    }
  }

  Future<void> _cargarContadorAvisos() async {
    try {
      final res = await ApiService().contadorAvisos(todas: true);
      if (!mounted) return;
      setState(() => _avisosNoLeidos = res.noLeidas);
    } catch (_) {
      // Si falla, usa notificacionesSinLeer de /usuario/dashboard/ o 0.
    }
  }

  String get _displayName {
    if (_nombre.isNotEmpty) return _nombre;
    if (widget.userName.trim().isNotEmpty) return widget.userName.trim();
    return 'Atleta';
  }

  int get _effectiveNotifications {
    if (_avisosNoLeidos != null) return _avisosNoLeidos!;
    return _dashData?.notificacionesSinLeer ?? 0;
  }

  /// Abre una pantalla encima del panel y refresca al volver.
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) {
      await _cargarUsuarioSesion();
      _cargarTodoEnParalelo();
    }
  }

  void _openProfile() =>
      _go(ProfileScreen(userName: _displayName, photoPath: _fotoUrl));

  /// Barra inferior: 0 Inicio, 1 Rutinas, 2 Scan IA, 3 Historial, 4 Perfil.
  void _onNavTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        _go(const RoutinesScreen());
        break;
      case 2:
        _go(const AnalysisScreen());
        break;
      case 3:
        _go(const HistoryScreen());
        break;
      case 4:
        _openProfile();
        break;
    }
  }

  /// Menú lateral (drawer).
  void _onMenuSelect(String id) {
    switch (id) {
      case 'perfil':
        _openProfile();
        break;
      case 'rutinas':
        _go(const RoutinesScreen());
        break;
      case 'progreso':
        _go(const ProgressScreen());
        break;
      case 'configuracion':
        _go(const SettingsScreen());
        break;
      case 'analisis_ia':
        _go(const AnalysisScreen());
        break;
      case 'historial_ia':
        _go(const AiHistoryScreen());
        break;
      case 'notificaciones':
        _go(const NotificationsScreen());
        break;
      case 'historial':
        _go(const HistoryScreen());
        break;
      case 'contenido':
        _go(const ContentScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: DashboardDrawer(
        userName: _displayName,
        photoUrl: _fotoUrl,
        selectedId: 'panel',
        onSelect: _onMenuSelect,
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
              userName: _displayName,
              notifications: _effectiveNotifications,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onBellTap: () => _go(const NotificationsScreen()),
            ),
            Expanded(
              child: RefreshIndicator(
                color: DashColors.blueLight,
                backgroundColor: DashColors.card,
                onRefresh: _cargarTodoEnParalelo,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DashboardTopSummary(
                            loading: _loadingDash,
                            error: _errorDash,
                            data: _dashData,
                            progresoRachaActual: _progresoData?.racha.actual,
                            onRetry: _cargarResumenDashboard,
                            onOpenAnalysis: () => _go(const AnalysisScreen()),
                            onOpenAiHistory: () => _go(const AiHistoryScreen()),
                            onOpenRoutines: () => _go(const RoutinesScreen()),
                          ),
                          const SizedBox(height: AppSpacing.dashSectionGap),
                          DashboardQuickAccess(
                            onStartAnalysis: () => _go(const AnalysisScreen()),
                            onViewHistory: () => _go(const HistoryScreen()),
                            onDailyRoutine: () => _go(const RoutinesScreen()),
                            onExercises: () => _go(const ContentScreen()),
                          ),
                          const SizedBox(height: 24),
                          MiProgresoSection(
                            loading: _loadingProgreso,
                            error: _errorProgreso,
                            datos: _progresoData,
                            onRetry: _cargarProgreso,
                            onOpenRoutines: () => _go(const RoutinesScreen()),
                            onStartAnalysis: () => _go(const AnalysisScreen()),
                          ),
                        ],
                      ),
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
