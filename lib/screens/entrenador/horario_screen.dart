import 'package:flutter/material.dart';

// ───────── Colores (de tu :root en Horario.css) ─────────
class _C {
  static const bg2 = Color(0xFF0C1220);
  static const card = Color(0xFF0E1525);
  static const card2 = Color(0xFF121D30);
  static const card3 = Color(0xFF172038);
  static const hover = Color(0xFF1A2540);
  static const border = Color(0x0FFFFFFF); // rgba(255,255,255,.06)
  static const border2 = Color(0x1CFFFFFF); // rgba(255,255,255,.11)
  static const blue = Color(0xFF3B82F6);
  static const blue2 = Color(0xFF60A5FA);
  static const purple = Color(0xFF6D28D9);
  static const purple2 = Color(0xFF8B5CF6);
  static const purpleG1 = Color(0xFF5B21B6);
  static const purpleG2 = Color(0xFF7C3AED);
  static const green = Color(0xFF10B981);
  static const t1 = Color(0xFFEEF4FF);
  static const t2 = Color(0xFF7A90B8);
  static const t3 = Color(0xFF374A6E);
}

const _hours = [
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
];
const _slotH = 56.0;
const _dayNames = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
const _monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];
const _monthShort = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];
const _tipos = ['Entrenamiento', 'Competencia', 'Reunión', 'Otro'];

// Colores por tipo de evento
Color _evBg(String t) => switch (t) {
  'Entrenamiento' => const Color(0xFF1C3461),
  'Competencia' => const Color(0xFF4A1020),
  'Reunión' => const Color(0xFF1A2E1A),
  _ => const Color(0xFF2A1F40),
};
Color _evBorder(String t) => switch (t) {
  'Entrenamiento' => _C.blue,
  'Competencia' => const Color(0xFFDC2626),
  'Reunión' => _C.green,
  _ => _C.purple2,
};
Color _dotFg(String t) => switch (t) {
  'Entrenamiento' => _C.blue2,
  'Competencia' => const Color(0xFFF87171),
  'Reunión' => const Color(0xFF34D399),
  _ => _C.purple2,
};
IconData _tipoIcon(String t) => switch (t) {
  'Competencia' => Icons.emoji_events,
  'Reunión' => Icons.groups,
  _ => Icons.sports_volleyball,
};

// ───────── Modelo y utilidades ─────────
class _Ev {
  final int id;
  final String title, type, place, notes;
  final DateTime start, end;
  const _Ev({
    required this.id,
    required this.title,
    required this.type,
    required this.place,
    required this.notes,
    required this.start,
    required this.end,
  });
}

class _DlgResult {
  final _Ev? ev;
  final bool delete;
  const _DlgResult({this.ev, this.delete = false});
}

bool _same(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _two(int n) => n.toString().padLeft(2, '0');
String _fmtDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
String _fmtTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String _fmtTod(TimeOfDay t) => '${_two(t.hour)}:${_two(t.minute)}';

DateTime _addMonths(DateTime d, int delta) {
  final first = DateTime(d.year, d.month + delta, 1);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, d.day > last ? last : d.day);
}

// ───────── Pantalla ─────────
class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  String _view = 'semana';
  DateTime _current = DateTime.now();
  late List<_Ev> _events;

  @override
  void initState() {
    super.initState();
    final t = DateTime.now();
    final y = t.year, m = t.month, d = t.day;
    _events = [
      _Ev(
        id: 1,
        title: 'Entrenamiento técnico',
        type: 'Entrenamiento',
        place: 'Cancha Principal',
        notes: 'Técnica de recepción y saque',
        start: DateTime(y, m, d, 8),
        end: DateTime(y, m, d, 10),
      ),
      _Ev(
        id: 2,
        title: 'Partido vs Tigres',
        type: 'Competencia',
        place: 'Estadio Municipal',
        notes: 'Uniforme completo',
        start: DateTime(y, m, d + 1, 15),
        end: DateTime(y, m, d + 1, 17, 30),
      ),
      _Ev(
        id: 3,
        title: 'Reunión táctica',
        type: 'Reunión',
        place: 'Sala de conferencias',
        notes: 'Revisión de videos',
        start: DateTime(y, m, d + 3, 19),
        end: DateTime(y, m, d + 3, 20, 30),
      ),
    ];
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _C.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _C.border2),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: _C.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg, style: const TextStyle(color: _C.t1)),
              ),
            ],
          ),
        ),
      );
  }

  // ───────── Acciones ─────────
  void _prev() => setState(
    () => _current = _view == 'semana'
        ? _current.subtract(const Duration(days: 7))
        : _addMonths(_current, -1),
  );

  void _next() => setState(
    () => _current = _view == 'semana'
        ? _current.add(const Duration(days: 7))
        : _addMonths(_current, 1),
  );

  Future<void> _pickMonth() async {
    final res = await showDialog<DateTime>(
      context: context,
      builder: (_) =>
          _MonthPickerDialog(initialYear: _current.year, selected: _current),
    );
    if (res != null) setState(() => _current = res);
  }

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

  Future<void> _openEdit(_Ev ev) async {
    await _showEventDialog(
      ev,
      ev.start,
      TimeOfDay(hour: ev.start.hour, minute: ev.start.minute),
      TimeOfDay(hour: ev.end.hour, minute: ev.end.minute),
    );
  }

  Future<void> _showEventDialog(
    _Ev? editing,
    DateTime fecha,
    TimeOfDay ini,
    TimeOfDay fin,
  ) async {
    final res = await showDialog<_DlgResult>(
      context: context,
      builder: (_) => _EventDialog(
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

  List<DateTime> _weekDays() {
    final d = DateTime(_current.year, _current.month, _current.day);
    final monday = d.subtract(Duration(days: d.weekday - 1));
    return [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];
  }

  List<_Ev> _eventsForDay(DateTime date) {
    final s = DateTime(date.year, date.month, date.day);
    final e = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    final list =
        _events
            .where((ev) => !ev.start.isAfter(e) && !ev.end.isBefore(s))
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  // ───────── Build ─────────
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
        final panel = _eventsPanel(narrow, calH);

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
                  color: _C.t3,
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

  // ───────── Calendario ─────────
  Widget _calArea(bool narrow, double height) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: _box(_C.card, 14),
      child: Column(
        children: [
          _controls(narrow),
          Expanded(child: _view == 'semana' ? _weekView(narrow) : _monthView()),
        ],
      ),
    );
  }

  Widget _controls(bool narrow) {
    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CtrlBtn(icon: Icons.chevron_left, onTap: _prev),
        const SizedBox(width: 6),
        _CtrlBtn(icon: Icons.chevron_right, onTap: _next),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => setState(() => _current = DateTime.now()),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _C.card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _C.border2),
            ),
            child: const Text(
              'Hoy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.t1,
              ),
            ),
          ),
        ),
      ],
    );

    final center = InkWell(
      onTap: _pickMonth,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_monthNames[_current.month - 1]} ${_current.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.t1,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: _C.t1),
          ],
        ),
      ),
    );

    final right = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ViewBtn(
          label: 'Semana',
          active: _view == 'semana',
          onTap: () => setState(() => _view = 'semana'),
        ),
        const SizedBox(width: 6),
        _ViewBtn(
          label: 'Mes',
          active: _view == 'mes',
          onTap: () => setState(() => _view = 'mes'),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: narrow
          ? Column(
              children: [
                Row(children: [left, const Spacer(), right]),
                const SizedBox(height: 6),
                center,
              ],
            )
          : Row(
              children: [
                left,
                Expanded(child: Center(child: center)),
                right,
              ],
            ),
    );
  }

  // ───────── Vista semana ─────────
  Widget _weekView(bool narrow) {
    final days = _weekDays();
    final today = DateTime.now();
    final timeW = narrow ? 44.0 : 52.0;
    final minW = timeW + 588;

    return LayoutBuilder(
      builder: (context, c) {
        final scrolls = c.maxWidth < minW;
        final width = scrolls ? minW : c.maxWidth;

        final header = Container(
          decoration: const BoxDecoration(
            color: _C.card,
            border: Border(bottom: BorderSide(color: _C.border2)),
          ),
          child: Row(
            children: [
              SizedBox(width: timeW),
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      border: i < 6
                          ? const Border(right: BorderSide(color: _C.border))
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayNames[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: _same(days[i], today) ? _C.blue2 : _C.t3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${days[i].day} ${_monthShort[days[i].month - 1]}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _same(days[i], today)
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: _same(days[i], today) ? _C.blue2 : _C.t2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );

        final timeCol = Container(
          width: timeW,
          decoration: const BoxDecoration(
            color: _C.card,
            border: Border(right: BorderSide(color: _C.border)),
          ),
          child: Column(
            children: [
              for (final h in _hours)
                Container(
                  height: _slotH,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _C.border)),
                  ),
                  child: Text(
                    '${_two(h)}:00',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                      color: _C.t3,
                    ),
                  ),
                ),
            ],
          ),
        );

        final content = SizedBox(
          width: width,
          child: Column(
            children: [
              header,
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      timeCol,
                      for (var i = 0; i < 7; i++)
                        Expanded(child: _dayColumn(days[i], last: i == 6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return scrolls
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              )
            : content;
      },
    );
  }

  Widget _dayColumn(DateTime day, {required bool last}) {
    final evs = _events.where((e) => _same(e.start, day) && e.start.hour >= 6);

    return Container(
      height: _hours.length * _slotH,
      decoration: BoxDecoration(
        border: last ? null : const Border(right: BorderSide(color: _C.border)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final h = (d.localPosition.dy ~/ _slotH).clamp(0, 17) + 6;
                _openNew(day, h);
              },
              child: Column(
                children: [
                  for (final _ in _hours)
                    Container(
                      height: _slotH,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: _C.border)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final ev in evs)
            Positioned(
              left: 3,
              right: 3,
              top:
                  (ev.start.hour - 6) * _slotH +
                  (ev.start.minute / 60) * _slotH,
              height: ((ev.end.difference(ev.start).inMinutes / 60) * _slotH)
                  .clamp(42.0, double.infinity),
              child: GestureDetector(
                onTap: () => _openEdit(ev),
                child: _EvBox(
                  bg: _evBg(ev.type),
                  border: _evBorder(ev.type),
                  radius: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      maxHeight: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ev.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_fmtTime(ev.start)} - ${_fmtTime(ev.end)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          if (ev.place.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              ev.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ───────── Vista mes ─────────
  Widget _monthView() {
    final y = _current.year, m = _current.month;
    final first = DateTime(y, m, 1);
    final prevDays = first.weekday - 1;
    final today = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              for (final d in _dayNames)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: _C.t3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var row = 0; row < 6; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: col < 6 ? 4 : 0),
                        child: _monthCell(
                          DateTime(y, m, 1 - prevDays + row * 7 + col),
                          m,
                          today,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _monthCell(DateTime date, int month, DateTime today) {
    final isToday = _same(date, today);
    final other = date.month != month;
    final evs = _eventsForDay(date).take(3).toList();

    return Opacity(
      opacity: other ? 0.35 : 1,
      child: InkWell(
        onTap: () => _openNew(date),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 92,
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: isToday ? _C.blue.withValues(alpha: 0.07) : _C.card2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isToday ? _C.blue : _C.border),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isToday ? _C.blue2 : _C.t2,
                  ),
                ),
                for (final ev in evs)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: GestureDetector(
                      onTap: () => _openEdit(ev),
                      child: _EvBox(
                        bg: _evBg(ev.type),
                        border: _evBorder(ev.type),
                        radius: 4,
                        width: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${_fmtTime(ev.start)} ${ev.title.length > 12 ? '${ev.title.substring(0, 12)}...' : ev.title}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
      ),
    );
  }

  // ───────── Panel de próximos eventos ─────────
  Widget _eventsPanel(bool narrow, double calH) {
    final now = DateTime.now();
    final future = _events.where((e) => e.end.isAfter(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final list = future.take(10).toList();

    final items = list.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No hay eventos próximos',
                style: TextStyle(fontSize: 12, color: _C.t3),
              ),
            ),
          )
        : Column(
            children: [
              for (final ev in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _openEdit(ev),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _dotFg(ev.type).withValues(alpha: 0.15),
                            ),
                            child: Icon(
                              _tipoIcon(ev.type),
                              size: 13,
                              color: _dotFg(ev.type),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ev.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: _C.t1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ev.start.day} ${_monthShort[ev.start.month - 1]} • ${_fmtTime(ev.start)}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: _C.t2,
                                  ),
                                ),
                                if (ev.place.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Text(
                                      ev.place,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _C.t3,
                                      ),
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
            ],
          );

    final boton = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openNew(),
        borderRadius: BorderRadius.circular(9),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.purpleG1, _C.purpleG2],
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: _C.purple.withValues(alpha: 0.35),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 14, color: Colors.white),
              SizedBox(width: 7),
              Text(
                'Nuevo evento',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Próximos eventos',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: _C.t1,
          ),
        ),
        const SizedBox(height: 12),
        if (narrow)
          items
        else
          Expanded(child: SingleChildScrollView(child: items)),
        const SizedBox(height: 12),
        boton,
      ],
    );

    return Container(
      height: narrow ? null : calH,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: _box(_C.card, 14),
      child: content,
    );
  }
}

// ───────── Helpers de estilo ─────────
BoxDecoration _box(Color c, double r) => BoxDecoration(
  color: c,
  borderRadius: BorderRadius.circular(r),
  border: Border.all(color: _C.border),
);

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _C.card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _C.border2),
      ),
      child: Icon(icon, size: 16, color: _C.t2),
    ),
  );
}

class _ViewBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ViewBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: active
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_C.purpleG1, _C.purpleG2],
              )
            : null,
        color: active ? null : _C.card2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? Colors.transparent : _C.border2),
        boxShadow: active
            ? [
                BoxShadow(
                  color: _C.purple.withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : _C.t2,
        ),
      ),
    ),
  );
}

/// Caja con barra de color a la izquierda (border-left del CSS).
class _EvBox extends StatelessWidget {
  final Color bg, border;
  final double radius, width;
  final EdgeInsets padding;
  final Widget child;
  const _EvBox({
    required this.bg,
    required this.border,
    required this.radius,
    required this.padding,
    required this.child,
    this.width = 3,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          left: BorderSide(color: border, width: width),
        ),
      ),
      child: Padding(padding: padding, child: child),
    ),
  );
}

// ───────── Selector de mes ─────────
class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final DateTime selected;
  const _MonthPickerDialog({required this.initialYear, required this.selected});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year = widget.initialYear;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _C.card2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _C.border2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seleccionar mes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.t1,
                      ),
                    ),
                  ),
                  _CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [
                  for (var i = 0; i < 12; i++)
                    InkWell(
                      onTap: () =>
                          Navigator.pop(context, DateTime(_year, i + 1, 1)),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient:
                              (widget.selected.month == i + 1 &&
                                  widget.selected.year == _year)
                              ? const LinearGradient(
                                  colors: [_C.purpleG1, _C.purpleG2],
                                )
                              : null,
                          color:
                              (widget.selected.month == i + 1 &&
                                  widget.selected.year == _year)
                              ? null
                              : _C.card3,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _C.border),
                        ),
                        child: Text(
                          _monthNames[i].substring(0, 3),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color:
                                (widget.selected.month == i + 1 &&
                                    widget.selected.year == _year)
                                ? Colors.white
                                : _C.t2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CtrlBtn(
                    icon: Icons.chevron_left,
                    onTap: () => setState(() => _year--),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$_year',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.t1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CtrlBtn(
                    icon: Icons.chevron_right,
                    onTap: () => setState(() => _year++),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseBtn({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _C.card3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.close, size: 14, color: _C.t2),
    ),
  );
}

// ───────── Modal de evento ─────────
class _EventDialog extends StatefulWidget {
  final _Ev? editing;
  final DateTime initFecha;
  final TimeOfDay initIni, initFin;
  const _EventDialog({
    required this.editing,
    required this.initFecha,
    required this.initIni,
    required this.initFin,
  });

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.editing?.title ?? '',
  );
  late final TextEditingController _place = TextEditingController(
    text: widget.editing?.place ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.editing?.notes ?? '',
  );
  late String _type = widget.editing?.type ?? 'Entrenamiento';
  late DateTime _fecha = widget.initFecha;
  late TimeOfDay _ini = widget.initIni;
  late TimeOfDay _fin = widget.initFin;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _pickHora(bool inicio) async {
    final t = await showTimePicker(
      context: context,
      initialTime: inicio ? _ini : _fin,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t != null) setState(() => inicio ? _ini = t : _fin = t);
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    final start = DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _ini.hour,
      _ini.minute,
    );
    final end = DateTime(
      _fecha.year,
      _fecha.month,
      _fecha.day,
      _fin.hour,
      _fin.minute,
    );
    if (!end.isAfter(start)) {
      setState(() => _error = 'La hora fin debe ser posterior');
      return;
    }
    Navigator.pop(
      context,
      _DlgResult(
        ev: _Ev(
          id: widget.editing?.id ?? DateTime.now().millisecondsSinceEpoch,
          title: _title.text.trim(),
          type: _type,
          place: _place.text.trim(),
          notes: _notes.text.trim(),
          start: start,
          end: end,
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: _C.card3,
    hintText: hint,
    hintStyle: const TextStyle(color: _C.t3, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: _C.border2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: _C.border2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: _C.blue),
    ),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: _C.t2,
        ),
      ),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _pickerBox(String text, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(9),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: _C.card3,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _C.border2),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: _C.t1)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return Dialog(
      backgroundColor: _C.card2,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _C.border2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    editing ? Icons.edit : Icons.event_available,
                    size: 16,
                    color: _C.t1,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      editing ? 'Editar evento' : 'Nuevo evento',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.t1,
                      ),
                    ),
                  ),
                  _CloseBtn(onTap: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              _field(
                'Nombre del evento',
                TextField(
                  controller: _title,
                  style: const TextStyle(color: _C.t1, fontSize: 13),
                  decoration: _deco('Ej. Entrenamiento técnico'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      'Tipo',
                      DropdownButtonFormField<String>(
                        value: _type,
                        isExpanded: true,
                        dropdownColor: _C.card3,
                        style: const TextStyle(color: _C.t1, fontSize: 13),
                        decoration: _deco(''),
                        items: [
                          for (final t in _tipos)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setState(() => _type = v ?? _type),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'Lugar',
                      TextField(
                        controller: _place,
                        style: const TextStyle(color: _C.t1, fontSize: 13),
                        decoration: _deco('Cancha 1…'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field('Fecha', _pickerBox(_fmtDate(_fecha), _pickFecha)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      'Hora inicio',
                      _pickerBox(_fmtTod(_ini), () => _pickHora(true)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      'Hora fin',
                      _pickerBox(_fmtTod(_fin), () => _pickHora(false)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(
                'Notas',
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  style: const TextStyle(color: _C.t1, fontSize: 13),
                  decoration: _deco('Detalles adicionales…'),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFF87171),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _C.border)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    if (editing)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(
                          context,
                          const _DlgResult(delete: true),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 15),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF87171),
                          backgroundColor: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.08),
                          side: BorderSide(
                            color: const Color(
                              0xFFDC2626,
                            ).withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                      ),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.t2,
                        side: const BorderSide(color: _C.border2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _save,
                        borderRadius: BorderRadius.circular(9),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_C.purpleG1, _C.purpleG2],
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
