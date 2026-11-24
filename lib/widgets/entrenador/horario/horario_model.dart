import 'package:flutter/material.dart';
import '../../../models/schedule_data.dart';

export '../../../models/schedule_data.dart';

const kHours = <int>[
  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
];
const kSlotH = 56.0;
const kDayNames = <String>['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
const kMonthNames = <String>[
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];
const kMonthShort = <String>[
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

/// Tipos de evento en la base de datos (`vinculos/horario.py`: `TIPOS`).
const kHorarioTipos = <(String, String)>[
  ('entrenamiento', 'Entrenamiento'),
  ('partido', 'Competencia'),
  ('evaluacion', 'Evaluación'),
  ('reunion', 'Reunión'),
  ('otro', 'Otro'),
];

/// Estados del evento (`vinculos/horario.py`: `ESTADOS`).
const kHorarioEstados = <(String, String)>[
  ('programado', 'Programado'),
  ('en_curso', 'En curso'),
  ('completado', 'Completado'),
  ('cancelado', 'Cancelado'),
];

/// Estados de asistencia (`vinculos/asistencia.py`: `ESTADOS`).
const kAsistenciaOpciones = <(String, String)>[
  ('presente', 'Presente'),
  ('tarde', 'Tarde'),
  ('ausente', 'Ausente'),
  ('justificado', 'Justificado'),
];

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

List<CoachScheduleEvent> eventsForDay(
  List<CoachScheduleEvent> events,
  DateTime date,
) {
  final s = DateTime(date.year, date.month, date.day);
  final e = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  return events
      .where((ev) => !ev.start.isAfter(e) && !ev.end.isBefore(s))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
}

/// Rango `[desde, hasta]` (`AAAA-MM-DD`) que se pide al servidor según `view` (`'semana'` | `'mes'`).
/// Replica exactamente `rangoVisible` en `VolleyScan_Next/src/app/panel_entrenador/horario/page.jsx:146-160`.
(String, String) visibleRangeFor(String view, DateTime currentDate) {
  if (view == 'semana') {
    final d = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    return (fmtDate(monday), fmtDate(sunday));
  }
  final first = DateTime(currentDate.year, currentDate.month, 1);
  final prevDays = first.weekday - 1;
  final ini = DateTime(first.year, first.month, 1 - prevDays);
  final fin = DateTime(ini.year, ini.month, ini.day + 41);
  return (fmtDate(ini), fmtDate(fin));
}

String inicialesDeNombre(String nombre) {
  final parts = nombre
      .trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .take(2)
      .toList();
  if (parts.isEmpty) return '?';
  return parts.map((p) => p[0]).join().toUpperCase();
}
