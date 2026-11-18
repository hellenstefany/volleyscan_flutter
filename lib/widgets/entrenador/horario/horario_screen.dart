import 'package:flutter/material.dart';
import 'horario_colors.dart';
import 'horario_common_widgets.dart';
import 'horario_controls.dart';
import 'horario_event_dialog.dart';
import 'horario_events_panel.dart';
import 'horario_model.dart';
import 'horario_month_picker.dart';
import 'horario_month_view.dart';
import 'horario_week_view.dart';

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  String _view = 'semana';
  DateTime _current = DateTime.now();
  List<Ev> _events = sampleEvents();

  // ── Toast ──
  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: HC.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: HC.border2),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: HC.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: HC.t1)),
              ),
            ],
          ),
        ),
      );
  }

  // ── Navegación ──
  void _prev() => setState(
    () => _current = _view == 'semana'
        ? _current.subtract(const Duration(days: 7))
        : addMonths(_current, -1),
  );

  void _next() => setState(
    () => _current = _view == 'semana'
        ? _current.add(const Duration(days: 7))
        : addMonths(_current, 1),
  );

  Future<void> _pickMonth() async {
    final res = await showDialog<DateTime>(
      context: context,
      builder: (_) =>
          MonthPickerDialog(initialYear: _current.year, selected: _current),
    );
    if (res != null) setState(() => _current = res);
  }

  // ── Eventos ──
  Future<void> _openNew([DateTime? date, int? hour]) async {
    final fecha = date ?? DateTime.now();
    final ini = hour != null
        ? TimeOfDay(hour: hour, minute: 0)
        : const TimeOfDay(hour: 9, minute: 0);
    final fin = hour != null
        ? (hour + 2 > 23
              ? const TimeOfDay(hour: 23, minute: 59)
              : TimeOfDay(hour: hour + 2, minute: 0))
        : const TimeOfDay(hour: 11, minute: 0);
    await _showEventDialog(null, fecha, ini, fin);
  }

  Future<void> _openEdit(Ev ev) => _showEventDialog(
    ev,
    ev.start,
    TimeOfDay(hour: ev.start.hour, minute: ev.start.minute),
    TimeOfDay(hour: ev.end.hour, minute: ev.end.minute),
  );

  Future<void> _showEventDialog(
    Ev? editing,
    DateTime fecha,
    TimeOfDay ini,
    TimeOfDay fin,
  ) async {
    final res = await showDialog<EvDialogResult>(
      context: context,
      builder: (_) => EventDialog(
        editing: editing,
        initFecha: fecha,
        initIni: ini,
        initFin: fin,
      ),
    );
    if (res == null) return;
    setState(() {
      if (res.delete) {
        _events = _events.where((e) => e.id != editing!.id).toList();
        _toast('Evento eliminado');
      } else if (editing != null) {
        _events = [for (final e in _events) e.id == editing.id ? res.ev! : e];
        _toast('Evento actualizado');
      } else {
        _events = [..._events, res.ev!];
        _toast('Evento creado');
      }
    });
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 960;
        final calH = narrow
            ? (screenH * 0.72).clamp(440.0, 900.0)
            : (screenH - 140).clamp(520.0, 1000.0);

        final cal = _calArea(narrow, calH);
        final panel = EventsPanel(
          narrow: narrow,
          calH: calH,
          events: _events,
          onEdit: _openEdit,
          onNew: () => _openNew(),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CALENDARIO / HORARIO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                  color: HC.t3,
                ),
              ),
              const SizedBox(height: 14),
              if (narrow) ...[
                cal,
                const SizedBox(height: 12),
                panel,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cal),
                    const SizedBox(width: 14),
                    SizedBox(width: 210, child: panel),
                  ],
                ),
            ],
          ),
        );
      },
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
          onToday: () => setState(() => _current = DateTime.now()),
          onPickMonth: _pickMonth,
          onView: (v) => setState(() => _view = v),
        ),
        Expanded(
          child: _view == 'semana'
              ? WeekView(
                  narrow: narrow,
                  current: _current,
                  events: _events,
                  onNewAt: (day, hour) => _openNew(day, hour),
                  onEdit: _openEdit,
                )
              : MonthView(
                  current: _current,
                  events: _events,
                  onNew: (date) => _openNew(date),
                  onEdit: _openEdit,
                ),
        ),
      ],
    ),
  );
}
