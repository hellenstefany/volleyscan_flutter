/// Modelos de la pantalla "Mis rutinas" (`/usuario/rutinas`) alineados con
/// `VolleyScan_Next/src/app/usuario/rutinas/page.jsx` y
/// `Backend_VolleyScan/panel_usuario/rutinas/views.py`.
class RoutineProgress {
  final int total;
  final int completados;
  final int porcentaje;

  const RoutineProgress({
    this.total = 0,
    this.completados = 0,
    this.porcentaje = 0,
  });

  factory RoutineProgress.fromJson(Map<String, dynamic> json) {
    final total = _toInt(json['total']) ?? 0;
    final completados = _toInt(json['completados']) ?? 0;
    final pct = _toInt(json['porcentaje']) ??
        (total > 0 ? ((completados * 100) / total).round() : 0);
    return RoutineProgress(
      total: total,
      completados: completados,
      porcentaje: pct,
    );
  }

  bool get isComplete => total > 0 && completados >= total;
}

class RoutineSummary {
  final int id;
  final String nombre;
  final String descripcion;
  final String nivel;
  final String objetivo;
  final bool activa;
  final int totalEjercicios;
  final int completados;

  const RoutineSummary({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.nivel = 'intermedio',
    this.objetivo = '',
    this.activa = true,
    this.totalEjercicios = 0,
    this.completados = 0,
  });

  factory RoutineSummary.fromJson(Map<String, dynamic> json) {
    final total = _toInt(json['total_ejercicios']) ?? 0;
    final done = _toInt(json['completados']) ?? 0;
    return RoutineSummary(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      descripcion: (json['descripcion'] ?? '').toString().trim(),
      nivel: (json['nivel'] ?? 'intermedio').toString().trim().toLowerCase(),
      objetivo: (json['objetivo'] ?? '').toString().trim(),
      activa: json['activa'] != false,
      totalEjercicios: total,
      completados: done,
    );
  }

  int get porcentaje =>
      totalEjercicios > 0 ? ((completados * 100) / totalEjercicios).round() : 0;

  RoutineSummary copyWith({int? totalEjercicios, int? completados}) {
    return RoutineSummary(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      nivel: nivel,
      objetivo: objetivo,
      activa: activa,
      totalEjercicios: totalEjercicios ?? this.totalEjercicios,
      completados: completados ?? this.completados,
    );
  }
}

class RoutineExerciseItem {
  final int id;
  final String nombre;
  final int series;
  final int repeticiones;
  final int orden;
  final bool completado;

  const RoutineExerciseItem({
    required this.id,
    required this.nombre,
    required this.series,
    required this.repeticiones,
    this.orden = 0,
    this.completado = false,
  });

  factory RoutineExerciseItem.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseItem(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      series: _toInt(json['series']) ?? 0,
      repeticiones: _toInt(json['repeticiones']) ?? 0,
      orden: _toInt(json['orden']) ?? 0,
      completado: json['completado'] == true,
    );
  }

  RoutineExerciseItem copyWith({bool? completado}) {
    return RoutineExerciseItem(
      id: id,
      nombre: nombre,
      series: series,
      repeticiones: repeticiones,
      orden: orden,
      completado: completado ?? this.completado,
    );
  }
}

class RoutineDetail {
  final int id;
  final String nombre;
  final String descripcion;
  final String nivel;
  final String objetivo;
  final bool activa;
  final RoutineProgress progreso;
  final List<RoutineExerciseItem> ejercicios;

  const RoutineDetail({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    this.nivel = 'intermedio',
    this.objetivo = '',
    this.activa = true,
    this.progreso = const RoutineProgress(),
    this.ejercicios = const <RoutineExerciseItem>[],
  });

  factory RoutineDetail.fromJson(Map<String, dynamic> json) {
    final rawProg = json['progreso'];
    final rawExercises = json['ejercicios'];
    return RoutineDetail(
      id: _toInt(json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString().trim(),
      descripcion: (json['descripcion'] ?? '').toString().trim(),
      nivel: (json['nivel'] ?? 'intermedio').toString().trim().toLowerCase(),
      objetivo: (json['objetivo'] ?? '').toString().trim(),
      activa: json['activa'] != false,
      progreso: rawProg is Map
          ? RoutineProgress.fromJson(Map<String, dynamic>.from(rawProg))
          : const RoutineProgress(),
      ejercicios: rawExercises is List
          ? rawExercises
              .whereType<Map>()
              .map(
                (e) =>
                    RoutineExerciseItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
          : const <RoutineExerciseItem>[],
    );
  }

  RoutineDetail copyWith({
    RoutineProgress? progreso,
    List<RoutineExerciseItem>? ejercicios,
  }) {
    return RoutineDetail(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      nivel: nivel,
      objetivo: objetivo,
      activa: activa,
      progreso: progreso ?? this.progreso,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }
}

class ToggleExerciseResult {
  final RoutineExerciseItem ejercicio;
  final RoutineProgress progreso;

  const ToggleExerciseResult({
    required this.ejercicio,
    required this.progreso,
  });

  factory ToggleExerciseResult.fromJson(Map<String, dynamic> json) {
    final rawEx = json['ejercicio'];
    final rawProg = json['progreso'];
    return ToggleExerciseResult(
      ejercicio: rawEx is Map
          ? RoutineExerciseItem.fromJson(Map<String, dynamic>.from(rawEx))
          : const RoutineExerciseItem(
              id: 0,
              nombre: '',
              series: 0,
              repeticiones: 0,
            ),
      progreso: rawProg is Map
          ? RoutineProgress.fromJson(Map<String, dynamic>.from(rawProg))
          : const RoutineProgress(),
    );
  }
}

const routineLevelOrder = <String>[
  'principiante',
  'intermedio',
  'avanzado',
  'profesional',
];

String formatRoutineLevelLabel(String nivel) {
  final n = nivel.trim().toLowerCase();
  if (n == 'todos') return 'Todos los niveles';
  if (n.isEmpty) return 'Rutina';
  return '${n[0].toUpperCase()}${n.substring(1)}';
}

int routineLevelIndex(String nivel) {
  final n = nivel.trim().toLowerCase();
  if (n == 'todos') return routineLevelOrder.length - 1;
  final idx = routineLevelOrder.indexOf(n);
  return idx >= 0 ? idx : 1;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
