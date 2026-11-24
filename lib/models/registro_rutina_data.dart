import 'my_level_data.dart';

// Modelos de la pantalla "Registro de rutinas" del Panel de Entrenador
// (`/panel_entrenador/registro-rutinas`), alineados con
// `VolleyScan_Next/src/app/panel_entrenador/registro-rutinas/page.jsx` y
// `Backend_VolleyScan/vinculos/registro_rutinas.py`.

int _toInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _toStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

String? _toNullableStr(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

const List<String> kNivelesOrden = <String>[
  'principiante',
  'intermedio',
  'avanzado',
  'profesional',
];

const Map<String, String> kNombreNivel = <String, String>{
  'principiante': 'Principiante',
  'intermedio': 'Intermedio',
  'avanzado': 'Avanzado',
  'profesional': 'Profesional',
  'todos': 'Todos los niveles',
};

const Map<int, String> kEtiquetaCalificacion = <int, String>{
  1: 'Muy floja',
  2: 'Mejorable',
  3: 'Correcta',
  4: 'Muy buena',
  5: 'Excelente',
};

String nombreNivelRegistro(String? raw) {
  if (raw == null) return '—';
  return kNombreNivel[raw.trim().toLowerCase()] ?? '—';
}

/// Datos básicos del deportista dentro de un registro de rutina.
class RegistroAtleta {
  final int id;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String nivel;

  const RegistroAtleta({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.nivel = 'principiante',
  });

  factory RegistroAtleta.fromJson(Map<String, dynamic> json) {
    return RegistroAtleta(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
      fotoUrl: _toNullableStr(json['fotoUrl']),
      nivel: _toStr(json['nivel'], 'principiante').toLowerCase(),
    );
  }

  String get nombreCompleto {
    final full = [nombre, apellido].where((s) => s.isNotEmpty).join(' ').trim();
    return full.isNotEmpty ? full : 'Deportista';
  }

  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    final ini = '$n$a'.toUpperCase();
    return ini.isNotEmpty ? ini : '?';
  }
}

/// Revisión del entrenador sobre una rutina completada.
class RegistroRevision {
  final int calificacion;
  final String? comentario;
  final String? notaPrivada;
  final String? revisadaEn;
  final String? actualizadaEn;

  const RegistroRevision({
    required this.calificacion,
    this.comentario,
    this.notaPrivada,
    this.revisadaEn,
    this.actualizadaEn,
  });

  factory RegistroRevision.fromJson(Map<String, dynamic> json) {
    return RegistroRevision(
      calificacion: _toInt(json['calificacion']).clamp(1, 5),
      comentario: _toNullableStr(json['comentario']),
      notaPrivada: _toNullableStr(json['notaPrivada']),
      revisadaEn: _toNullableStr(json['revisadaEn']),
      actualizadaEn: _toNullableStr(json['actualizadaEn']),
    );
  }
}

/// Ejercicio individual en el detalle de una rutina completada.
class RegistroEjercicioDetalle {
  final String nombre;
  final int series;
  final int repeticiones;
  final String? completadoEn;

  const RegistroEjercicioDetalle({
    required this.nombre,
    required this.series,
    required this.repeticiones,
    this.completadoEn,
  });

  factory RegistroEjercicioDetalle.fromJson(Map<String, dynamic> json) {
    return RegistroEjercicioDetalle(
      nombre: _toStr(json['nombre']),
      series: _toInt(json['series'], 1),
      repeticiones: _toInt(json['repeticiones'], 1),
      completadoEn: _toNullableStr(json['completadoEn']),
    );
  }
}

/// Rutina completada en el registro (sirve tanto para lista como para detalle).
class RegistroRutinaItem {
  final int id;
  final RegistroAtleta atleta;
  final String nombre;
  final String? tipo;
  final String nivel;
  final String? objetivo;
  final int? intensidad;
  final int? duracionMin;
  final String? fechaProgramada;
  final int ejercicios;
  final String? completadaEn;
  final int? diasRetraso;
  final bool? aTiempo;
  final RegistroRevision? revision;
  final List<RegistroEjercicioDetalle> listaEjercicios;

  const RegistroRutinaItem({
    required this.id,
    required this.atleta,
    required this.nombre,
    this.tipo,
    this.nivel = 'intermedio',
    this.objetivo,
    this.intensidad,
    this.duracionMin,
    this.fechaProgramada,
    this.ejercicios = 0,
    this.completadaEn,
    this.diasRetraso,
    this.aTiempo,
    this.revision,
    this.listaEjercicios = const <RegistroEjercicioDetalle>[],
  });

  factory RegistroRutinaItem.fromJson(Map<String, dynamic> json) {
    final rawAtleta = json['atleta'];
    final rawRev = json['revision'];
    final rawLista = json['listaEjercicios'];
    return RegistroRutinaItem(
      id: _toInt(json['id']),
      atleta: rawAtleta is Map
          ? RegistroAtleta.fromJson(Map<String, dynamic>.from(rawAtleta))
          : const RegistroAtleta(id: 0, nombre: '', apellido: ''),
      nombre: _toStr(json['nombre']),
      tipo: _toNullableStr(json['tipo']),
      nivel: _toStr(json['nivel'], 'intermedio').toLowerCase(),
      objetivo: _toNullableStr(json['objetivo']),
      intensidad: _toNullableInt(json['intensidad']),
      duracionMin: _toNullableInt(json['duracionMin']),
      fechaProgramada: _toNullableStr(json['fechaProgramada']),
      ejercicios: _toInt(json['ejercicios']),
      completadaEn: _toNullableStr(json['completadaEn']),
      diasRetraso: _toNullableInt(json['diasRetraso']),
      aTiempo: json['aTiempo'] is bool ? json['aTiempo'] as bool : null,
      revision: rawRev is Map
          ? RegistroRevision.fromJson(Map<String, dynamic>.from(rawRev))
          : null,
      listaEjercicios: rawLista is List
          ? rawLista
              .whereType<Map>()
              .map(
                (e) => RegistroEjercicioDetalle.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const <RegistroEjercicioDetalle>[],
    );
  }
}

/// Cifras resumen de `GET /api/ia/registro-rutinas`.
class RegistroResumen {
  final int total;
  final int pendientes;
  final int revisadas;
  final double? calificacionPromedio;
  final int? aTiempoPct;

  const RegistroResumen({
    this.total = 0,
    this.pendientes = 0,
    this.revisadas = 0,
    this.calificacionPromedio,
    this.aTiempoPct,
  });

  factory RegistroResumen.fromJson(Map<String, dynamic> json) {
    return RegistroResumen(
      total: _toInt(json['total']),
      pendientes: _toInt(json['pendientes']),
      revisadas: _toInt(json['revisadas']),
      calificacionPromedio: _toNullableDouble(json['calificacionPromedio']),
      aTiempoPct: _toNullableInt(json['aTiempoPct']),
    );
  }
}

class RegistroRutinasResponse {
  final RegistroResumen resumen;
  final List<RegistroRutinaItem> items;

  const RegistroRutinasResponse({
    this.resumen = const RegistroResumen(),
    this.items = const <RegistroRutinaItem>[],
  });

  factory RegistroRutinasResponse.fromJson(Map<String, dynamic> json) {
    final rawRes = json['resumen'];
    final rawItems = json['items'];
    return RegistroRutinasResponse(
      resumen: rawRes is Map
          ? RegistroResumen.fromJson(Map<String, dynamic>.from(rawRes))
          : const RegistroResumen(),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (e) => RegistroRutinaItem.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : const <RegistroRutinaItem>[],
    );
  }
}

/// Deportista con su nivel y progreso hacia el siguiente (`GET /api/ia/niveles/deportistas`).
class DeportistaNivelResumen {
  final int id;
  final String nombre;
  final String apellido;
  final String? fotoUrl;
  final String? posicion;
  final String nivel;
  final String? ultimoCambio;
  final int pendientesRevision;
  final LevelAdvance avance;

  const DeportistaNivelResumen({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.fotoUrl,
    this.posicion,
    this.nivel = 'principiante',
    this.ultimoCambio,
    this.pendientesRevision = 0,
    required this.avance,
  });

  factory DeportistaNivelResumen.fromJson(Map<String, dynamic> json) {
    final rawAvance = json['avance'];
    return DeportistaNivelResumen(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
      fotoUrl: _toNullableStr(json['fotoUrl']),
      posicion: _toNullableStr(json['posicion']),
      nivel: _toStr(json['nivel'], 'principiante').toLowerCase(),
      ultimoCambio: _toNullableStr(json['ultimoCambio']),
      pendientesRevision: _toInt(json['pendientesRevision']),
      avance: rawAvance is Map
          ? LevelAdvance.fromJson(Map<String, dynamic>.from(rawAvance))
          : const LevelAdvance(nivelActual: 'principiante'),
    );
  }

  String get nombreCompleto {
    final full = [nombre, apellido].where((s) => s.isNotEmpty).join(' ').trim();
    return full.isNotEmpty ? full : 'Deportista';
  }

  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    final ini = '$n$a'.toUpperCase();
    return ini.isNotEmpty ? ini : '?';
  }
}

/// Detalle e historial de niveles de un deportista (`GET /api/ia/niveles/deportistas/<id>`).
class DeportistaNivelDetalle {
  final int id;
  final String nombre;
  final String apellido;
  final String nivel;
  final LevelAdvance avance;
  final List<LevelHistoryItem> historial;

  const DeportistaNivelDetalle({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.nivel = 'principiante',
    required this.avance,
    this.historial = const <LevelHistoryItem>[],
  });

  factory DeportistaNivelDetalle.fromJson(Map<String, dynamic> json) {
    final rawAvance = json['avance'];
    final rawHist = json['historial'];
    return DeportistaNivelDetalle(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
      nivel: _toStr(json['nivel'], 'principiante').toLowerCase(),
      avance: rawAvance is Map
          ? LevelAdvance.fromJson(Map<String, dynamic>.from(rawAvance))
          : const LevelAdvance(nivelActual: 'principiante'),
      historial: rawHist is List
          ? rawHist
              .whereType<Map>()
              .map(
                (e) => LevelHistoryItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const <LevelHistoryItem>[],
    );
  }
}
