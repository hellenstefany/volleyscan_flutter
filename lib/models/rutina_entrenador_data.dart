// Modelos de la pantalla "Rutinas" del Panel de Entrenador
// (`/panel_entrenador/rutinas`), alineados con
// `VolleyScan_Next/src/app/panel_entrenador/rutinas/page.jsx` y
// `Backend_VolleyScan/vinculos/asignaciones.py`.

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

String _toStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString().trim();
}

String? _toNullableStr(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

/// Datos básicos del deportista asignado a una rutina.
class RutinaAtleta {
  final int id;
  final String nombre;
  final String apellido;

  const RutinaAtleta({
    required this.id,
    required this.nombre,
    required this.apellido,
  });

  factory RutinaAtleta.fromJson(Map<String, dynamic> json) {
    return RutinaAtleta(
      id: _toInt(json['id']),
      nombre: _toStr(json['nombre']),
      apellido: _toStr(json['apellido']),
    );
  }

  String get nombreCompleto {
    final full = [nombre, apellido].where((s) => s.isNotEmpty).join(' ').trim();
    return full.isNotEmpty ? full : 'Deportista';
  }
}

/// Ejercicio dentro de una rutina asignada por el entrenador.
class RutinaEjercicio {
  final int? id;
  final String nombre;
  final int series;
  final int repeticiones;
  final bool completado;
  final String? completadoEn;

  const RutinaEjercicio({
    this.id,
    required this.nombre,
    this.series = 3,
    this.repeticiones = 10,
    this.completado = false,
    this.completadoEn,
  });

  factory RutinaEjercicio.fromJson(Map<String, dynamic> json) {
    return RutinaEjercicio(
      id: _toNullableInt(json['id']),
      nombre: _toStr(json['nombre']),
      series: _toInt(json['series'], 3).clamp(1, 99),
      repeticiones: _toInt(json['repeticiones'], 10).clamp(1, 99),
      completado: json['completado'] == true,
      completadoEn: _toNullableStr(json['completadoEn']),
    );
  }

  RutinaEjercicio copyWith({
    int? series,
    int? repeticiones,
  }) {
    return RutinaEjercicio(
      id: id,
      nombre: nombre,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      completado: completado,
      completadoEn: completadoEn,
    );
  }

  Map<String, dynamic> toPayloadJson() => {
        'nombre': nombre,
        'series': series.clamp(1, 99),
        'repeticiones': repeticiones.clamp(1, 99),
      };
}

/// Avance del deportista en los ejercicios de una rutina.
class RutinaProgreso {
  final int total;
  final int completados;
  final int porcentaje;

  const RutinaProgreso({
    this.total = 0,
    this.completados = 0,
    this.porcentaje = 0,
  });

  factory RutinaProgreso.fromJson(Map<String, dynamic> json) {
    final total = _toInt(json['total']);
    final completados = _toInt(json['completados']);
    final pct = _toNullableInt(json['porcentaje']) ??
        (total > 0 ? ((completados * 100) / total).round() : 0);
    return RutinaProgreso(
      total: total,
      completados: completados,
      porcentaje: pct,
    );
  }
}

/// Rutina asignada por el entrenador (`GET /api/ia/rutinas/entrenador`).
class RutinaEntrenador {
  final int id;
  final RutinaAtleta atleta;
  final String nombre;
  final String tipo;
  final String nivel;
  final String? objetivo;
  final String? notas;
  final String? horaInicio;
  final int duracionMin;
  final int intensidad;
  final String? fechaProgramada;
  final List<RutinaEjercicio> ejercicios;
  final RutinaProgreso progreso;
  final bool completada;
  final String? completadaEn;

  const RutinaEntrenador({
    required this.id,
    required this.atleta,
    required this.nombre,
    required this.tipo,
    this.nivel = 'intermedio',
    this.objetivo,
    this.notas,
    this.horaInicio,
    this.duracionMin = 60,
    this.intensidad = 6,
    this.fechaProgramada,
    this.ejercicios = const <RutinaEjercicio>[],
    this.progreso = const RutinaProgreso(),
    this.completada = false,
    this.completadaEn,
  });

  factory RutinaEntrenador.fromJson(Map<String, dynamic> json) {
    final rawAtleta = json['atleta'];
    final rawEjercicios = json['ejercicios'];
    final rawProgreso = json['progreso'];
    return RutinaEntrenador(
      id: _toInt(json['id']),
      atleta: rawAtleta is Map
          ? RutinaAtleta.fromJson(Map<String, dynamic>.from(rawAtleta))
          : const RutinaAtleta(id: 0, nombre: '', apellido: ''),
      nombre: _toStr(json['nombre']),
      tipo: _toStr(json['tipo']),
      nivel: _toStr(json['nivel'], 'intermedio').toLowerCase(),
      objetivo: _toNullableStr(json['objetivo']),
      notas: _toNullableStr(json['notas']),
      horaInicio: _toNullableStr(json['horaInicio']),
      duracionMin: _toInt(json['duracionMin'], 60),
      intensidad: _toInt(json['intensidad'], 6),
      fechaProgramada: _toNullableStr(json['fechaProgramada']),
      ejercicios: rawEjercicios is List
          ? rawEjercicios
              .whereType<Map>()
              .map((e) => RutinaEjercicio.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const <RutinaEjercicio>[],
      progreso: rawProgreso is Map
          ? RutinaProgreso.fromJson(Map<String, dynamic>.from(rawProgreso))
          : const RutinaProgreso(),
      completada: json['completada'] == true,
      completadaEn: _toNullableStr(json['completadaEn']),
    );
  }
}
