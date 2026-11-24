/// Modelos de la pantalla "Horario" del deportista (`/usuario/horario`) y del
/// entrenador (`/panel_entrenador/horario`), alineados con
/// `Backend_VolleyScan/vinculos/horario.py` y `asistencia.py`.
class ScheduleTeamRef {
  final int id;
  final String nombre;

  const ScheduleTeamRef({required this.id, required this.nombre});

  factory ScheduleTeamRef.fromJson(Map<String, dynamic> json) => ScheduleTeamRef(
        id: _toInt(json['id']) ?? 0,
        nombre: (json['nombre'] ?? '').toString().trim(),
      );
}

class ScheduleEvent {
  final int id;
  final String titulo, tipo, estado, fecha, horaInicio, horaFin, entrenador;
  final String? ubicacion, notas, miAsistencia, miObservacion;
  final ScheduleTeamRef? equipo;

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
      equipo: rawEquipo is Map ? ScheduleTeamRef.fromJson(Map<String, dynamic>.from(rawEquipo)) : null,
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

  String get tipoLabel =>
      const <String, String>{
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

// ── Modelos del Horario del Entrenador (/api/ia/horario...) ──────────

class CoachScheduleAthleteRef {
  final int id;
  final String nombre;
  const CoachScheduleAthleteRef({required this.id, required this.nombre});

  factory CoachScheduleAthleteRef.fromJson(Map<String, dynamic> json) =>
      CoachScheduleAthleteRef(id: _toInt(json['id']) ?? 0, nombre: (json['nombre'] ?? '').toString().trim());
}

class CoachScheduleEvent {
  final int id, asistenciaMarcada;
  final String titulo, tipo, estado, fecha, horaInicio, horaFin;
  final String ubicacion, notas, creadoPor;
  final ScheduleTeamRef? equipo;
  final List<CoachScheduleAthleteRef> deportistas;
  final bool puedeEditar;

  const CoachScheduleEvent({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.estado,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.ubicacion = '',
    this.notas = '',
    this.equipo,
    this.deportistas = const <CoachScheduleAthleteRef>[],
    this.creadoPor = '',
    this.puedeEditar = true,
    this.asistenciaMarcada = 0,
  });

  factory CoachScheduleEvent.fromJson(Map<String, dynamic> json) {
    final rawEq = json['equipo'];
    final rawDeps = json['deportistas'];
    final rawDep = json['deportista'];
    final List<CoachScheduleAthleteRef> citados = rawDeps is List
        ? rawDeps.whereType<Map>().map((m) => CoachScheduleAthleteRef.fromJson(Map<String, dynamic>.from(m))).toList()
        : (rawDep is Map ? [CoachScheduleAthleteRef.fromJson(Map<String, dynamic>.from(rawDep))] : const <CoachScheduleAthleteRef>[]);

    return CoachScheduleEvent(
      id: _toInt(json['id']) ?? 0,
      titulo: (json['titulo'] ?? '').toString().trim(),
      tipo: (json['tipo'] ?? 'entrenamiento').toString().trim(),
      estado: (json['estado'] ?? 'programado').toString().trim(),
      fecha: (json['fecha'] ?? '').toString().trim(),
      horaInicio: (json['horaInicio'] ?? '09:00').toString().trim(),
      horaFin: (json['horaFin'] ?? '11:00').toString().trim(),
      ubicacion: (json['ubicacion'] ?? '').toString().trim(),
      notas: (json['notas'] ?? '').toString().trim(),
      equipo: rawEq is Map ? ScheduleTeamRef.fromJson(Map<String, dynamic>.from(rawEq)) : null,
      deportistas: citados,
      creadoPor: (json['creadoPor'] ?? '').toString().trim(),
      puedeEditar: json['puedeEditar'] != false,
      asistenciaMarcada: _toInt(json['asistenciaMarcada']) ?? 0,
    );
  }

  DateTime get start => _parseWallDateTime(fecha, horaInicio) ?? DateTime.now();
  DateTime get end => _parseWallDateTime(fecha, horaFin) ?? DateTime.now();
  bool get isCancelled => estado == 'cancelado';
  bool get isCompleted => estado == 'completado';
  bool get conLista => equipo != null || deportistas.isNotEmpty;

  String get paraQuien {
    if (equipo != null) return equipo!.nombre;
    if (deportistas.length == 1) return deportistas.first.nombre;
    if (deportistas.length > 1) return '${deportistas.length} deportistas';
    return '';
  }
}

class CoachAttendanceAthlete {
  final int id;
  final String nombre, apellido, observacion;
  final String? fotoUrl, posicion, estado;
  final int? numeroCamiseta;
  final bool activo, observacionVisible;

  const CoachAttendanceAthlete({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.posicion,
    this.numeroCamiseta,
    this.activo = true,
    this.estado,
    this.observacion = '',
    this.observacionVisible = false,
  });

  String get nombreCompleto => [nombre.trim(), apellido.trim()].where((s) => s.isNotEmpty).join(' ');

  factory CoachAttendanceAthlete.fromJson(Map<String, dynamic> j) => CoachAttendanceAthlete(
        id: _toInt(j['id']) ?? 0,
        nombre: (j['nombre'] ?? '').toString().trim(),
        apellido: (j['apellido'] ?? '').toString().trim(),
        fotoUrl: _optionalText(j['fotoUrl']),
        posicion: _optionalText(j['posicion']),
        numeroCamiseta: _toInt(j['numeroCamiseta']),
        activo: j['activo'] != false,
        estado: _optionalText(j['estado']),
        observacion: (j['observacion'] ?? '').toString(),
        observacionVisible: j['observacionVisible'] == true,
      );
}

class CoachAttendanceResponse {
  final CoachScheduleEvent evento;
  final List<CoachAttendanceAthlete> deportistas;
  final bool puedePasarLista;

  const CoachAttendanceResponse({required this.evento, required this.deportistas, required this.puedePasarLista});

  factory CoachAttendanceResponse.fromJson(Map<String, dynamic> j) {
    final rawEv = j['evento'];
    final rawDeps = j['deportistas'];
    return CoachAttendanceResponse(
      evento: rawEv is Map
          ? CoachScheduleEvent.fromJson(Map<String, dynamic>.from(rawEv))
          : const CoachScheduleEvent(id: 0, titulo: '', tipo: 'entrenamiento', estado: 'programado', fecha: '', horaInicio: '09:00', horaFin: '11:00'),
      deportistas: rawDeps is List
          ? rawDeps.whereType<Map>().map((m) => CoachAttendanceAthlete.fromJson(Map<String, dynamic>.from(m))).toList()
          : const <CoachAttendanceAthlete>[],
      puedePasarLista: j['puedePasarLista'] == true,
    );
  }
}

int? _toInt(dynamic v) => v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

String? _optionalText(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

DateTime? _parseWallDate(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return null;
  final y = int.tryParse(p[0]), m = int.tryParse(p[1]), d = int.tryParse(p[2]);
  return (y == null || m == null || d == null) ? null : DateTime(y, m, d);
}

DateTime? _parseWallDateTime(String iso, String hhmm) {
  final date = _parseWallDate(iso);
  final t = hhmm.split(':');
  if (date == null || t.length < 2) return null;
  final h = int.tryParse(t[0]), min = int.tryParse(t[1]);
  return (h == null || min == null) ? null : DateTime(date.year, date.month, date.day, h, min);
}

String fechaIsoLocal(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _mesesLargoEs = <String>['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
const _diasLargoEs = <String>['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _diasCortoEs = <String>['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

String formatScheduleMonth(DateTime mes) {
  final n = _mesesLargoEs[mes.month - 1];
  return '${n[0].toUpperCase()}${n.substring(1)} de ${mes.year}';
}

String formatScheduleLongDay(DateTime d) => '${_diasLargoEs[d.weekday - 1]}, ${d.day} de ${_mesesLargoEs[d.month - 1]}';
String formatScheduleShortWeekday(DateTime d) => _diasCortoEs[d.weekday - 1];

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
