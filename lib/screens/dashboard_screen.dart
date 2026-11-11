import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/daily_routine_card.dart';
import '../widgets/usuario/dash_card.dart';
import '../widgets/usuario/dashboard_bottom_nav.dart';
import '../widgets/usuario/dashboard_drawer.dart';
import '../widgets/usuario/dashboard_header.dart';
import '../widgets/usuario/last_analysis_card.dart';
import '../widgets/usuario/sparkline.dart';
import '../widgets/usuario/stat_card.dart';
import '../widgets/usuario/streak_card.dart';
import 'ai_history_screen.dart';
import 'analysis_screen.dart';
import 'content_screen.dart';
import 'history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'routines_screen.dart';
import 'settings_screen.dart';

/// Panel de usuario (Inicio) alineado con `VolleyScan_Next/src/app/usuario/dashboard/page.jsx`,
/// `Dashboard.css`, `MiProgreso.jsx` y `mi-progreso.module.css`.
/// Conecta en paralelo (`Future.wait`):
/// - `GET /api/usuario/dashboard/`
/// - `GET /api/ia/progreso?tz=...`
/// - `GET /api/ia/avisos/contador?todas=1`
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

  // Estado de `/api/usuario/dashboard/`
  bool _loadingDash = true;
  String? _errorDash;
  Map<String, dynamic>? _dashData;

  // Estado de `/api/ia/progreso`
  bool _loadingProgreso = true;
  String? _errorProgreso;
  Map<String, dynamic>? _progresoData;

  // Estado de `/api/ia/avisos/contador`
  int? _avisosNoLeidos;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    // Leemos primero el nombre en caché seguro para no esperar a la red en el saludo.
    try {
      final guardado = await ApiService.getUsuario();
      if (mounted && guardado != null) {
        final nombreGuardado = (guardado['nombre'] ?? '').toString().trim();
        if (nombreGuardado.isNotEmpty) {
          setState(() => _nombre = nombreGuardado);
        }
      }
    } catch (_) {}

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
      final usuario = data['usuario'];
      final nombreApi = usuario is Map
          ? (usuario['nombre'] ?? '').toString().trim()
          : '';
      setState(() {
        _dashData = data;
        if (nombreApi.isNotEmpty) _nombre = nombreApi;
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
      final count = await ApiService().contadorAvisos(todas: true);
      if (!mounted) return;
      setState(() => _avisosNoLeidos = count);
    } catch (_) {
      // Si falla, usamos notificaciones_sin_leer de /usuario/dashboard/ o 0.
    }
  }

  String get _displayName {
    if (_nombre.isNotEmpty) return _nombre;
    if (widget.userName.trim().isNotEmpty) return widget.userName.trim();
    return 'Atleta';
  }

  int get _effectiveNotifications {
    if (_avisosNoLeidos != null) return _avisosNoLeidos!;
    final fromDash = _dashData?['notificaciones_sin_leer'];
    if (fromDash != null) {
      return int.tryParse(fromDash.toString()) ?? 0;
    }
    return 0;
  }

  /// Equivalente a `haceCuanto(iso)` en `VolleyScan_Next/src/lib/formato.js`.
  String _haceCuanto(dynamic rawIso) {
    if (rawIso == null) return '';
    final str = rawIso.toString().trim();
    if (str.isEmpty) return '';
    final dt = DateTime.tryParse(str);
    if (dt == null) return '';
    final diffMin = DateTime.now().difference(dt.toLocal()).inMinutes;
    if (diffMin < 1) return 'Hace un momento';
    if (diffMin < 60) return 'Hace $diffMin min';
    final h = diffMin ~/ 60;
    if (h < 24) return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
    final d = h ~/ 24;
    return 'Hace $d ${d == 1 ? 'día' : 'días'}';
  }

  /// Convierte URL relativa `/media/...` en absoluta respecto al host del backend.
  String? _resolveMediaUrl(dynamic rawUrl) {
    if (rawUrl == null) return null;
    final url = rawUrl.toString().trim();
    if (url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final apiBase = ApiService.baseUrl;
    final hostBase = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;
    return url.startsWith('/') ? '$hostBase$url' : '$hostBase/$url';
  }

  /// Abre una pantalla encima del panel y refresca al volver.
  Future<void> _go(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) {
      _cargarTodoEnParalelo();
    }
  }

  void _openProfile() => _go(ProfileScreen(userName: _displayName));

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
                          // ── Bloque 1: Estadísticas + Último análisis + Rutina del día ──
                          _buildTopDashboardSection(),
                          const SizedBox(height: 20),

                          // ── Bloque 2: Accesos rápidos (.quick-access) ──
                          _buildQuickAccessSection(),
                          const SizedBox(height: 24),

                          // ── Bloque 3: Tu progreso (MiProgreso.jsx -> /api/ia/progreso) ──
                          _buildMiProgresoSection(),
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

  // ===========================================================================
  // BLOQUE 1: /api/usuario/dashboard/ (Stats, Racha, Último análisis, Rutina)
  // ===========================================================================

  Widget _buildTopDashboardSection() {
    if (_loadingDash) {
      return Column(
        children: [
          SizedBox(
            height: 156,
            child: Row(
              children: [
                Expanded(child: _buildSkeletonCard(height: 156)),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonCard(height: 156)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSkeletonCard(height: 82),
          const SizedBox(height: 14),
          SizedBox(
            height: 168,
            child: Row(
              children: [
                Expanded(child: _buildSkeletonCard(height: 168)),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonCard(height: 168)),
              ],
            ),
          ),
        ],
      );
    }

    if (_errorDash != null || _dashData == null) {
      return _buildErrorBanner(
        message: 'No se pudo cargar el dashboard.',
        detail: _errorDash,
        onRetry: _cargarResumenDashboard,
      );
    }

    final data = _dashData!;
    final progreso = data['progreso'] is Map
        ? Map<String, dynamic>.from(data['progreso'] as Map)
        : const <String, dynamic>{};
    final sesiones = data['sesiones'] is Map
        ? Map<String, dynamic>.from(data['sesiones'] as Map)
        : const <String, dynamic>{};

    // Progreso general: valor y variación reales (sin inventar si vienen null)
    final progValor = progreso['valor'];
    final progValorStr = progValor != null ? '$progValor%' : '—%';
    final progVar = _toNum(progreso['variacion']);
    final String? progDeltaStr = (progVar != null && progVar != 0)
        ? '${progVar.abs()}%'
        : null;
    final bool progDeltaPos = (progVar ?? 0) > 0;

    final rawTendencia = progreso['tendencia'];
    final List<double> tendencia = rawTendencia is List
        ? rawTendencia
              .map((e) => double.tryParse(e.toString()))
              .whereType<double>()
              .toList()
        : const <double>[];

    // Sesiones completadas esta semana
    final sesSemana = sesiones['semana'] ?? 0;
    final sesVar = _toNum(sesiones['variacion']);
    final String? sesDeltaStr = (sesVar != null && sesVar != 0)
        ? '${sesVar.abs()}'
        : null;
    final bool sesDeltaPos = (sesVar ?? 0) > 0;

    // Racha actual: igual que en Next (`progresoReal.datos?.racha?.actual ?? racha_dias ?? 0`)
    final rachaProgreso = _progresoData?['racha'] is Map
        ? (_progresoData!['racha'] as Map)['actual']
        : null;
    final rachaDias =
        _toInt(rachaProgreso) ?? _toInt(data['racha_dias']) ?? 0;

    // Último análisis (null si el atleta aún no tiene sesiones)
    final ultimoMap = data['ultimo_analisis'] is Map
        ? Map<String, dynamic>.from(data['ultimo_analisis'] as Map)
        : null;

    // Rutina del día (null si el atleta no tiene rutina activa asignada)
    final rutinaMap = data['rutina_del_dia'] is Map
        ? Map<String, dynamic>.from(data['rutina_del_dia'] as Map)
        : null;

    return Column(
      children: [
        SizedBox(
          height: 156,
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: DashColors.blueLight,
                  iconBg: DashColors.blueGlow,
                  label: 'Progreso general',
                  value: progValorStr,
                  delta: progDeltaStr,
                  deltaPositive: progDeltaPos,
                  caption: 'vs. semana pasada',
                  chart: tendencia.length >= 2
                      ? Sparkline(values: tendencia)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.gps_fixed_rounded,
                  iconColor: DashColors.green,
                  iconBg: DashColors.greenGlow,
                  label: 'Sesiones completadas',
                  value: '$sesSemana',
                  delta: sesDeltaStr,
                  deltaPositive: sesDeltaPos,
                  caption: 'esta semana',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreakCard(days: rachaDias),
        const SizedBox(height: 14),
        SizedBox(
          height: 174,
          child: Row(
            children: [
              Expanded(
                child: ultimoMap != null
                    ? LastAnalysisCard(
                        hasData: true,
                        technique: (ultimoMap['tecnica'] ?? 'Análisis')
                            .toString(),
                        timeAgo: _haceCuanto(ultimoMap['creado_en']),
                        score: _toInt(ultimoMap['puntuacion']) ?? 0,
                        imageUrl: _resolveMediaUrl(ultimoMap['miniatura_url']),
                        onTap: () => _go(const AiHistoryScreen()),
                      )
                    : LastAnalysisCard(
                        hasData: false,
                        technique: '',
                        timeAgo: '',
                        score: 0,
                        onTap: () => _go(const AnalysisScreen()),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: rutinaMap != null
                    ? DailyRoutineCard(
                        hasRoutine: true,
                        title: (rutinaMap['nombre'] ?? 'Rutina').toString(),
                        completed: _toInt(rutinaMap['completados']) ?? 0,
                        total: _toInt(rutinaMap['total_ejercicios']) ?? 0,
                        onViewRoutine: () => _go(const RoutinesScreen()),
                      )
                    : DailyRoutineCard(
                        hasRoutine: false,
                        title: '',
                        completed: 0,
                        total: 0,
                        onViewRoutine: () => _go(const RoutinesScreen()),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // BLOQUE 2: Accesos rápidos (`.quick-access` en `Dashboard.css`)
  // ===========================================================================

  Widget _buildQuickAccessSection() {
    final buttons = <_QuickBtnConfig>[
      _QuickBtnConfig(
        label: 'Iniciar análisis',
        icon: Icons.photo_camera_rounded,
        bgColor: DashColors.blueLight,
        textColor: Colors.white,
        onTap: () => _go(const AnalysisScreen()),
      ),
      _QuickBtnConfig(
        label: 'Ver historial',
        icon: Icons.history_rounded,
        bgColor: DashColors.card,
        textColor: DashColors.textSecondary,
        borderColor: DashColors.border,
        onTap: () => _go(const HistoryScreen()),
      ),
      _QuickBtnConfig(
        label: 'Rutina del día',
        icon: Icons.event_available_rounded,
        bgColor: DashColors.green,
        textColor: Colors.white,
        onTap: () => _go(const RoutinesScreen()),
      ),
      _QuickBtnConfig(
        label: 'Ejercicios',
        icon: Icons.fitness_center_rounded,
        bgColor: DashColors.purple,
        textColor: Colors.white,
        onTap: () => _go(const ContentScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCESOS RÁPIDOS',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: DashColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQuickButton(buttons[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickButton(buttons[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildQuickButton(buttons[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickButton(buttons[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickButton(_QuickBtnConfig btn) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showAppToast(context, 'Abriendo: ${btn.label}', type: 'info');
          btn.onTap();
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: btn.bgColor,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: btn.borderColor != null
                ? Border.all(color: btn.borderColor!)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(btn.icon, size: 22, color: btn.textColor),
              const SizedBox(height: 8),
              Text(
                btn.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: btn.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // BLOQUE 3: Tu progreso (`MiProgreso.jsx` + `mi-progreso.module.css`)
  // ===========================================================================

  Widget _buildMiProgresoSection() {
    final generadoEn = _progresoData?['generadoEn'];
    final stamp = (!_loadingProgreso && _errorProgreso == null && generadoEn != null)
        ? 'Actualizado ${_haceCuanto(generadoEn)}'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'TU PROGRESO',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: DashColors.textSecondary,
              ),
            ),
            if (stamp != null && stamp.trim().isNotEmpty)
              Text(
                stamp,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: DashColors.textMuted,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (_loadingProgreso) ...[
          _buildSkeletonCard(height: 185),
          const SizedBox(height: 14),
          _buildSkeletonCard(height: 165),
          const SizedBox(height: 14),
          _buildSkeletonCard(height: 195),
        ] else if (_errorProgreso != null || _progresoData == null) ...[
          _buildErrorBanner(
            message: 'No se pudo cargar tu progreso.',
            detail: _errorProgreso,
            onRetry: _cargarProgreso,
          ),
        ] else ...[
          _buildSemanaCard(_progresoData!),
          const SizedBox(height: 14),
          _buildRutinasProgresoCard(_progresoData!),
          const SizedBox(height: 14),
          _buildEvolucionCard(_progresoData!),
          const SizedBox(height: 14),
          _buildPorTecnicaCard(_progresoData!),
          const SizedBox(height: 14),
          _buildSemanasCard(_progresoData!),
          const SizedBox(height: 14),
          _buildEntrenadorCard(_progresoData!),
          const SizedBox(height: 14),
          _buildLogrosCard(_progresoData!),
          const SizedBox(height: 14),
          _buildRecienteCard(_progresoData!),
        ],
      ],
    );
  }

  // ── 3.1 Tu semana y racha (`Semana` en `MiProgreso.jsx`) ──
  Widget _buildSemanaCard(Map<String, dynamic> datos) {
    final racha = datos['racha'] is Map
        ? Map<String, dynamic>.from(datos['racha'] as Map)
        : const <String, dynamic>{};
    final semana = datos['semana'] is List
        ? (datos['semana'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : const <Map<String, dynamic>>[];

    final actual = _toInt(racha['actual']) ?? 0;
    final mejor = _toInt(racha['mejor']) ?? 0;
    final activoHoy = racha['activoHoy'] == true;

    final mensaje = activoHoy
        ? '¡Hoy ya cuenta! Vuelve mañana para seguir sumando.'
        : (actual > 0
              ? 'Entrena hoy para no perder tu racha.'
              : 'Haz un análisis o un ejercicio hoy y empieza tu racha.');

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader('Tu semana', 'Lunes a domingo'),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: actual == 0
                      ? Colors.white.withValues(alpha: 0.06)
                      : DashColors.orange.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 24,
                  color: actual == 0 ? DashColors.textMuted : DashColors.orange,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Poppins'),
                        children: [
                          TextSpan(
                            text: '$actual',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${actual == 1 ? 'día seguido' : 'días seguidos'}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DashColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$mensaje Mejor racha: $mejor ${mejor == 1 ? 'día' : 'días'}.',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        height: 1.4,
                        color: DashColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (semana.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < semana.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(child: _buildDayCell(semana[i])),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayCell(Map<String, dynamic> d) {
    final dia = (d['dia'] ?? '').toString();
    final fechaStr = (d['fecha'] ?? '').toString();
    final dayNum = _extractDayOfMonth(fechaStr);
    final activo = d['activo'] == true;
    final hoy = d['hoy'] == true;
    final futuro = d['futuro'] == true;

    Color bgColor = DashColors.surface;
    Color borderColor = DashColors.border;
    if (activo) {
      bgColor = DashColors.green.withValues(alpha: 0.08);
      borderColor = DashColors.green.withValues(alpha: 0.4);
    }
    if (hoy) {
      borderColor = DashColors.blueLight;
    }

    return Opacity(
      opacity: futuro ? 0.45 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: hoy ? 1.5 : 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dia,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: DashColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: (activo || hoy)
                    ? Colors.white
                    : DashColors.textSecondary,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activo
                    ? DashColors.green
                    : Colors.white.withValues(alpha: 0.06),
              ),
              alignment: Alignment.center,
              child: activo
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Color(0xFF052E16),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── 3.2 Tus rutinas (`Rutinas` en `MiProgreso.jsx`) ──
  Widget _buildRutinasProgresoCard(Map<String, dynamic> datos) {
    final r = datos['rutinas'] is Map
        ? Map<String, dynamic>.from(datos['rutinas'] as Map)
        : const <String, dynamic>{};

    final asignadas = _toInt(r['asignadas']) ?? 0;
    final completadas = _toInt(r['completadas']) ?? 0;
    final ejerciciosTotal = _toInt(r['ejerciciosTotal']) ?? 0;
    final ejerciciosHechos = _toInt(r['ejerciciosHechos']) ?? 0;
    final porcentaje = _toInt(r['porcentaje']) ?? 0;
    final sig = r['siguiente'] is Map
        ? Map<String, dynamic>.from(r['siguiente'] as Map)
        : null;

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(
            'Tus rutinas',
            '$asignadas ${asignadas == 1 ? 'asignada' : 'asignadas'}',
          ),
          const SizedBox(height: 14),
          if (asignadas == 0)
            _buildEmptyBox(
              title: 'Aún no tienes rutinas',
              subtitle:
                  'Cuando tu entrenador te asigne una, verás aquí tu avance.',
            )
          else ...[
            Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: (porcentaje.clamp(0, 100)) / 100,
                          strokeWidth: 7.5,
                          strokeCap: StrokeCap.round,
                          color: porcentaje >= 100
                              ? DashColors.green
                              : DashColors.blueLight,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: DashColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '$ejerciciosHechos',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: ' de $ejerciciosTotal ejercicios hechos',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: DashColors.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: '$completadas',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: ' de $asignadas rutinas completas',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (sig != null)
              InkWell(
                onTap: () => _go(const RoutinesScreen()),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: DashColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DashColors.border2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (sig['nombre'] ?? 'Rutina').toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${sig['hechos'] ?? 0}/${sig['total'] ?? 0} ejercicios',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    color: DashColors.textSecondary,
                                  ),
                                ),
                                if (sig['fecha'] != null) ...[
                                  const Text(
                                    ' · ',
                                    style: TextStyle(
                                      color: DashColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    sig['vencida'] == true
                                        ? 'Vencida (${_fechaCorta(sig['fecha'].toString())})'
                                        : _fechaCorta(sig['fecha'].toString()),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.5,
                                      fontWeight: sig['vencida'] == true
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: sig['vencida'] == true
                                          ? const Color(0xFFFCA5A5)
                                          : DashColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: DashColors.blueLight.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                '🎉 Completaste todas tus rutinas asignadas.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: DashColors.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── 3.3 Evolución de tu técnica (`Evolucion` en `MiProgreso.jsx`) ──
  Widget _buildEvolucionCard(Map<String, dynamic> datos) {
    final a = datos['analisis'] is Map
        ? Map<String, dynamic>.from(datos['analisis'] as Map)
        : const <String, dynamic>{};

    final promedio = a['promedio'];
    final mejor = a['mejor'];
    final sesiones = _toInt(a['sesiones']) ?? 0;
    final variacion = _toInt(a['variacion']);

    final rawEvol = a['evolucion'] is List ? a['evolucion'] as List : const [];
    final pts = rawEvol
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final values = pts
        .map((p) => double.tryParse((p['puntuacion'] ?? '').toString()))
        .whereType<double>()
        .toList();

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(
            'Evolución de tu técnica',
            pts.isNotEmpty
                ? 'Últimas ${pts.length} sesiones'
                : 'Sin sesiones aún',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildKpiBox(
                  value: '${promedio ?? '—'}',
                  label: 'Promedio',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiBox(
                  value: '${mejor ?? '—'}',
                  label: 'Mejor nota',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiBox(
                  value: '$sesiones',
                  label: 'Sesiones',
                  delta: (variacion != null && variacion != 0)
                      ? '${variacion > 0 ? '+' : '−'}${variacion.abs()}'
                      : null,
                  deltaUp: (variacion ?? 0) > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (values.length < 2)
            _buildEmptyBox(
              title: pts.isEmpty
                  ? 'Aún no tienes análisis'
                  : 'Falta una sesión más',
              subtitle: pts.isEmpty
                  ? 'Haz tu primera sesión con la IA para ver tu evolución.'
                  : 'Con dos sesiones ya se dibuja tu gráfica.',
              actionLabel: 'Iniciar análisis',
              actionIcon: Icons.photo_camera_rounded,
              onAction: () => _go(const AnalysisScreen()),
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              decoration: BoxDecoration(
                color: DashColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DashColors.border),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Sparkline(
                      values: values,
                      color: DashColors.blueLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _fechaCorta((pts.first['creadoEn'] ?? '').toString()),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: DashColors.textMuted,
                        ),
                      ),
                      Text(
                        'Última: ${values.last.round()}/100 · ${_fechaCorta((pts.last['creadoEn'] ?? '').toString())}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: DashColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiBox({
    required String value,
    required String label,
    String? delta,
    bool deltaUp = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: DashColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: 4),
                Text(
                  delta,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: deltaUp
                        ? DashColors.green
                        : const Color(0xFFF87171),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: DashColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3.4 Por técnica (`Tecnicas` en `MiProgreso.jsx`) ──
  Widget _buildPorTecnicaCard(Map<String, dynamic> datos) {
    final a = datos['analisis'] is Map
        ? Map<String, dynamic>.from(datos['analisis'] as Map)
        : const <String, dynamic>{};
    final rawList = a['porTecnica'] is List
        ? a['porTecnica'] as List
        : const [];
    final porTecnica = rawList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader('Por técnica', 'Promedio'),
          const SizedBox(height: 14),
          if (porTecnica.isEmpty)
            _buildEmptyBox(
              title: 'Sin datos todavía',
              subtitle:
                  'Tus promedios por técnica aparecerán tras tus primeras sesiones.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < porTecnica.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _buildTecnicaRow(porTecnica[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTecnicaRow(Map<String, dynamic> t) {
    final rawName = (t['tecnica'] ?? '').toString();
    final tecnica = rawName.isEmpty
        ? 'Técnica'
        : '${rawName[0].toUpperCase()}${rawName.substring(1)}';
    final promedio = _toInt(t['promedio']);
    final sesiones = _toInt(t['sesiones']) ?? 0;
    final factor = ((promedio ?? 0).clamp(0, 100)) / 100.0;

    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            tecnica,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: DashColors.text1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 8,
              color: Colors.white.withValues(alpha: 0.07),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: factor,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DashColors.blueLight, Color(0xFF14B8A6)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: DashColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: '${promedio ?? '—'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: ' · $sesiones ${sesiones == 1 ? 'sesión' : 'sesiones'}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3.5 Actividad por semana (`Semanas` en `MiProgreso.jsx`) ──
  Widget _buildSemanasCard(Map<String, dynamic> datos) {
    final rawList = datos['semanas'] is List ? datos['semanas'] as List : const [];
    final semanas = rawList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    var total = 0;
    var maxVal = 1;
    for (final w in semanas) {
      final s = _toInt(w['sesiones']) ?? 0;
      final e = _toInt(w['ejercicios']) ?? 0;
      final sum = s + e;
      total += sum;
      if (sum > maxVal) maxVal = sum;
    }

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actividad por semana',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DashColors.text1,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(DashColors.blueLight, 'Ejercicios'),
                  const SizedBox(width: 10),
                  _buildLegendDot(const Color(0xFF14B8A6), 'Análisis'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (total == 0)
            _buildEmptyBox(
              title: 'Sin actividad en las últimas 8 semanas',
              subtitle:
                  'Cada ejercicio que marques y cada análisis suma aquí.',
            )
          else
            SizedBox(
              height: 145,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < semanas.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _buildSemanaBarColumn(
                        semanas[i],
                        maxVal: maxVal,
                        isCurrent: i == semanas.length - 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: DashColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSemanaBarColumn(
    Map<String, dynamic> w, {
    required int maxVal,
    required bool isCurrent,
  }) {
    final ses = _toInt(w['sesiones']) ?? 0;
    final ej = _toInt(w['ejercicios']) ?? 0;
    final n = ses + ej;
    final barMaxH = 95.0;
    final totalH = n == 0 ? 4.0 : ((n / maxVal) * barMaxH).clamp(8.0, barMaxH);
    final ejH = n == 0 ? 0.0 : totalH * (ej / n);
    final sesH = n == 0 ? 0.0 : totalH * (ses / n);
    final label = isCurrent
        ? 'Esta'
        : _fechaNumerica((w['semana'] ?? '').toString());

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          n > 0 ? '$n' : '',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10.5,
            color: DashColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 26,
            height: totalH,
            color: Colors.white.withValues(alpha: 0.05),
            child: n == 0
                ? null
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (sesH > 0)
                        Container(
                          height: sesH,
                          width: double.infinity,
                          color: const Color(0xFF14B8A6),
                        ),
                      if (ejH > 0)
                        Container(
                          height: ejH,
                          width: double.infinity,
                          color: DashColors.blueLight,
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
            color: isCurrent ? Colors.white : DashColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ── 3.6 Tu entrenador (`Entrenador` en `MiProgreso.jsx`) ──
  Widget _buildEntrenadorCard(Map<String, dynamic> datos) {
    final e = datos['entrenador'] is Map
        ? Map<String, dynamic>.from(datos['entrenador'] as Map)
        : null;

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader('Tu entrenador', null),
          const SizedBox(height: 12),
          if (e == null) ...[
            const Text(
              'Vincúlate con un entrenador para que vea tu progreso, revise tus sesiones y te asigne rutinas.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: DashColors.textSecondary,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [DashColors.blueLight, Color(0xFF8B5CF6)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials((e['nombre'] ?? '').toString()),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (e['nombre'] ?? 'Entrenador').toString(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: e['estado'] == 'aceptado'
                              ? DashColors.green.withValues(alpha: 0.14)
                              : const Color(0x1FFBBF24),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: e['estado'] == 'aceptado'
                                ? DashColors.green.withValues(alpha: 0.3)
                                : const Color(0x4DFBBF24),
                          ),
                        ),
                        child: Text(
                          e['estado'] == 'aceptado'
                              ? 'VINCULADO'
                              : 'SOLICITUD ENVIADA',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: e['estado'] == 'aceptado'
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              e['estado'] == 'aceptado'
                  ? 'Ve tu progreso, revisa tus sesiones de análisis y te asigna rutinas.'
                  : 'Esperando que acepte tu solicitud. Te avisaremos cuando responda.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                color: DashColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 3.7 Logros (`Logros` en `MiProgreso.jsx`) ──
  Widget _buildLogrosCard(Map<String, dynamic> datos) {
    final rawList = datos['logros'] is List ? datos['logros'] as List : const [];
    final logros = rawList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final hechos = logros.where((l) => l['conseguido'] == true).length;

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader('Logros', '$hechos de ${logros.length}'),
          const SizedBox(height: 14),
          if (logros.isEmpty)
            _buildEmptyBox(
              title: 'Sin logros disponibles',
              subtitle: 'Entrena y analiza tus sesiones para desbloquearlos.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < logros.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLogroTile(logros[i])),
                      const SizedBox(width: 10),
                      Expanded(
                        child: (i + 1 < logros.length)
                            ? _buildLogroTile(logros[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLogroTile(Map<String, dynamic> l) {
    final id = (l['id'] ?? '').toString();
    final titulo = (l['titulo'] ?? '').toString();
    final detalle = (l['detalle'] ?? '').toString();
    final valor = _toInt(l['valor']) ?? 0;
    final meta = (_toInt(l['meta']) ?? 1).clamp(1, 999999);
    final conseguido = l['conseguido'] == true;
    final ratio = (valor / meta).clamp(0.0, 1.0);

    final IconData icon = conseguido ? _logroIcon(id) : Icons.lock_rounded;
    const amber = Color(0xFFFBBF24);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: conseguido ? null : DashColors.surface,
        gradient: conseguido
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  amber.withValues(alpha: 0.14),
                  DashColors.surface,
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: conseguido
              ? amber.withValues(alpha: 0.45)
              : DashColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: conseguido
                  ? amber.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 17,
              color: conseguido ? amber : DashColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: conseguido ? Colors.white : DashColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detalle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              height: 1.35,
              color: DashColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Container(
              height: 5,
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  color: conseguido ? amber : DashColors.blueLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            conseguido ? '¡Conseguido!' : '$valor / $meta',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              color: DashColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  IconData _logroIcon(String id) {
    switch (id) {
      case 'primer-analisis':
        return Icons.photo_camera_rounded;
      case 'diez-analisis':
        return Icons.military_tech_rounded;
      case 'nota-80':
        return Icons.star_rounded;
      case 'racha-3':
        return Icons.local_fire_department_rounded;
      case 'racha-7':
        return Icons.bolt_rounded;
      case 'primera-rutina':
        return Icons.fitness_center_rounded;
      case 'cinco-rutinas':
        return Icons.emoji_events_rounded;
      case 'con-entrenador':
        return Icons.groups_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  // ── 3.8 Actividad reciente (`Reciente` en `MiProgreso.jsx`) ──
  Widget _buildRecienteCard(Map<String, dynamic> datos) {
    final rawList = datos['reciente'] is List
        ? datos['reciente'] as List
        : const [];
    final eventos = rawList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader('Actividad reciente', null),
          const SizedBox(height: 14),
          if (eventos.isEmpty)
            _buildEmptyBox(
              title: 'Todavía no hay actividad',
              subtitle:
                  'Tus análisis y ejercicios completados aparecerán aquí.',
            )
          else
            Column(
              children: [
                for (var i = 0; i < eventos.length; i++) ...[
                  if (i > 0)
                    Divider(height: 18, color: DashColors.border),
                  _buildEventoRow(eventos[i]),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEventoRow(Map<String, dynamic> ev) {
    final tipo = (ev['tipo'] ?? '').toString();
    final isAnalisis = tipo == 'analisis';
    final titulo = (ev['titulo'] ?? '').toString();
    final detalle = ev['detalle']?.toString();
    final creadoEn = ev['creadoEn'];

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isAnalisis
                ? DashColors.blueLight.withValues(alpha: 0.16)
                : DashColors.green.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Icon(
            isAnalisis ? Icons.gps_fixed_rounded : Icons.fitness_center_rounded,
            size: 16,
            color: isAnalisis
                ? const Color(0xFF93C5FD)
                : const Color(0xFF86EFAC),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DashColors.text1,
                ),
              ),
              if (detalle != null && detalle.trim().isNotEmpty)
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: DashColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _haceCuanto(creadoEn),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: DashColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Helpers de UI y formateo
  // ===========================================================================

  Widget _buildCardHeader(String title, String? tag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DashColors.text1,
            ),
          ),
        ),
        if (tag != null && tag.isNotEmpty)
          Text(
            tag,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: DashColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyBox({
    required String title,
    required String subtitle,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashColors.border2),
        color: Colors.white.withValues(alpha: 0.015),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: DashColors.text1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              height: 1.45,
              color: DashColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                actionIcon ?? Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashColors.blueLight,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner({
    required String message,
    String? detail,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashColors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: DashColors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFCA5A5),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFCA5A5),
                  ),
                ),
                if (detail != null &&
                    detail.trim().isNotEmpty &&
                    detail.trim() != message)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      detail,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        color: DashColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Reintentar',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF93C5FD),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF93C5FD),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return DashCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadii.panel,
      child: SizedBox(
        height: height - 34,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: DashColors.blueLight.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }

  num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  String _extractDayOfMonth(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length >= 3) {
      final d = int.tryParse(parts[2].substring(0, 2));
      if (d != null) return '$d';
    }
    return '';
  }

  String _fechaNumerica(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length >= 3) {
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2].substring(0, 2));
      if (d != null && m != null) return '$d/$m';
    }
    return isoDate;
  }

  String _fechaCorta(String rawIso) {
    if (rawIso.trim().isEmpty) return '';
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final dt = DateTime.tryParse(rawIso.trim());
    if (dt != null) {
      final local = dt.toLocal();
      return '${local.day} ${meses[local.month - 1]}';
    }
    final parts = rawIso.split('-');
    if (parts.length >= 3) {
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2].substring(0, 2));
      if (d != null && m != null && m >= 1 && m <= 12) {
        return '$d ${meses[m - 1]}';
      }
    }
    return rawIso;
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }
}

class _QuickBtnConfig {
  const _QuickBtnConfig({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;
}
