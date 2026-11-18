import 'package:flutter/material.dart';

import 'package:volleyscan_mobile/models/profile_data.dart';
import 'package:volleyscan_mobile/services/api_service.dart';
import 'package:volleyscan_mobile/theme/app_theme.dart';
import 'package:volleyscan_mobile/theme/dash_colors.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_activity_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_chart.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_kpis.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_models.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_panel.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_players_list.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_session_dialog.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_theme.dart';
import 'package:volleyscan_mobile/widgets/entrenador/dashboard/dashboard_topbar.dart';

// Nota: se llama DashboardScreen para coincidir con EntrenadorShell
// (que la importa con `as entrenador`).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProfileData? _entrenador;
  bool _loadingUser = true;

  EntrenadorDashboardData? _data;
  bool _loadingDashboard = true;
  String? _errorDashboard;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    final guardado = await ApiService.getUsuario();
    if (mounted && guardado != null) {
      setState(() => _entrenador = ProfileData.fromJson(guardado));
    }

    await Future.wait([
      _cargarEntrenador(),
      _cargarDashboard(),
    ]);
  }

  Future<void> _cargarEntrenador() async {
    if (mounted) setState(() => _loadingUser = true);
    try {
      final raw = await ApiService().me();
      if (!mounted) return;
      setState(() {
        _entrenador = ProfileData.fromJson(raw);
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUser = false);
    }
  }

  Future<void> _cargarDashboard() async {
    if (mounted) {
      setState(() {
        _loadingDashboard = true;
        _errorDashboard = null;
      });
    }
    try {
      final res = await ApiService().dashboardEntrenador();
      if (!mounted) return;
      setState(() {
        _data = res;
        _loadingDashboard = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isUnauthorized) return; // ApiService ya redirige a LoginScreen
      const fallbackMsg = 'No se pudo cargar el resumen del dashboard';
      final msg = e.message.isNotEmpty ? e.message : fallbackMsg;
      setState(() {
        _errorDashboard = msg;
        _loadingDashboard = false;
      });
      showAppToast(context, fallbackMsg, type: 'error');
    } catch (_) {
      if (!mounted) return;
      const msg = 'No se pudo cargar el resumen del dashboard';
      setState(() {
        _errorDashboard = msg;
        _loadingDashboard = false;
      });
      showAppToast(context, msg, type: 'error');
    }
  }

  String? get _nombreCompleto {
    final u = _entrenador;
    if (u == null) return null;
    final full = [u.nombre.trim(), u.apellido.trim()]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return full.isNotEmpty ? full : null;
  }

  Future<void> _openNewSession() async {
    final createdTitle = await showDialog<String>(
      context: context,
      barrierColor: DashColors.modalOverlay,
      builder: (_) => const DashboardSessionDialog(),
    );
    if (createdTitle == null || !mounted) return;

    showAppToast(
      context,
      'Sesión "$createdTitle" guardada en tu horario',
      type: 'success',
    );
    await _cargarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => _buildBody(box.maxWidth < 760),
    );
  }

  Widget _buildBody(bool narrow) {
    final partidos =
        _data?.ultimosPartidos ?? const <EntrenadorUltimoPartido>[];
    final eventos = _data?.eventosProximos ?? const <EntrenadorEventoProximo>[];

    return Material(
      color: DashboardTheme.bgSecondary,
      child: Column(
        children: [
          DashboardTopbar(
            narrow: narrow,
            nombreCompleto: _nombreCompleto,
            email: _entrenador?.email,
            loadingUser: _loadingUser,
            onNewSession: _openNewSession,
          ),
          Expanded(
            child: RefreshIndicator(
              color: DashboardTheme.blue,
              backgroundColor: DashboardTheme.bgCard,
              onRefresh: _cargarTodo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(narrow ? 16 : 28),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final threeCols = w >= 1000;

                    final chartPanel = DashboardPanel(
                      title: 'Efectividad en últimos partidos (% Sets)',
                      child: DashboardChart(
                        narrow: narrow,
                        partidos: partidos,
                        loading: _loadingDashboard,
                        error: _errorDashboard,
                        onRetry: _cargarDashboard,
                      ),
                    );
                    final matchesPanel = DashboardPanel(
                      title: 'Últimos partidos',
                      child: DashboardPlayersList(
                        partidos: partidos,
                        loading: _loadingDashboard,
                        error: _errorDashboard,
                        onRetry: _cargarDashboard,
                        onPartidoTap: (p) => showAppToast(
                          context,
                          'Partido vs ${p.rival}: ${p.setsGanados}-${p.setsPerdidos}',
                          type: 'success',
                        ),
                      ),
                    );
                    final eventsPanel = DashboardPanel(
                      title: 'Próximos eventos (7 días)',
                      child: DashboardActivityList(
                        eventos: eventos,
                        loading: _loadingDashboard,
                        error: _errorDashboard,
                        onRetry: _cargarDashboard,
                      ),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DashboardKpis(
                          width: w,
                          data: _data,
                          loading: _loadingDashboard,
                          error: _errorDashboard,
                          onRetry: _cargarDashboard,
                        ),
                        SizedBox(height: narrow ? 16 : 22),
                        if (threeCols)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: chartPanel),
                              const SizedBox(width: 16),
                              Expanded(child: matchesPanel),
                              const SizedBox(width: 16),
                              Expanded(child: eventsPanel),
                            ],
                          )
                        else ...[
                          chartPanel,
                          const SizedBox(height: 14),
                          matchesPanel,
                          const SizedBox(height: 14),
                          eventsPanel,
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
