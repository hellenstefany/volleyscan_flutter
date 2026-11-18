import 'package:flutter/material.dart';

const kHours = [
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
const kSlotH = 56.0;
const kDayNames = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
const kMonthNames = [
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
const kMonthShort = [
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
const kTipos = ['Entrenamiento', 'Competencia', 'Reunión', 'Otro'];

class Ev {
  final int id;
  final String title, type, place, notes;
  final DateTime start, end;
  const Ev({
    required this.id,
    required this.title,
    required this.type,
    required this.place,
    required this.notes,
    required this.start,
    required this.end,
  });
}

/// Resultado del modal de evento: guardar (ev) o eliminar (delete).
class EvDialogResult {
  final Ev? ev;
  final bool delete;
  const EvDialogResult({this.ev, this.delete = false});
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String pad2(int n) => n.toString().padLeft(2, '0');
String fmtDate(DateTime d) => '${d.year}-${pad2(d.month)}-${pad2(d.day)}';
String fmtTime(DateTime d) => '${pad2(d.hour)}:${pad2(d.minute)}';
String fmtTod(TimeOfDay t) => '${pad2(t.hour)}:${pad2(t.minute)}';

DateTime addMonths(DateTime d, int delta) {
  final first = DateTime(d.year, d.month + delta, 1);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, d.day > last ? last : d.day);
}

List<Ev> eventsForDay(List<Ev> events, DateTime date) {
  final s = DateTime(date.year, date.month, date.day);
  final e = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  return events
      .where((ev) => !ev.start.isAfter(e) && !ev.end.isBefore(s))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
}

/// Eventos de ejemplo (relativos a hoy).
List<Ev> sampleEvents() {
  final t = DateTime.now();
  final y = t.year, m = t.month, d = t.day;
  return [
    Ev(
      id: 1,
      title: 'Entrenamiento técnico',
      type: 'Entrenamiento',
      place: 'Cancha Principal',
      notes: 'Técnica de recepción y saque',
      start: DateTime(y, m, d, 8),
      end: DateTime(y, m, d, 10),
    ),
    Ev(
      id: 2,
      title: 'Partido vs Tigres',
      type: 'Competencia',
      place: 'Estadio Municipal',
      notes: 'Uniforme completo',
      start: DateTime(y, m, d + 1, 15),
      end: DateTime(y, m, d + 1, 17, 30),
    ),
    Ev(
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
