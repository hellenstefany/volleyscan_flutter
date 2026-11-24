import 'package:flutter/material.dart';

import '../../models/equipo.dart';
import '../../services/api_service.dart';
import '../../widgets/entrenador/gestion/gestion_athlete.dart';
import '../../widgets/entrenador/horario/horario_colors.dart';
import '../../widgets/entrenador/horario/horario_common_widgets.dart';
import '../../widgets/entrenador/horario/horario_event_dialog.dart';
import '../../widgets/entrenador/horario/horario_events_panel.dart';
import '../../widgets/entrenador/horario/horario_model.dart';
import '../../widgets/entrenador/horario/horario_month_picker.dart';
import '../../widgets/entrenador/horario/horario_month_view.dart';
import '../../widgets/entrenador/horario/horario_week_view.dart';

/// Pantalla "Horario" del Panel de Entrenador (`/panel_entrenador/horario`).
class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  String _view = 'semana';
  DateTime _current = DateTime.now();

  List<CoachScheduleEvent> _events = const <CoachScheduleEvent>[];
  List<CoachScheduleEvent> _proximos = const <CoachScheduleEvent>[];
  List<Equipo> _equipos = const <Equipo>[];
  List<EntrenadorDeportista> _deportistas = const <EntrenadorDeportista>[];

  bool _cargando = true;
  String _errorCarga = '';
  int _reqToken = 0;

  @override
  void initState() {
    super.initState();
    _cargarCatalogos();
    _recargarTodo();
  }

  Future<void> _cargarCatalogos() async {
    final eqF = ApiService().listarEquiposEntrenador().catchError((_) => const <Equipo>[]);
    final depF = ApiService().listarDeportistasEntrenador().catchError((_) => const <EntrenadorDeportista>[]);
    final res = await Future.wait([eqF, depF]);
    if (!mounted) return;
    setState(() {
      _equipos = res[0] as List<Equipo>;
      _deportistas = res[1] as List<EntrenadorDeportista>;
    });
  }

  Future<void> _cargarRangoVisible() async {
    final token = ++_reqToken;
    final (desde, hasta) = visibleRangeFor(_view, _current);
    if (mounted) {
      setState(() {
        _cargando = true;
        _errorCarga = '';
      });
    }
    try {
      final list = await ApiService().listarEventosHorarioEntrenador(desde: desde, hasta: hasta);
      if (!mounted || token != _reqToken) return;
      setState(() {
        _events = list;
        _cargando = false;
        _errorCarga = '';
      });
    } on ApiException catch (e) {
      if (!mounted || token != _reqToken || e.isUnauthorized) return;
      setState(() {
        _cargando = false;
        _errorCarga = e.message;
      });
    } catch (_) {
      if (!mounted || token != _reqToken) return;
      setState(() {
        _cargando = false;
        _errorCarga = 'No se pudo cargar el horario.';
      });
    }
  }

  Future<void> _cargarProximos() async {
    final hoy = DateTime.now();
    try {
      final list = await ApiService().listarEventosHorarioEntrenador(
        desde: fmtDate(hoy),
        hasta: fmtDate(hoy.add(const Duration(days: 60))),
      );
      if (!mounted) return;
      setState(() => _proximos = list);
    } catch (_) {}
  }

  Future<void> _recargarTodo() => Future.wait([_cargarRangoVisible(), _cargarProximos()]);

  void _cambiarFecha(DateTime nueva, {String? nuevoView}) {
    setState(() {
      _current = nueva;
      if (nuevoView != null) _view = nuevoView;
    });
    _cargarRangoVisible();
  }

  void _prev() => _cambiarFecha(_view == 'semana' ? _current.subtract(const Duration(days: 7)) : addMonths(_current, -1));

  void _next() => _cambiarFecha(_view == 'semana' ? _current.add(const Duration(days: 7)) : addMonths(_current, 1));

  Future<void> _pickMonth() async {
    final res = await showDialog<DateTime>(
      context: context,
      builder: (_) => MonthPickerDialog(initialYear: _current.year, selected: _current),
    );
    if (res != null) _cambiarFecha(res);
  }

  Future<void> _openNew([DateTime? date, int? hour]) async {
    final fecha = date ?? DateTime.now();
    final ini = hour != null ? TimeOfDay(hour: hour, minute: 0) : const TimeOfDay(hour: 9, minute: 0);
    final fin = hour != null
        ? (hour + 2 > 23 ? const TimeOfDay(hour: 23, minute: 59) : TimeOfDay(hour: hour + 2, minute: 0))
        : const TimeOfDay(hour: 11, minute: 0);
    await _showEventDialog(null, fecha, ini, fin);
  }

  Future<void> _openEdit(CoachScheduleEvent ev) => _showEventDialog(
        ev,
        ev.start,
        TimeOfDay(hour: ev.start.hour, minute: ev.start.minute),
        TimeOfDay(hour: ev.end.hour, minute: ev.end.minute),
      );

  Future<void> _showEventDialog(CoachScheduleEvent? editing, DateTime fecha, TimeOfDay ini, TimeOfDay fin) async {
    final outcome = await showDialog<EventDialogOutcome>(
      context: context,
      builder: (_) => EventDialog(
        editing: editing,
        initFecha: fecha,
        initIni: ini,
        initFin: fin,
        equipos: _equipos,
        deportistas: _deportistas,
      ),
    );
    if (!mounted || outcome == null) return;
    if (outcome == EventDialogOutcome.openAttendance && editing != null) {
      final savedAsis = await showDialog<bool>(
        context: context,
        builder: (_) => HorarioAttendanceDialog(eventoId: editing.id),
      );
      if (savedAsis == true && mounted) await _recargarTodo();
      return;
    }
    await _recargarTodo();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Material(
      color: HC.bg2,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 960;
          final calH = narrow ? (screenH * 0.72).clamp(440.0, 900.0) : (screenH - 140).clamp(520.0, 1000.0);
          final cal = _calArea(narrow, calH);
          final panel = EventsPanel(narrow: narrow, calH: calH, events: _proximos, onEdit: _openEdit, onNew: _openNew);

          return RefreshIndicator(
            color: HC.blue,
            backgroundColor: HC.card,
            onRefresh: _recargarTodo,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(narrow ? 12 : 22, narrow ? 60 : 20, narrow ? 12 : 22, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'CALENDARIO / HORARIO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: HC.t3),
                  ),
                  const SizedBox(height: 14),
                  HorarioStatusBanner(loading: _cargando, error: _errorCarga, onRetry: _recargarTodo),
                  if (narrow) ...[cal, const SizedBox(height: 12), panel] else Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child: cal), const SizedBox(width: 14), SizedBox(width: 210, child: panel)],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _calArea(bool narrow, double height) => Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: hBox(HC.card, 14),
        child: Column(
          children: [
            CalendarControls(
              narrow: narrow,
              current: _current,
              view: _view,
              onPrev: _prev,
              onNext: _next,
              onToday: () => _cambiarFecha(DateTime.now()),
              onPickMonth: _pickMonth,
              onView: (v) {
                if (v != _view) _cambiarFecha(_current, nuevoView: v);
              },
            ),
            Expanded(
              child: _view == 'semana'
                  ? WeekView(narrow: narrow, current: _current, events: _events, onNewAt: (day, hour) => _openNew(day, hour), onEdit: _openEdit)
                  : MonthView(current: _current, events: _events, onNew: (date) => _openNew(date), onEdit: _openEdit),
            ),
          ],
        ),
      );
}
