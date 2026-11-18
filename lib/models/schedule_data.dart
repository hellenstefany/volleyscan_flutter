/// Modelos de la pantalla "Horario" (`/usuario/horario`) alineados con
/// `VolleyScan_Next/src/app/usuario/horario/page.jsx` y
/// `Backend_VolleyScan/vinculos/horario.py`.
class ScheduleTeamRef {
  final int id;
  final String nombre;

  const ScheduleTeamRef({required this.id, required this.nombre});

  factory ScheduleTeamRef.fromJson(Map<String, dynamic> json) {
    return ScheduleTeamRef(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
    );
  }
}

class ScheduleEvent {
  final int id;
  final String titulo;
  final String tipo;
  final String estado;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String? ubicacion;
  final String? notas;
  final ScheduleTeamRef? equipo;
  final String entrenador;
  final String? miAsistencia;
  final String? miObservacion;

  const ScheduleEvent({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.ubicacion,
    this.notas,
    this.equipo,
    this.entrenador = '',
    this.miAsistencia,
    this.miObservacion,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    final rawEquipo = json['equipo'];
    return ScheduleEvent(
      id: _toInt(json['id']) ?? 0,
      titulo: (json['titulo'] ?? '').toString().trim(),
      tipo: (json['tipo'] ?? 'otro').toString().trim(),
      estado: (json['estado'] ?? 'programado').toString().trim(),
      fecha: (json['fecha'] ?? '').toString().trim(),
      horaInicio: (json['horaInicio'] ?? '').toString().trim(),
      horaFin: (json['horaFin'] ?? '').toString().trim(),
      ubicacion: _optionalText(json['ubicacion']),
      notas: _optionalText(json['notas']),
      equipo: rawEquipo is Map
          ? ScheduleTeamRef.fromJson(Map<String, dynamic>.from(rawEquipo))
          : null,
      entrenador: (json['entrenador'] ?? '').toString().trim(),
      miAsistencia: _optionalText(json['miAsistencia']),
      miObservacion: _optionalText(json['miObservacion']),
    );
  }

  bool get isCancelled => estado == 'cancelado';
  bool get isCompleted => estado == 'completado';

  DateTime? get startDateTime => _parseWallDateTime(fecha, horaInicio);
  DateTime? get endDateTime => _parseWallDateTime(fecha, horaFin);
  DateTime? get dateOnly => _parseWallDate(fecha);

  String get tipoLabel => const <String, String>{
        'entrenamiento': 'Entrenamiento',
        'partido': 'Competencia',
        'evaluacion': 'Evaluación',
        'reunion': 'Reunión',
        'otro': 'Evento',
      }[tipo] ??
      'Evento';

  String? get asistenciaLabel => const <String, String>{
        'presente': 'Asististe',
        'tarde': 'Llegaste tarde',
        'ausente': 'Faltaste',
        'justificado': 'Falta justificada',
      }[miAsistencia];
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _optionalText(dynamic value) {
  final text = value?.toString().trim();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _parseWallDate(String isoDate) {
  final parts = isoDate.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

DateTime? _parseWallDateTime(String isoDate, String hhmm) {
  final date = _parseWallDate(isoDate);
  if (date == null) return null;
  final t = hhmm.split(':');
  if (t.length < 2) return null;
  final h = int.tryParse(t[0]);
  final min = int.tryParse(t[1]);
  if (h == null || min == null) return null;
  return DateTime(date.year, date.month, date.day, h, min);
}

/// Fecha local -> "AAAA-MM-DD" (replica `fechaISO` de Next).
String fechaIsoLocal(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

const _mesesLargoEs = <String>[
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

const _diasLargoEs = <String>[
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const _diasCortoEs = <String>[
  'lun',
  'mar',
  'mié',
  'jue',
  'vie',
  'sáb',
  'dom',
];

/// Replica `fMes.format(mes)` con primera letra en mayúscula.
String formatScheduleMonth(DateTime mes) {
  final nombre = _mesesLargoEs[mes.month - 1];
  final cap = '${nombre[0].toUpperCase()}${nombre.substring(1)}';
  return '$cap de ${mes.year}';
}

/// Replica `fDiaLargo.format(d)` (ej. "martes, 17 de noviembre").
String formatScheduleLongDay(DateTime d) {
  final diaSem = _diasLargoEs[d.weekday - 1];
  final mes = _mesesLargoEs[d.month - 1];
  return '$diaSem, ${d.day} de $mes';
}

/// Replica `fDiaCorto.format(d).replace(".", "")` (ej. "mar").
String formatScheduleShortWeekday(DateTime d) {
  return _diasCortoEs[d.weekday - 1];
}

/// Replica `cuentaRegresiva(fecha)` de `VolleyScan_Next/src/app/usuario/horario/page.jsx`.
String formatCountdown(DateTime start) {
  final diff = start.difference(DateTime.now());
  if (diff.inMilliseconds <= 0) return 'En curso ahora';
  final min = (diff.inSeconds / 60).round();
  if (min < 60) return 'Empieza en $min min';
  final h = (min / 60).round();
  if (h < 24) return 'Empieza en $h h';
  final d = (h / 24).round();
  return d == 1 ? 'Es mañana' : 'Faltan $d días';
}
