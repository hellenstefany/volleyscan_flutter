import 'package:flutter/material.dart';
import '../models/schedule_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/dash_colors.dart';
import '../widgets/usuario/drawer/menu_button.dart';
import '../widgets/usuario/entrenador/coach_status_widgets.dart';
import '../widgets/usuario/horario/schedule_day_group.dart';
import '../widgets/usuario/horario/schedule_header_and_next.dart';
import '../widgets/usuario/horario/schedule_month_nav.dart';

/// Pantalla "Horario" (`/usuario/horario`) replicando
/// `VolleyScan_Next/src/app/usuario/horario/page.jsx` y `horario.module.css`.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _mes = _firstDayOfMonth(DateTime.now());
  List<ScheduleEvent> _eventos = const <ScheduleEvent>[];
  List<ScheduleEvent> _proximos = const <ScheduleEvent>[];
  bool _cargandoMes = true;
  String _error = '';
  int _mesReqId = 0;

  static DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  static DateTime _lastDayOfMonth(DateTime d) =>
      DateTime(d.year, d.month + 1, 0);

  @override
  void initState() {
    super.initState();
    _cargarMes(_mes);
    _cargarProximos();
  }

  Future<void> _cargarMes(DateTime mes, {bool silent = false}) async {
    final reqId = ++_mesReqId;
    if (!silent && mounted) {
      setState(() {
        _cargandoMes = true;
        _error = '';
      });
    }

    final desde = fechaIsoLocal(_firstDayOfMonth(mes));
    final hasta = fechaIsoLocal(_lastDayOfMonth(mes));

    try {
      final data = await ApiService().miHorario(desde: desde, hasta: hasta);
      if (!mounted || reqId != _mesReqId) return;
      setState(() {
        _eventos = data;
        _error = '';
        _cargandoMes = false;
      });
    } on ApiException catch (e) {
      if (!mounted || reqId != _mesReqId) return;
      setState(() {
        _error = e.message;
        _cargandoMes = false;
      });
    } catch (_) {
      if (!mounted || reqId != _mesReqId) return;
      setState(() {
        _error = 'Ocurrió un error inesperado.';
        _cargandoMes = false;
      });
    }
  }

  Future<void> _cargarProximos() async {
    final hoy = DateTime.now();
    final fin = hoy.add(const Duration(days: 60));
    try {
      final data = await ApiService().miHorario(
        desde: fechaIsoLocal(hoy),
        hasta: fechaIsoLocal(fin),
      );
      if (!mounted) return;
      setState(() => _proximos = data);
    } catch (_) {
      // Si falla la carga secundaria de próximos, el mes principal maneja el error.
    }
  }

  Future<void> _refrescarTodo() async {
    await Future.wait<void>([
      _cargarMes(_mes, silent: true),
      _cargarProximos(),
    ]);
  }

  void _cambiarMes(int delta) {
    final nuevo = DateTime(_mes.year, _mes.month + delta, 1);
    setState(() => _mes = nuevo);
    _cargarMes(nuevo);
  }

  void _irAHoy() {
    final hoyMes = _firstDayOfMonth(DateTime.now());
    if (hoyMes.year == _mes.year && hoyMes.month == _mes.month) return;
    setState(() => _mes = hoyMes);
    _cargarMes(hoyMes);
  }

  ScheduleEvent? get _siguienteEvento {
    final now = DateTime.now();
    final candidatos = _proximos.where((e) {
      if (e.isCancelled) return false;
      final end = e.endDateTime;
      return end != null && end.isAfter(now);
    }).toList();
    candidatos.sort((a, b) {
      final da = a.startDateTime ?? DateTime(2100);
      final db = b.startDateTime ?? DateTime(2100);
      return da.compareTo(db);
    });
    return candidatos.isNotEmpty ? candidatos.first : null;
  }

  List<MapEntry<String, List<ScheduleEvent>>> get _diasAgrupados {
    final mapa = <String, List<ScheduleEvent>>{};
    for (final e in _eventos) {
      mapa.putIfAbsent(e.fecha, () => <ScheduleEvent>[]).add(e);
    }
    final entradas = mapa.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entradas;
  }

  ({int fue, int total}) get _resumenMes {
    final marcados = _eventos.where((e) => e.miAsistencia != null).toList();
    final fue = marcados
        .where((e) => e.miAsistencia == 'presente' || e.miAsistencia == 'tarde')
        .length;
    return (fue: fue, total: marcados.length);
  }

  @override
  Widget build(BuildContext context) {
    final siguiente = _siguienteEvento;
    final dias = _diasAgrupados;
    final resumen = _resumenMes;
    final hoyIso = fechaIsoLocal(DateTime.now());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashColors.bg,
      drawer: const UserDrawer(selectedId: 'horario'),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.userPanelBg),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              ScheduleTopBar(
                onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: DashColors.blueLight,
                  backgroundColor: DashColors.card,
                  onRefresh: _refrescarTodo,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 48),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SchedulePageHeader(),
                            if (_error.isNotEmpty)
                              CoachAlertBanner(message: _error),
                            if (siguiente != null)
                              NextEventBanner(event: siguiente),
                            ScheduleMonthNav(
                              month: _mes,
                              attendedCount: resumen.fue,
                              totalAttendanceCount: resumen.total,
                              onPreviousMonth: () => _cambiarMes(-1),
                              onToday: _irAHoy,
                              onNextMonth: () => _cambiarMes(1),
                            ),
                            if (_cargandoMes)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 18),
                                child: Text(
                                  'Cargando agenda…',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: DashColors.muted,
                                  ),
                                ),
                              )
                            else if (_error.isNotEmpty)
                              ScheduleErrorRetry(onRetry: _refrescarTodo)
                            else if (dias.isEmpty)
                              const ScheduleEmptyState()
                            else
                              ...dias.map(
                                (entry) => ScheduleDayGroup(
                                  isoDate: entry.key,
                                  events: entry.value,
                                  isToday: entry.key == hoyIso,
                                ),
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
      ),
    );
  }
}
